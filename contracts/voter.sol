// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVotingSystem {
    address public admin;
    bool public votingActive;

    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool registered;
        bool voted;
    }

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    event VoterRegistered(address voter);
    event VoteCast(address voter, uint candidateIndex);
    event VotingStarted();
    event VotingEnded();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier votingIsActive() {
        require(votingActive, "Voting is not active.");
        _;
    }

    modifier votingIsNotActive() {
        require(!votingActive, "Voting is already active.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Admin adds candidates
    function addCandidate(string memory name) public onlyAdmin votingIsNotActive {
        candidates.push(Candidate(name, 0));
    }

    // Admin registers voters
    function registerVoter(address voter) public onlyAdmin votingIsNotActive {
        require(!voters[voter].registered, "Voter is already registered.");
        voters[voter] = Voter(true, false);
        emit VoterRegistered(voter);
    }

    // Start voting
    function startVoting() public onlyAdmin votingIsNotActive {
        votingActive = true;
        emit VotingStarted();
    }

    // End voting
    function endVoting() public onlyAdmin votingIsActive {
        votingActive = false;
        emit VotingEnded();
    }

    // Voters cast their vote
    function vote(uint candidateIndex) public votingIsActive {
        require(voters[msg.sender].registered, "You are not registered to vote.");
        require(!voters[msg.sender].voted, "You have already voted.");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        voters[msg.sender].voted = true;
        candidates[candidateIndex].voteCount += 1;
        
        emit VoteCast(msg.sender, candidateIndex);
    }

    // Get the total number of candidates
    function getCandidatesCount() public view returns (uint) {
        return candidates.length;
    }

    // Get a candidate's details
    function getCandidate(uint index) public view returns (string memory, uint) {
        require(index < candidates.length, "Invalid candidate index.");
        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.voteCount);
    }

    // Get the winner(s) of the election
    function getWinner() public view returns (string memory) {
        require(!votingActive, "Voting is still active.");
        
        uint maxVotes = 0;
        uint winnerIndex = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        return candidates[winnerIndex].name;
    }
}

