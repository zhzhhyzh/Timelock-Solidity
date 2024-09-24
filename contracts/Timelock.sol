// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AccountManager.sol";

contract Timelock {

        AccountManager public accountsContract;

    constructor(
        address _accountsContractAddress
    ) {
        // admin = msg.sender;
        accountsContract = AccountManager(_accountsContractAddress);
     
    }

    //Transaction--------------------------------------------------------------
    error AlreadyQueuedError(bytes32 txId);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestamp, uint256 timestamp);
    error TimestampNotMatureError(uint256 blockTimestamp, uint256 expiresAt);
    error TimestampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error TxFailedError();

    event Queue(
        bytes32 indexed txId,
        address indexed sender,
        address indexed target,
        uint256 value,
        uint256 startTimestamp,
        uint256 endTimestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed sender,
        address indexed target,
        uint256 value,
        uint256 startTimestamp,
        uint256 endTimestamp
    );
    event Cancel(bytes32 indexed txId);
    event Deposited(address indexed user, uint256 amount);

enum TxStatus{
    Queued, 
    Completed,
    Cancelled,
    Failed
}
    // Struct to store transaction details
    struct Tx {
        bytes32 txId;
        address sender;
        address target;
        uint256 value;
        uint256 startTimestamp;
        uint256 endTimestamp;
        TxStatus status;
    }

    // Mapping of transaction IDs to transaction data
    mapping(bytes32 => Tx) private txs;
    mapping(uint => bytes32) private indexToTxMapping;
    uint txCount;
    address public whoDeposited;
    uint256 public depositAmt;
    uint256 public accountBalance;

    function getTxId(
        address _sender,
        address _target,
        uint256 _value,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_sender,_target, _value,_startTimestamp,_endTimestamp));
    }

    function queue(
        address _target,
        uint256 _value,
               uint256 _endTimestamp
        ) external returns (bytes32) {
        require(_value > 0, "Ether value must be greater than 0.");
        require(_endTimestamp > block.timestamp, "End date and time must be in future.");
        require(
            accountsContract.getAccountDeposit(msg.sender) > _value,
            "Insufficient Balance"
        );
        // Generate the transaction ID based on the target and value
        bytes32 txId = getTxId(msg.sender,_target, _value, block.timestamp, _endTimestamp);

        // Ensure the transaction is not already queued
        // if (txs[txId].status==TxStatus.Queued) {
        //     revert AlreadyQueuedError(txId);
        // }

        // Store the new transaction
        Tx memory currentTx = Tx(
            txId,
            msg.sender,
            _target,
            _value,
            block.timestamp,
            _endTimestamp,
            TxStatus.Queued
        );
        txs[txId] = currentTx;
        indexToTxMapping[txCount] = txId;

        uint256 newAmount = accountsContract.getAccountDeposit(msg.sender) -
            _value;
        // Emit the Queue event
        emit Queue(txId,msg.sender, _target, _value, block.timestamp,             _endTimestamp);
        addLog(currentTx);
        accountsContract.depositUpdate(msg.sender, newAmount);
        txCount++;
        return txId;
    }

    function getTxArr() public view returns (Tx[] memory) {
        Tx[] memory arr = new Tx[](txCount);
        for (uint i = 0; i < txCount; i++) {
            if (txs[indexToTxMapping[i]].status == TxStatus.Queued) {
                arr[i] = txs[indexToTxMapping[i]];
            }
        }
        return arr;
    }

    function execute(
        bytes32 _txId
    ) external  {
        // Ensure the transaction is actually queued
        if (txs[_txId].status!=TxStatus.Queued) {
            revert NotQueuedError(_txId);
        }

        Tx memory currentTx = txs[_txId];

        // // Ensure the timestamp has passed for execution
        // if (block.timestamp < currentTx.timestamp) {
        //     revert TimestampNotPassedError(
        //         block.timestamp,
        //         currentTx.timestamp
        //     );
        // }

        // Ensure the transaction is executed after the grace period
        if (block.timestamp < currentTx.endTimestamp ) {
            revert TimestampNotMatureError(
                block.timestamp,
                currentTx.endTimestamp
            );
        }

      
        uint256 newAmount = accountsContract.getAccountDeposit(
            currentTx.target
        ) + currentTx.value;
        bool success = accountsContract.depositUpdate(
            currentTx.target,
            newAmount
        );
        if (!success) {
            txs[_txId].status = TxStatus.Failed;
            updateStatus(_txId,TxStatus.Failed);
            revert TxFailedError();
        }
        // Mark the transaction as executed
        txs[_txId].status = TxStatus.Completed;

        // Emit the Execute event
        emit Execute(
           _txId,msg.sender, currentTx.target, currentTx.value, block.timestamp,             currentTx.endTimestamp
        );

        // return (currentTx.target, currentTx.value);
    }

    function cancel(
        bytes32 _txId
    ) external{
        // Ensure the transaction is queued
        if (txs[_txId].status!=TxStatus.Queued) {
            revert NotQueuedError(_txId);
        }

        Tx memory currentTx = txs[_txId];
        // // Ensure the transaction is executed in the grace period
        // if (block.timestamp >= currentTx.timestamp + gracePeriod) {
        //     revert TimestampExpiredError(
        //         block.timestamp,
        //         currentTx.timestamp + gracePeriod
        //     );
        // }
        // Mark the transaction as canceled

        txs[_txId].status = TxStatus.Cancelled;

        uint256 newAmount = accountsContract.getAccountDeposit(
            currentTx.sender
        ) + currentTx.value;
        bool success = accountsContract.depositUpdate(
            currentTx.sender,
            newAmount
        );
        // Emit the Cancel event
        emit Cancel(_txId);
                    updateStatus(_txId,TxStatus.Cancelled);

        require(success, "Failed to return Ether to depositor");
        // return (currentTx.depositor, currentTx.value);
    }

    function getTx(
        bytes32 _txId
    ) external view returns (Tx memory transaction) {
        return txs[_txId];
    }

    // ------------------- LISTING BY YEOH ZHE HENG ------------------
     struct Log {
        bytes32 txId;
        address sender;
        address target;
        uint256 value;
        uint256 startTimestamp; // Passed the scheduled for transaction date, in grace period form
        uint256 endTimestamp; // Passed the scheduled for transaction date, in grace period form
        TxStatus currentState;
    }

    Log[] internal logs;

    function listLogs() public view returns (Log[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].sender == msg.sender) {
                count++;
            }
        }

        Log[] memory filterLog = new Log[](count);
        count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].sender == msg.sender) {
                filterLog[count] = logs[i];
                count++;
            }
        }

        return filterLog;
    }

    function listQueued() public view returns (Log[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Queued
            ) {
                count++;
            }
        }

        Log[] memory filterLog = new Log[](count);
        count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Queued
            ) {
                filterLog[count] = logs[i];
                count++;
            }
        }

        return filterLog;
    }

    function listCancelled() public view returns (Log[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Cancelled
            ) {
                count++;
            }
        }

        Log[] memory filterLog = new Log[](count);
        count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Cancelled
            ) {
                filterLog[count] = logs[i];
                count++;
            }
        }

        return filterLog;
    }

     function listExecuted() public view returns (Log[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Completed
            ) {
                count++;
            }
        }

        Log[] memory filterLog = new Log[](count);
        count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Completed
            ) {
                filterLog[count] = logs[i];
                count++;
            }
        }

        return filterLog;
    }
     function listFailed() public view returns (Log[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Completed
            ) {
                count++;
            }
        }

        Log[] memory filterLog = new Log[](count);
        count = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].sender == msg.sender &&
                logs[i].currentState == TxStatus.Failed
            ) {
                filterLog[count] = logs[i];
                count++;
            }
        }

        return filterLog;
    }

    function addLog(
       Tx memory _tx
    ) internal returns (bool, string memory) {
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].txId == _tx.txId) {
                return (false, "Transaction ID already exists");
            }
        }

        logs.push(
            Log({
                txId: _tx.txId,
                sender: _tx.sender,
                target: _tx.target,
                value: _tx.value,
                startTimestamp: _tx.startTimestamp,
                endTimestamp: _tx.endTimestamp,
                currentState: TxStatus.Queued
            })
        );

        return (true, "Log added successfully");
    }

 function updateStatus(bytes32 _txId, TxStatus _status)internal returns(bool, string memory){
        bool found = false;
        uint256 count;
        while(count < logs.length){
            if(logs[count].txId == _txId){
                break;
            }
            count++;
        }
        if(!found){
            return (false, "Transaction Id not found");
        }

        logs[count].currentState = _status;
        return (true, "Update log successfully");
       
    }

   


}
