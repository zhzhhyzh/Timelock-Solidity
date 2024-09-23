// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccountManager {
    //Account Manager----------------------------------------

    struct Account {
        address userAddress;
        string name;
        string email;
        bool exist;
        uint256 value;
    }

    uint256 public totalAccounts = 0;
    address private admin;

    mapping(address => Account) public accounts;

    address[] public accountAddresses;

    event AccountCreated(
        address indexed user,
        string name,
        string email,
        uint256 value
    );
    event AccountPurged(address indexed user);
    event DepositMade(address indexed user, uint256 amount);
    event WithdrawalMade(address indexed user, uint256 amount);
    event DepositUpdated(address indexed user, uint256 newAmount);
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Contract Admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function getAllAccounts() public view returns (Account[] memory) {
        Account[] memory allAccounts = new Account[](totalAccounts);
        uint256 count = 0;

        for (uint256 i = 0; i < accountAddresses.length; i++) {
            if (accounts[accountAddresses[i]].exist) {
                allAccounts[count] = accounts[accountAddresses[i]];
                count++;
            }
        }

        return allAccounts;
    }

    function getAccountCount() public view returns (uint256) {
        return totalAccounts;
    }

    function accountExists(address _account) public view returns (bool) {
        return accounts[_account].exist;
    }

    function createAccount(
        address _user,
        string memory _name,
        string memory _email
    ) public onlyAdmin  {
        require(!accounts[_user].exist, "Account already exists");

        accounts[_user] = Account({
            userAddress: _user,
            name: _name,
            email: _email,
            exist: true,
            value: 0
        });
        accountAddresses.push(_user); // Add the user's address to the array
        totalAccounts++;

        emit AccountCreated(_user, _name, _email, 0);
    }

    function purgeAccount(address _user) public onlyAdmin {
        require(accounts[_user].exist, "Account doesn't exist");

        totalAccounts--;
        delete accounts[_user];

        for (uint256 i = 0; i < accountAddresses.length; i++) {
            if (accountAddresses[i] == _user) {
                accountAddresses[i] = accountAddresses[
                    accountAddresses.length - 1
                ];
                accountAddresses.pop(); // Remove last element
                break;
            }
        }

        emit AccountPurged(_user);
    }

    function getAccountDetails(
        address _user
    )
        public
        view
        returns (string memory name, string memory email, uint256 value)
    {
        require(accounts[_user].exist, "Account doesn't exist");
        Account memory account = accounts[_user];
        return (account.name, account.email, account.value);
    }

    function deposit() public payable {
        require(accounts[msg.sender].exist, "Account doesn't exist");
        require(msg.value > 0, "You need to deposit some Ether");

        // Update the user's balance
        accounts[msg.sender].value += msg.value;

        // Emit the DepositMade event
        emit DepositMade(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        require(accounts[msg.sender].exist, "Account doesn't exist");
        require(_amount > 0, "Withdraw amount must be greater than zero");
        require(accounts[msg.sender].value >= _amount, "Insufficient balance");

        // Deduct the withdrawn amount from the user's balance
        accounts[msg.sender].value -= _amount;

        // Transfer the Ether back to the user
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");

        // Emit the WithdrawalMade event
        emit WithdrawalMade(msg.sender, _amount);
    }

    function depositUpdate(
        address _user,
        uint256 _newAmount
    ) public returns (bool success) {
        require(accounts[_user].exist, "Account doesn't exist");

        // Update the user's value to the new amount
        accounts[_user].value = _newAmount;

        // Emit the DepositUpdated event
        emit DepositUpdated(_user, _newAmount);
        return true;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function adminGetAccountDeposit(
        address _target
    ) public  view  onlyAdmin returns (uint256 value) {
        require(accounts[_target].exist, "Account doesn't exist");
        Account memory account = accounts[_target];
        return account.value;
    }

    // for proccesing use onlt

     function getAccountDeposit(
        address _target
    ) external  view  returns (uint256 value) {
        require(accounts[_target].exist, "Account doesn't exist");
        Account memory account = accounts[_target];
        return account.value;
    }
    function getMyDeposit(
    ) public view returns (uint256 value) {
        require(accounts[msg.sender].exist, "Account doesn't exist");
        Account memory account = accounts[msg.sender];
        return account.value;
    }

   
}
