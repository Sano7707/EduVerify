// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EduVerifyAdmin {
    
    using ECDSA for bytes32;
    enum Action { AddInstitution, RevokeInstitution, AddGovernor, RevokeGovernor }

    /*
        Three governers at the start, on which we have initial trust.

        Each of them can use a proposal: authorize or revoke institutions; add another governer or remove the governer.    
    */
    
    struct Proposal {
        uint256 id;
        Action action;
        address target;
        uint256 yesVotes;
        uint256 snapshotGovernorCount;  //number of governers
        bool executed;                  //quorum is reached
        mapping(address => bool) hasVoted;
    }
    
    mapping(address => bool) public isGovernor;
    uint public totalGovernors;
    address public eduVerify; //address of other SC
    
    Proposal[] public proposals;
    
    event ProposalCreated(uint256 indexed proposalId, Action action, address target);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event ProposalExecuted(uint256 indexed proposalId);
    event GovernorAdded(address indexed governor);
    event GovernorRemoved(address indexed governor);
    
    modifier onlyGovernor() {
        require(isGovernor[msg.sender], "Not a governor");
        _;
    }
    
    constructor(address[] memory _initialGovernors, address _eduVerify) {
        totalGovernors = _initialGovernors.length;
        eduVerify = _eduVerify;

        uint length = _initialGovernors.length;
        for (uint i = 0; i < length;) {
            address governor = _initialGovernors[i];
            require(governor != address(0), "Invalid governor");
            require(!isGovernor[governor], "Duplicate governor");
            isGovernor[governor] = true;

            unchecked{ ++i; }
        }
    }
    
    function calculateThreshold() public view returns(uint) {
        return (totalGovernors / 2) + 1;
    }
    
    function propose(Action action, address target) external onlyGovernor returns(uint) {
        uint proposalId = proposals.length;
        Proposal storage newProposal = proposals.push();
        newProposal.id = proposalId;
        newProposal.action = action;
        newProposal.target = target;
        newProposal.yesVotes = 0;
        newProposal.snapshotGovernorCount = totalGovernors;
        newProposal.executed = false;
        
        emit ProposalCreated(proposalId, action, target);
        return proposalId;
    }

    function vote(uint proposalId) external onlyGovernor {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.hasVoted[msg.sender], "Governor already voted");
        require(!proposal.executed, "Proposal already executed");
        
        proposal.hasVoted[msg.sender] = true;
        proposal.yesVotes+=1;
        emit VoteCast(proposalId, msg.sender);
    }
    
    function executeProposal(uint proposalId) external onlyGovernor {
        Proposal storage proposal = proposals[proposalId];
        uint requiredThreshold = (proposal.snapshotGovernorCount / 2) + 1;
        
        require(proposal.yesVotes >= requiredThreshold, "Insufficient votes to execute proposal");
        require(!proposal.executed, "Proposal already executed");
        
        if(proposal.action == Action.AddInstitution) {
            (bool success, ) = eduVerify.call(abi.encodeWithSignature("authorizeInstitution(address)", proposal.target));
            require(success, "Authorization failed");
        }
        else if(proposal.action == Action.RevokeInstitution) {
            (bool success, ) = eduVerify.call(abi.encodeWithSignature("revokeInstitution(address)", proposal.target));
            require(success, "Revocation failed");
        }
        else if(proposal.action == Action.AddGovernor) {
            require(!isGovernor[proposal.target], "Target is already a governor");
            isGovernor[proposal.target] = true;
            totalGovernors++;
            emit GovernorAdded(proposal.target);
        }
        else if(proposal.action == Action.RevokeGovernor) {
            require(isGovernor[proposal.target], "Not a governor");
            require(totalGovernors >= 2, "Two governors cannot remove each other");
            isGovernor[proposal.target] = false;
            totalGovernors--;
            emit GovernorRemoved(proposal.target);
        }
        
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
    
    function getProposalDetails(uint proposalId) public view returns( Action action, address target, uint yesVotes, uint snapshotGovernorCount,  bool executed) {
        Proposal storage p = proposals[proposalId];
        return (p.action, p.target, p.yesVotes, p.snapshotGovernorCount, p.executed);
    }
    
    function getThresholdForProposal(uint proposalId) public view returns(uint) {
        Proposal storage p = proposals[proposalId];
        return (p.snapshotGovernorCount / 2) + 1;
    }
    
    function hasVoted(uint proposalId, address governor) public view returns(bool) {
        return proposals[proposalId].hasVoted[governor];
    }
    
    function proposalCount() public view returns(uint) {
        return proposals.length;
    }
    
    function governorCount() public view returns(uint) {
        return totalGovernors;
    }

    function setEduVerifyAddress(address _eduVerify) external onlyGovernor {
        require(eduVerify == address(0), "Address already set");
        eduVerify = _eduVerify;
    }
}