// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AccountManager.sol";

contract Timelock {
    constructor(
        address _accountsContractAddress,
        uint256 _minGracePeriod,
        uint256 _maxGracePeriod,
        uint256 _defaultGracePeriod
    ) {
        // admin = msg.sender;
        accountsContract = AccountManager(_accountsContractAddress);
        minGracePeriod = _minGracePeriod;
        maxGracePeriod = _maxGracePeriod;
        gracePeriod = _defaultGracePeriod;
    }

    //Transaction--------------------------------------------------------------
    error AlreadyQueuedError(bytes32 txId);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestamp, uint256 timestamp);
    error TimestampNotMatureError(uint256 blockTimestamp, uint256 expiresAt);
    error TimestampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error TxFailedError();
    error NotAdminError();

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        uint256 timestamp
    );
    event Cancel(bytes32 indexed txId);
    event Deposited(address indexed user, uint256 amount);

    // Struct to store transaction details
    struct Tx {
        bytes32 txId;
        address target;
        uint256 value;
        uint256 timestamp;
        bool queued;
        address depositor;
    }

    // Mapping of transaction IDs to transaction data
    mapping(bytes32 => Tx) private txs;
    mapping(uint => bytes32) private indexToTxMapping;
    uint txCount;
    address public admin;

    uint256 private gracePeriod;

    address public whoDeposited;
    uint256 public depositAmt;
    uint256 public accountBalance;

    function getGracePeriod() public view returns (uint256) {
        return gracePeriod;
    }

    function getTxId(
        address _target,
        uint256 _value,
        uint256 _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value,_timestamp));
    }

    function queue(address _target, uint256 _value) external returns (bytes32) {
        require(_value > 0, "Ether value must be greater than 0.");
        require(
            accountsContract.getAccountDeposit(msg.sender) > _value,
            "Insufficient Balance"
        );
        // Generate the transaction ID based on the target and value
        bytes32 txId = getTxId(_target, _value, block.timestamp);

        // Ensure the transaction is not already queued
        if (txs[txId].queued) {
            revert AlreadyQueuedError(txId);
        }

        // Store the new transaction
        Tx memory currentTx = Tx(
            txId,
            _target,
            _value,
            block.timestamp,
            true,
            msg.sender
        );
        txs[txId] = currentTx;
        indexToTxMapping[txCount] = txId;

        uint256 newAmount = accountsContract.getAccountDeposit(msg.sender) -
            _value;
        // Emit the Queue event
        emit Queue(txId, _target, _value, block.timestamp);
        accountsContract.depositUpdate(msg.sender, newAmount);
        txCount++;
        return txId;
    }

    function getTxArr() public view returns (Tx[] memory) {
        Tx[] memory arr = new Tx[](txCount);
        for (uint i = 0; i < txCount; i++) {
            if (txs[indexToTxMapping[i]].queued) {
                arr[i] = txs[indexToTxMapping[i]];
            }
        }
        return arr;
    }

    function execute(
        bytes32 _txId
    ) external returns (address target, uint256 value) {
        // Ensure the transaction is actually queued
        if (!txs[_txId].queued) {
            revert NotQueuedError(_txId);
        }

        Tx memory currentTx = txs[_txId];

        // Ensure the timestamp has passed for execution
        if (block.timestamp < currentTx.timestamp) {
            revert TimestampNotPassedError(
                block.timestamp,
                currentTx.timestamp
            );
        }

        // Ensure the transaction is executed after the grace period
        if (block.timestamp < currentTx.timestamp + gracePeriod) {
            revert TimestampNotMatureError(
                block.timestamp,
                currentTx.timestamp + gracePeriod
            );
        }

        // Mark the transaction as executed
        txs[_txId].queued = false;
        // Execute the transaction using the .call function

        uint256 newAmount = accountsContract.getAccountDeposit(
            currentTx.target
        ) + currentTx.value;
        bool success = accountsContract.depositUpdate(
            currentTx.target,
            newAmount
        );
        if (!success) {
            revert TxFailedError();
        }

        // Emit the Execute event
        emit Execute(
            _txId,
            currentTx.target,
            currentTx.value,
            currentTx.timestamp
        );

        return (currentTx.target, currentTx.value);
    }

    function cancel(
        bytes32 _txId
    ) external returns (address sender, uint256 value) {
        // Ensure the transaction is queued
        if (!txs[_txId].queued) {
            revert NotQueuedError(_txId);
        }

        Tx memory currentTx = txs[_txId];
        // Ensure the transaction is executed in the grace period
        if (block.timestamp >= currentTx.timestamp + gracePeriod) {
            revert TimestampExpiredError(
                block.timestamp,
                currentTx.timestamp + gracePeriod
            );
        }
        // Mark the transaction as canceled

        txs[_txId].queued = false;

        uint256 newAmount = accountsContract.getAccountDeposit(
            currentTx.depositor
        ) + currentTx.value;
        bool success = accountsContract.depositUpdate(
            currentTx.depositor,
            newAmount
        );
        // Emit the Cancel event
        emit Cancel(_txId);
        require(success, "Failed to return Ether to depositor");
        return (currentTx.depositor, currentTx.value);
    }

    function getTx(
        bytes32 _txId
    ) external view returns (Tx memory transaction) {
        return txs[_txId];
    }

    //Grace Period Voting-------------------------------------------------
    AccountManager public accountsContract;
    event NewGracePeriodProposed(uint256 newGracePeriod);
    event GracePeriodChanged(uint256 gracePeriod);
    event VotingFinalized(uint256 newGracePeriod);
    address public owner;
    uint256 public minGracePeriod;
    uint256 public maxGracePeriod;

    uint256 private votingStartTime;
    uint256 private votingEndTime;
    uint256 private proposalDeadline;
    bool private votingActive;
    uint256 private voteThreshold;
    address[] public voted;
    uint256 private proposedGracePeriod;
    modifier onlyAdmin() {
        require(
            msg.sender == accountsContract.getAdmin(),
            "Not Contract Admin"
        );
        _;
    }

    modifier duringVotingPhase() {
        require(
            block.timestamp >= votingStartTime &&
                block.timestamp <= votingEndTime,
            "Voting phase is not active."
        );
        _;
    }

    modifier afterVotingPhase() {
        require(
            block.timestamp > votingEndTime,
            "Voting period has not ended."
        );
        _;
    }

    function startVoting(uint256 _proposedGracePeriod) public {
        require(
            (_proposedGracePeriod >= minGracePeriod &&
                _proposedGracePeriod <= maxGracePeriod),
            "Proposed grace Period Out of range"
        );
        require(
            _proposedGracePeriod != gracePeriod,
            "Proposed grace period same with current grace period"
        );
        require(!votingActive, "Voting is already active.");
        resetVoting();
        votingStartTime = block.timestamp;
        votingEndTime = block.timestamp + 120; // Total of 2 minutes

        votingActive = true;

        updateVoteThreshold();
        proposedGracePeriod = _proposedGracePeriod;
        emit NewGracePeriodProposed(proposedGracePeriod);
    }

    function updateVoteThreshold() internal {
        uint256 totalRegisteredUsers = accountsContract.getAccountCount();
        voteThreshold = (totalRegisteredUsers * 51 + 99) / 100; // Equivalent to rounding up (51% rule)
    }

    function voteGracePeriod() public duringVotingPhase {
        require(proposedGracePeriod != 0, "No Grace Period proposed.");
        require(
            accountsContract.accountExists(msg.sender),
            "Only registered users can vote."
        );
        require(!voterHasVoted(msg.sender), "Already voted.");

        voted.push(msg.sender);

        // Check if vote threshold has been met
        if (getTotalVotes() >= voteThreshold) {
            finalizeGPByThresHold(proposedGracePeriod);
        }
    }

    function voterHasVoted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < voted.length; i++) {
            if (voted[i] == _address) {
                return true;
            }
        }

        return false;
    }

    function finalizeGPByThresHold(uint256 _proposedGracePeriod) internal {
        gracePeriod = _proposedGracePeriod;

        emit VotingFinalized(_proposedGracePeriod);
        resetVoting();
    }

    // FINALIZE the voting process after 2 minutes
    function finalizeVote() public afterVotingPhase {
        require(proposedGracePeriod != 0, "No proposed grace period.");
        if (getTotalVotes() >= voteThreshold) {
            finalizeGPByThresHold(proposedGracePeriod);
            emit GracePeriodChanged(proposedGracePeriod);
            emit VotingFinalized(proposedGracePeriod);
        } else {
            // require(false, "Total Votes is not reached the threshold");
        }

        resetVoting();
    }

    function getCurrentGracePeriod() public view returns (uint256) {
        return gracePeriod;
    }

    function getProposedGracePeriod() public view returns (uint256) {
        return proposedGracePeriod;
    }

    function resetVoting() internal {
        proposedGracePeriod = 0;
        votingActive = false;
        votingEndTime = 0;
        voted = new address[](0);
    }

    function getTotalVotes() internal view returns (uint256 totalVotes) {
        totalVotes = 0;
        for (uint256 i = 0; i < voted.length; i++) {
            totalVotes += voted.length;
        }

        return totalVotes;
    }
}
