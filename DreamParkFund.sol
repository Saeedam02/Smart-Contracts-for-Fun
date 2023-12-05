// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DreamParkFund {
    address public owner;
    uint public deadline;
    uint public goal;
    uint public raisedAmount = 0;
    uint public currentPhase = 1;
    uint public constant PHASE_AMOUNT = 25000; // $25,000 per phase
    mapping(address => uint) public contributions;
    mapping(uint => bool) public phaseFunded;

    // Defining a structure for voting
    struct Vote {
        bool exists;
        uint upVotes;
        uint downVotes;
        mapping(address => bool) voted;
    }

    mapping(uint => Vote) public votes;

    // Events
    event ContributionReceived(address contributor, uint amount);
    event PhaseFunded(uint phase);
    event FundsReleased(uint amount);
    event RefundIssued(address contributor, uint amount);
    event VoteInitiated(uint voteId);
    event Voted(address voter, uint voteId, bool vote);

    constructor(uint _duration, uint _goal) {
        owner = msg.sender;
        deadline = block.timestamp + _duration;
        goal = _goal;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Funding period has ended");
        require(raisedAmount < goal, "Goal has been reached");
        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit ContributionReceived(msg.sender, msg.value);

        // Check if current phase is funded
        if(raisedAmount >= currentPhase * PHASE_AMOUNT) {
            phaseFunded[currentPhase] = true;
            emit PhaseFunded(currentPhase);
            currentPhase++;
        }
    }

    function releaseFunds() public {
        require(msg.sender == owner, "Only owner can release funds");
        require(raisedAmount >= goal, "Funding goal not reached");
        payable(owner).transfer(raisedAmount);
        emit FundsReleased(raisedAmount);
    }

    function initiateVote(uint voteId) public {
        require(msg.sender == owner, "Only owner can initiate vote");
        Vote storage newVote = votes[voteId];
        newVote.exists = true;
        emit VoteInitiated(voteId);
    }

    function vote(uint voteId, bool upVote) public {
        require(votes[voteId].exists, "Vote does not exist");
        require(!votes[voteId].voted[msg.sender], "Already voted");
        votes[voteId].voted[msg.sender] = true;

        if(upVote) {
            votes[voteId].upVotes++;
        } else {
            votes[voteId].downVotes++;
        }

        emit Voted(msg.sender, voteId, upVote);
    }

    function refund() public {
        require(block.timestamp > deadline && raisedAmount < goal, "Refunds not applicable");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contributions found");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RefundIssued(msg.sender, amount);
    }

    // Additional functions for handling rewards, progress tracking, etc., can be added here.

    // Fallback function to accept ETH
    receive() external payable {
        contribute();
    }
}
