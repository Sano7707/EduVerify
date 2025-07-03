// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EduVerifyAdmin {
    
    using ECDSA for bytes32;
    
    enum Action { AddInstitution, RevokeInstitution, AddGovernor, RevokeGovernor }

    struct Proposal {
        uint256 id;                             //unique identifier of the proposal
        Action action;                          //type of action of the proposal
        address target;                         //address subject of the proposal
        uint256 yesVotes;                       //number of yes votes
        uint256 snapshotGovernorCount;          //number of governors at the moment of the proposal
        bool executed;                          //quorum is reached and proposal is made effective
        mapping(address => bool) hasVoted;      //mapping to identify if a specific governor has voted or not
    }

    /*
        Three governors at the start, on which we have initial trust (Multi-Sig model).
        Each of them can use a proposal for: authorize or revoke institutions; add another governor or remove a governor.    
    */

    //to cheack easier if an addr is a governor without loops
    mapping(address => bool) public isGovernor;
    //to store the governors
    address[] public governors;
    //address of other SC
    address public eduVerify;
    
    //history of all proposals
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
    
    constructor(address[] memory _initialGovernors) {

        uint length = _initialGovernors.length;
        for (uint i = 0; i < length;) {
            address governor = _initialGovernors[i];
            require(governor != address(0), "Invalid governor");
            require(!isGovernor[governor], "Duplicate governor");
            isGovernor[governor] = true;
            governors.push(governor);
            emit GovernorAdded(governor);

            unchecked{ ++i; }
        }
    }

    //we set the address of SC EduVerify once it has been deployed
    function setEduVerifyAddress(address _eduVerify) external onlyGovernor {
        require(eduVerify == address(0), "Address already set");
        eduVerify = _eduVerify;
    }
    
    function calculateThreshold() external view returns(uint) {
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
            address _addr_target = proposal.target;
            require(!isGovernor[_addr_target], "Target is already a governor");
            isGovernor[_addr_target] = true;
            governors.push(_addr_target);
            emit GovernorAdded(_addr_target);
        }
        else if(proposal.action == Action.RevokeGovernor) {
            address _addr_target = proposal.target;
            require(isGovernor[_addr_target], "Not a governor");
            require(governors.length >= 2, "Two governors cannot remove each other");
            isGovernor[_addr_target] = false;

            uint length = governors.length;            
            for (uint i = 0; i < length;) {
                if (governors[i] == _addr_target) {
                    governors[i] = governors[length - 1];
                    governors.pop();
                    break;
                }
                unchecked{ ++i; }
            }
            
            emit GovernorRemoved(proposal.target);
        }
        
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
    
    function getProposalDetails(uint proposalId) external view returns(Action action, address target, uint yesVotes, uint snapshotGovernorCount,  bool executed) {
        Proposal storage p = proposals[proposalId];
        return (p.action, p.target, p.yesVotes, p.snapshotGovernorCount, p.executed);
    }
    
    function getThresholdForProposal(uint proposalId) external view returns(uint) {
        Proposal storage p = proposals[proposalId];
        return (p.snapshotGovernorCount / 2) + 1;
    }
    
    function hasVoted(uint proposalId, address governor) external view returns(bool) {
        return proposals[proposalId].hasVoted[governor];
    }
    
    function proposalCount() external view returns(uint) {
        return proposals.length;
    }
    
    function governorCount() external view returns(uint) {
        return governors.length;
    }

}