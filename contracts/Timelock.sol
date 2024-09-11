// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Account.sol";

contract Timelock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint256 blockTimestamp, uint256 timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestmap, uint256 timestamp);
    error TimestampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error InvalidGracePeriodError();
    error VotingNotAllowedError();
    error AlreadyVotedError();
    error NoProposalError();

    event VotingReset();

    event GracePeriodUpdated(uint256 newGracePeriod);
    struct Tx {
        bytes32 txId;
        address target;
        uint256 value;
        string func;
        bytes data;
        uint256 timestamp;
        bool queued;
    }
    error TxFailedError();
    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    
    event Cancel(bytes32 indexed txId);
    modifier onlyVoter() {
        if (!accountsContract.accountExists(msg.sender)) {
            revert VotingNotAllowedError();
        }
        _;
    }
    mapping(address => bool) private hasVoted;
    uint256 private totalVotes;
    uint256 private votesForNewPeriod;
    uint256 private proposedGracePeriod;
    uint256 private constant MIN_DELAY = 10; // seconds
    uint256 private constant MAX_DELAY = 1000; // seconds.
    uint256 private gracePeriod = 30; // seconds
    address private owner;
    uint256 private votingStartTime;
    uint256 private constant VOTING_DURATION = 1 hours; // Duration for voting

    // tx id => tx
    mapping(bytes32 => Tx) private txs;
    // Declare a reference to the imported AccountsContract
    AccountManager  public accountsContract;

    // Constructor sets the address of the deployed AccountsContract

    constructor(address _accountsContractAddress) {
        owner = msg.sender;
        accountsContract = AccountManager(_accountsContractAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    receive() external payable {}

    function getTxId(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    function queue(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) external onlyOwner returns (bytes32) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (txs[txId].queued) {
            revert AlreadyQueuedError(txId);
        }
        Tx memory currentTx = Tx(
            txId,
            _target,
            _value,
            _func,
            _data,
            _timestamp,
            true
        );

        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }
        txs[txId] = currentTx;
        emit Queue(txId, _target, _value, _func, _data, _timestamp);

        return txId;
    }

    function execute(bytes32 _txId)
        external
        payable
        onlyOwner
        returns (bytes memory)
    {
        if (!txs[_txId].queued) {
            revert NotQueuedError(_txId);
        }
        Tx memory currentTx = txs[_txId];
        if (block.timestamp < currentTx.timestamp) {
            revert TimestampNotPassedError(
                block.timestamp,
                currentTx.timestamp
            );
        }
        if (block.timestamp > currentTx.timestamp + gracePeriod) {
            revert TimestampExpiredError(block.timestamp, gracePeriod);
        }

        txs[_txId].queued = false;
        // prepare data.
        bytes memory data;
        if (bytes(currentTx.func).length > 0) {
            // data func selector + _data
            data = abi.encodePacked(bytes4(keccak256(bytes(currentTx.func))));
        } else {
            // call fallback with data.
            data = currentTx.data;
        } // call target
        (bool ok, bytes memory res) = currentTx.target.call{
            value: currentTx.value
        }(data);
        if (!ok) {
            revert TxFailedError();
        }

        emit Execute(
            _txId,
            currentTx.target,
            currentTx.value,
            currentTx.func,
            currentTx.data,
            currentTx.timestamp
        );
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!txs[_txId].queued) {
            revert NotQueuedError(_txId);
        }
        txs[_txId].queued = false;
        emit Cancel(_txId);
    }

    function getTx(bytes32 _txId)
        external
        view
        returns (Tx memory transaction)
    {
        return txs[_txId];
    }

    // VOTING SYSTEM
    function proposeGracePeriod(uint256 _newGracePeriod) external onlyVoter {
        if(proposedGracePeriod<=0) revert NoProposalError();
        if (_newGracePeriod <= 0) {
            revert InvalidGracePeriodError();
        }
        proposedGracePeriod = _newGracePeriod;
        hasVoted[msg.sender] = true;
        votesForNewPeriod++;
        totalVotes = getTotalAccounts();
        checkResult();
    }

    function vote() external onlyVoter {
        if (hasVoted[msg.sender] == true) revert AlreadyVotedError();
        votesForNewPeriod++;
        checkResult();
    }

    function resetVoting() external onlyOwner{
        require(
            block.timestamp >= votingStartTime + VOTING_DURATION,
            "Voting period has not expired yet."
        );
        _resetVoting();
    }

    // Check if we have enough votes (simple majority)
    function checkResult() internal {
        if (votesForNewPeriod * 2 > totalVotes) {
            gracePeriod = proposedGracePeriod;
            emit GracePeriodUpdated(gracePeriod);
            _resetVoting();
        }
    }

    function _resetVoting() internal {
        for (uint256 i = 0; i < totalVotes; i++) {
            hasVoted[tx.origin] = false;
        }
        totalVotes = 0;
        votesForNewPeriod = 0;
        votingStartTime = 0;
        emit VotingReset();
    }

   
    // Example function to get the total number of accounts
    function getTotalAccounts() internal view returns (uint256) {
        return accountsContract.getAccountCount();
    }


    function getGracePeriod() internal view returns (uint256) {
        return gracePeriod;
    }
}
