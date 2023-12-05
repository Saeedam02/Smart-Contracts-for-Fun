// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Contract for a Crowdfunding Platform
contract Crowdfunding {
    // The structure to store project details
    struct Project {
        string title; // Title of the project
        address payable owner; // Owner of the project
        uint goalAmount; // Funding goal in wei (1 ether = 10^18 wei)
        uint currentAmount; // Current amount raised
        bool funded; // Flag to check if the project is funded
    }

    // Mapping of project IDs to their details
    mapping(uint => Project) public projects;
    uint public projectCount;

    // Event to emit when a project is created
    event ProjectCreated(
        uint projectId,
        string title,
        uint goalAmount
    );

    // Event to emit when a project receives funding
    event ProjectFunded(
        uint projectId,
        uint amount,
        uint currentAmount
    );

    // Create a new project
    function createProject(string memory _title, uint _goalAmount) public {
        projectCount++; // Increment project count
        projects[projectCount] = Project(_title, payable(msg.sender), _goalAmount, 0, false);
        emit ProjectCreated(projectCount, _title, _goalAmount);
    }

    // Function to fund a project
    function fundProject(uint _projectId) public payable {
        Project storage project = projects[_projectId];
        require(msg.value > 0, "Funding amount must be greater than 0");
        require(!project.funded, "Project is already funded");
        
        project.currentAmount += msg.value; // Increment the current amount
        emit ProjectFunded(_projectId, msg.value, project.currentAmount);

        // Check if the funding goal is reached
        if (project.currentAmount >= project.goalAmount) {
            project.funded = true;
            project.owner.transfer(project.currentAmount); // Transfer funds to the project owner
        }
    }

    // Function to get project details
    function getProject(uint _projectId) public view returns (string memory, uint, uint, bool) {
        Project memory project = projects[_projectId];
        return (project.title, project.goalAmount, project.currentAmount, project.funded);
    }
}
