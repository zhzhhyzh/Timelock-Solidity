// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccountManager {
    // Define a struct to hold account details
    struct Account {
        string name;
        string email;
        bool exists;
    }

    uint256 total = 0;

    // State variable to store the contract owner's address
    address private owner;

    // Mapping to store accounts with the address as the key
    mapping(address => Account)  public accounts;

    // Event to be emitted when an account is created
    event AccountCreated(address indexed user, string name, string email);

    // Event to be emitted when an account is purged
    event AccountPurged(address indexed user);

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create or update an account
    function createAccount(address _user, string memory _name, string memory _email) public onlyOwner {
        // Create or update the account details
        accounts[_user] = Account({
            name: _name,
            email: _email,
            exists: true
        });
        total++;
        emit AccountCreated(_user, _name, _email);
    }

    // Function to purge an account
    function purgeAccount(address _user) public onlyOwner {
        require(accounts[_user].exists, "Account does not exist");
        total--;
        // Delete the account details
        delete accounts[_user];

        emit AccountPurged(_user);
    }

    // Function to get account details
    function getAccountDetails(address _user) public view onlyOwner returns (string memory name, string memory email) {
        require(accounts[_user].exists, "Account does not exist");

        Account memory account = accounts[_user];
        return (account.name, account.email);
    }

    // Retrieve the total number of accounts
    function getAccountCount() external view returns (uint256) {
        return total;
    }
   // Function to check if an account exists
    function accountExists(address _account) public view returns (bool) {
        return bytes(accounts[_account].name).length > 0;
    }
}
