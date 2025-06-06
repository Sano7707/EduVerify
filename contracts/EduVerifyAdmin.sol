// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EduVerifyAdmin {
    
     using ECDSA for bytes32;
     enum Action { AddInstitution, RevokeInstitution, AddGovernor, RevokeGovernor } 
    
    struct Proposal {
        uint256 id;
        Action action;
        address target;
        uint256 yesVotes;
        uint256 snapshotGovernorCount;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    
    address[] public governors;
    address public eduVerify;
    
    Proposal[] public proposals;
    
    event ProposalCreated(uint256 indexed proposalId, Action action, address target);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event ProposalExecuted(uint256 indexed proposalId);
    event GovernorAdded(address indexed governor);
    event GovernorRemoved(address indexed governor);
    
    modifier onlyGovernor() {
        require(isGovernor(msg.sender), "Not a governor");
        _;
    }
    
    constructor(address[] memory _initialGovernors, address _eduVerify) {
        governors = _initialGovernors;
        eduVerify = _eduVerify;
    }
    
    function isGovernor(address account) public view returns(bool) {
        for(uint i = 0; i < governors.length; i++) {
            if(governors[i] == account) return true;
        }
        return false;
    }
    
    function calculateThreshold() public view returns(uint) {
        return (governors.length / 2) + 1;
    }
    
  function propose(Action action, address target) external onlyGovernor returns(uint) {
    uint proposalId = proposals.length;
    Proposal storage newProposal = proposals.push();
    newProposal.id = proposalId;
    newProposal.action = action;
    newProposal.target = target;
    newProposal.yesVotes = 0;
    newProposal.snapshotGovernorCount = governors.length;
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
            require(!isGovernor(proposal.target), "Target is already a governor");
            governors.push(proposal.target);
            emit GovernorAdded(proposal.target);
        }
        else if(proposal.action == Action.RevokeGovernor) {
            require(isGovernor(proposal.target), "Not a governor");
            require(governorCount() >= 2, "Two governors cannot remove each other");
            for(uint i = 0; i < governors.length; i++) {
                if(governors[i] == proposal.target) {
                    governors[i] = governors[governors.length-1];
                    governors.pop();
                    emit GovernorRemoved(proposal.target);
                    break;
                }
            }
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
        return governors.length;
    }

   function setEduVerifyAddress(address _eduVerify) external onlyGovernor {
    require(eduVerify == address(0), "Address already set");
    eduVerify = _eduVerify;
}
}