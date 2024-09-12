// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Account.sol";

contract VoteAdmin {
   
    event NewAdminProposed(address indexed proposedAdmin);
    event AdminChanged(address indexed newAdmin);
    event VotingFinalized(address indexed newAdmin);

    AccountManager public accountsContract;

    constructor(address _accountsContractAddress) {
        admin = msg.sender;
        accountsContract = AccountManager(_accountsContractAddress);
    }

    
    address private proposedAdmin;
    uint private voteThreshold; // Auto calculate based on registered users
    uint private votingStartTime;
    uint private votingEndTime;
    uint private proposalDeadline;
    bool private votingActive;
    address private admin;
    address[] public voted; // List of all registered users

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this.");
        _;
    }
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

    modifier afterVotingPhase() {
        require(
            block.timestamp > votingEndTime,
            "Voting period has not ended."
        );
        _;
    }

    // Start the voting process with a time lock
    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting is already active.");
        // require(registeredUsers.length > 0, "No registered users available.");

        // Set the deadlines for proposal and voting
        votingStartTime = block.timestamp;
        proposalDeadline = block.timestamp + 2 minutes; // First 2 minutes for proposing
        votingEndTime = block.timestamp + 10 minutes; // Total of 10 minutes

        votingActive = true;

        // Recalculate vote threshold based on 51% of registered users
        updateVoteThreshold();
    }
    // Automatically calculate vote threshold (51% of registered users, rounded up)
    function updateVoteThreshold() internal {
        uint totalRegisteredUsers = accountsContract.getAccountCount();
        voteThreshold = (totalRegisteredUsers * 51 + 99) / 100; // Equivalent to rounding up (51% rule)
    }
    // PROPOSE a new admin during the first 2 minutes
    function proposeAdmin(address _proposedAdmin) public duringProposalPhase {
        require(proposedAdmin == address(0), "Admin is already proposed.");
        proposedAdmin = _proposedAdmin;
        emit NewAdminProposed(_proposedAdmin);
    }

    // VOTE for proposed admin (voting happens between 2 and 10 minutes)
    function voteForAdmin() public duringVotingPhase {
        require(proposedAdmin != address(0), "No admin proposed.");
        require(
            accountsContract.accountExists(msg.sender),
            "Only registered users can vote."
        );
        require(voterHasVoted(msg.sender), "Already voted.");

        voted.push(msg.sender);

        // Check if vote threshold has been met
        if (getTotalVotes() >= voteThreshold) {
            finalizeAdmin();
        }
    }
    function voterHasVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted.length; i++) {
            if (voted[i] == _address) {
                return true;
            }
        }

        return false;
    }
    // FINALIZE the voting process after 10 minutes
    function finalizeAdmin() public afterVotingPhase {
        require(proposedAdmin != address(0), "No proposed admin.");

        // Change the admin
        admin = proposedAdmin;
        emit AdminChanged(proposedAdmin);
        emit VotingFinalized(proposedAdmin);

        // Reset the voting state
        resetVoting();
    }
    function getCurrentAdmin() public returns (address) {
        return admin;
    }

    // Reset voting process after it ends
    function resetVoting() internal {
        proposedAdmin = address(0);
        votingActive = false;

       voted = [];
    }

    // Get total votes cast
    function getTotalVotes() internal view returns (uint totalVotes) {
        totalVotes = 0;
        for (uint i = 0; i < voted.length; i++) {
            totalVotes += voted[[i]];
        }

        return totalVotes;
    }
}
