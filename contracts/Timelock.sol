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

    //Transaction
    error AlreadyQueuedError(bytes32 txId);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestamp, uint256 timestamp);
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
    }

    // Mapping of transaction IDs to transaction data
    mapping(bytes32 => Tx) private txs;

    address public admin;

    uint256 private gracePeriod;

    address public whoDeposited;
    uint256 public depositAmt;
    uint256 public accountBalance;

    receive() external payable {
        accountBalance += msg.value;
        whoDeposited = msg.sender;
        depositAmt = msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    fallback() external payable {
        accountBalance += msg.value;
        whoDeposited = msg.sender;
        depositAmt = msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getGracePeriod() public view returns (uint256) {
        return gracePeriod;
    }

    function getTxId(address _target, uint256 _value)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_target, _value));
    }

    function queue(address _target, uint256 _value)
        external
        
        returns (bytes32)
    {
        // Generate the transaction ID based on the target and value
        bytes32 txId = getTxId(_target, _value);

        // Ensure the transaction is not already queued
        if (txs[txId].queued) {
            revert AlreadyQueuedError(txId);
        }

        // Store the new transaction
        Tx memory currentTx = Tx(txId, _target, _value, block.timestamp, true);
        txs[txId] = currentTx;

        // Emit the Queue event
        emit Queue(txId, _target, _value, block.timestamp);

        return txId;
    }

    function execute(bytes32 _txId)
        external
        payable
        
        returns (bytes memory)
    {
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

        // Ensure the transaction is executed within the grace period
        if (block.timestamp > currentTx.timestamp + gracePeriod) {
            revert TimestampExpiredError(
                block.timestamp,
                currentTx.timestamp + gracePeriod
            );
        }

        // Mark the transaction as executed
        txs[_txId].queued = false;

        // Execute the transaction using the .call function
        (bool ok, bytes memory res) = currentTx.target.call{
            value: currentTx.value
        }("");
        if (!ok) {
            revert TxFailedError();
        }

        // Emit the Execute event
        emit Execute(
            _txId,
            currentTx.target,
            currentTx.value,
            currentTx.timestamp
        );

        return res;
    }

    function cancel(bytes32 _txId) external  {
        // Ensure the transaction is queued
        if (!txs[_txId].queued) {
            revert NotQueuedError(_txId);
        }

        // Mark the transaction as canceled
        txs[_txId].queued = false;

        // Emit the Cancel event
        emit Cancel(_txId);
    }

    function getTx(bytes32 _txId)
        external
        view
        returns (Tx memory transaction)
    {
        return txs[_txId];
    }

    // Function to withdraw Ether from the contract (only admin)
    function withdraw(uint256 _amount) external  {
        require(_amount <= accountBalance, "Insufficient contract balance");
        accountBalance -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    //Grace Period Changing
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

    function startVoting(uint256 _proposedGracePeriod) public onlyAdmin {
        require(
            (_proposedGracePeriod >= minGracePeriod &&
                _proposedGracePeriod <= maxGracePeriod),
            "Proposed grace Period Out of range"
        );
        require(!votingActive, "Voting is already active.");
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

    function voteForAdmin() public duringVotingPhase {
        require(proposedGracePeriod != 0, "No admin proposed.");
        require(
            accountsContract.accountExists(msg.sender),
            "Only registered users can vote."
        );
        require(voterHasVoted(msg.sender), "Already voted.");

        voted.push(msg.sender);

        // Check if vote threshold has been met
        if (getTotalVotes() >= voteThreshold) {
            finalizeVote();
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

    // FINALIZE the voting process after 10 minutes
    function finalizeVote() public afterVotingPhase {
        require(proposedGracePeriod != 0, "No proposed grace period.");

        gracePeriod = proposedGracePeriod;
        emit GracePeriodChanged(proposedGracePeriod);
        emit VotingFinalized(proposedGracePeriod);

        resetVoting();
    }

    function getCurrentGracePeriod() public view returns (uint256) {
        return gracePeriod;
    }

    function resetVoting() internal {
        proposedGracePeriod = 0;
        votingActive = false;

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
