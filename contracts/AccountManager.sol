// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccountManager {
    //Account Manager

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

    // Events
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
    ) public onlyAdmin notDuringVotingPhase {
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

    function getAccountDetails(address _user)
        public
        view
        onlyAdmin
        returns (
            string memory name,
            string memory email,
            uint256 value
        )
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

    function depositUpdate(address _user, uint256 _newAmount) public onlyAdmin {
        require(accounts[_user].exist, "Account doesn't exist");

        // Update the user's value to the new amount
        accounts[_user].value = _newAmount;

        // Emit the DepositUpdated event
        emit DepositUpdated(_user, _newAmount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //Vote Admin
    struct proposedAdmin {
        string name;
        bool exist;
        uint256 votes;
    }
    mapping(address => proposedAdmin) public proposedAdmins;
    uint256 private voteThreshold;
    address[] public proposedAdminAddresses;
    uint256 private votingStartTime;
    uint256 private votingEndTime;
    uint256 private proposalDeadline;
    bool private votingActive;
    uint256 proposedAdminsCounts;
    address[] public voted;
    event StartVoting();
    event AdminChanged(address indexed newAdmin);
    modifier duringProposalPhase() {
        require(
            block.timestamp <= proposalDeadline,
            "Proposal phase has ended."
        );
        _;
    }

    modifier duringVotingPhase() {
        require(
            block.timestamp >= proposalDeadline &&
                block.timestamp <= votingEndTime,
            "Voting phase is not active."
        );
        _;
    }

    modifier notDuringVotingPhase() {
        require(
            block.timestamp < proposalDeadline ||
                block.timestamp > votingEndTime,
            "Voting phase is active."
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

    modifier adminProposedRestrict() {
        require(proposedAdminsCounts < 3, "Proposed Admin Full");
        _;
    }

    modifier checkAdminProposed() {
        require(proposedAdminsCounts != 0, "No admin proposed");
        _;
    }

    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting is already active.");
        votingStartTime = block.timestamp;
        proposalDeadline = block.timestamp + 60; // First 1 minutes for proposing
        votingEndTime = block.timestamp + 120; // Total of 2 minutes

        votingActive = true;
        updateVoteThreshold();
        emit StartVoting();
    }

    function updateVoteThreshold() internal {
        uint256 totalRegisteredUsers = getAccountCount();
        voteThreshold = (totalRegisteredUsers * 51 + 99) / 100; // Equivalent to rounding up (51% rule)
    }

    function proposeAdmin(address _admin)
        public
        duringProposalPhase
        adminProposedRestrict
    {
        require(
            accounts[_admin].exist,
            "Address is not in the Account contract"
        );
        require(!proposedAdmins[_admin].exist, "Admin is already proposed.");
        proposedAdmins[_admin] = proposedAdmin(accounts[_admin].name, true, 0);
        proposedAdminAddresses.push(_admin);
        proposedAdminsCounts++;
    }

    function voteForAdmin(address _admin)
        public
        duringVotingPhase
        checkAdminProposed
    {
        require(accountExists(msg.sender), "Only registered users can vote.");
        require(!voterHasVoted(msg.sender), "Already voted.");
        voted.push(msg.sender);
        proposedAdmins[_admin].votes++; //Increment the voted proposed admin votes

        if (proposedAdmins[_admin].votes >= voteThreshold) {
            finalizeAdminByThresHold(_admin);
        }
    }

    function finalizeAdminByThresHold(address _admin) internal {
        admin = _admin;

        emit AdminChanged(_admin);
        resetVoting();
    }

    function finalizeAdmin() public afterVotingPhase checkAdminProposed {
        address mostVotedAdmin;
        uint256 highestVotes = 0;

        for (uint256 i = 0; i < proposedAdminAddresses.length; i++) {
            address proposedAddress = proposedAdminAddresses[i];
            uint256 votes = proposedAdmins[proposedAddress].votes;

            // Check if the current admin has more votes than the current highest
            if (votes > highestVotes) {
                highestVotes = votes;
                mostVotedAdmin = proposedAddress;
            }
        }

        require(mostVotedAdmin != address(0), "No valid admin found.");

        // Set the new admin
        admin = mostVotedAdmin;

        emit AdminChanged(mostVotedAdmin); // Emit an event for admin change

        resetVoting();
    }

    function resetVoting() internal {
        for (uint256 i = 0; i < voted.length; i++) {
            delete proposedAdmins[voted[i]]; // Reset the proposed admin votes
        }
        votingActive = false;
        proposedAdminsCounts = 0;
        delete proposedAdminAddresses;
        delete voted;
    }

    function voterHasVoted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < voted.length; i++) {
            if (voted[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
