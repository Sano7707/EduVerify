// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../new-contracts/EduVerifyAdmin.sol";
import "../new-contracts/EduVerify.sol";
import "./Governor.sol";


contract EduVerifyAdminTest {
    
    EduVerifyAdmin admin;
    EduVerify eduVerify;

    Governor governor1;
    Governor governor2;
    Governor governor3;

    Governor candidateGovernor;

    address institution = address(0x6);
    address nonGovernor = address(0x7);

    address[] initialGovernors;

    function beforeAll() public {
        governor1 = new Governor();
        governor2 = new Governor();
        governor3 = new Governor();
        candidateGovernor = new Governor();

        initialGovernors.push(address(governor1));
        initialGovernors.push(address(governor2));
        initialGovernors.push(address(governor3));

        admin = new EduVerifyAdmin(initialGovernors);
        eduVerify = new EduVerify(address(admin));
        governor1.setEduVerify(admin, address(eduVerify));
    }

    function testInitialSetup() public {
        Assert.equal(admin.governorCount(), 3, "Initial governor count need to be 3");
        Assert.ok(admin.isGovernor(address(governor1)), "governor1 must be a governor");
        Assert.ok(!admin.isGovernor(nonGovernor), "Random address (non governor) should not be a governor");
        Assert.equal(admin.eduVerify(), address(eduVerify), "EduVerify address need to be the same");
        Assert.equal(admin.proposalCount(), 0, "Initial proposal count need to be 0");
    }

    function testChangeEduVerifyAddress() public {
        (bool success, ) = address(admin).call(
            abi.encodeWithSignature(
                "setEduVerifyAddress(address)",
                address(0x00)
            )
        );
        Assert.ok(!success, "Only governor must set EduVerifyAddress!");
        bool result = governor1.setEduVerify(admin, address(0x00));
        Assert.ok(!result, "EduVerifyAddress cannot be changed once set!");
    }

    function testProposalCreation() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 0, "First proposal ID need to be 0");
        Assert.equal(admin.proposalCount(), 1, "Number of proposals need to be 1");
        (EduVerifyAdmin.Action action, address target, uint yesVotes, uint snapshotGovernorCount, bool executed) = admin.getProposalDetails(0);
        Assert.equal(yesVotes, 0, "Number of yes votes of proposal at the beginning needs to be 0");
        Assert.equal(target, institution, "Target must match");
        Assert.equal(snapshotGovernorCount, 3, "Actual number of governors must match");
        Assert.equal(executed, false, "Proposal must not be executed yet");
        Assert.ok(action == EduVerifyAdmin.Action.AddInstitution, "Action must be remained immutate");
    }

    function testNonGovernorCannotPropose() public {
        (bool success, ) = address(admin).call(
            abi.encodeWithSignature(
                "proposeTest(uint8,address)",
                uint8(EduVerifyAdmin.Action.AddInstitution),
                institution
            )
        );
        Assert.ok(!success, "A non governor must not be able to make a proposal");
        
        (success, ) = address(candidateGovernor).call(
            abi.encodeWithSignature(
                "proposeTest(uint8,address)",
                uint8(EduVerifyAdmin.Action.AddGovernor),
                address(candidateGovernor)
            )
        );
        Assert.ok(!success, "A non governor must not be able to make a proposal");
    }

    function testVoting() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 1, "This should be proposal 1");

        bool successfulVote1 = governor1.voteTest(admin, 1);
        Assert.ok(successfulVote1, "Governor1 must be able to vote");
        Assert.ok(admin.hasVoted(1, address(governor1)), "Now Governor1 need to be marked as voted");
        (EduVerifyAdmin.Action action, address target, uint yesVotes, uint snapshotGovernorCount, bool executed) = admin.getProposalDetails(1);
        Assert.equal(yesVotes, 1, "Number of yes votes of proposal must be 1");
        Assert.equal(executed, false, "Proposal must not be executed yet");

        bool successfulVote2 = governor2.voteTest(admin, 1);
        Assert.ok(successfulVote2, "Governor2 also must be able to vote");
        Assert.ok(admin.hasVoted(1, address(governor2)), "Now Governor2 need to be marked as voted");
        (action, target, yesVotes, snapshotGovernorCount, executed) = admin.getProposalDetails(1);
        Assert.equal(yesVotes, 2, "Number of yes votes of proposal must be 2");
        Assert.equal(executed, false, "Proposal must not be executed yet");
    }

    function testDoubleVoting() public {
        bool successfulVote2_again = governor2.voteTest(admin, 1);
        Assert.ok(!successfulVote2_again, "Governor2 must not be able to vote twice");
        (EduVerifyAdmin.Action action, address target, uint yesVotes, uint snapshotGovernorCount, bool executed) = admin.getProposalDetails(1);
        Assert.equal(yesVotes, 2, "Number of yes votes of proposal must be remained 2");
       Assert.equal(executed, false, "Proposal must not be executed yet");
    }

    function testVoteOnInvalidProposal() public {
        bool success = governor1.voteTest(admin, 999);
        Assert.ok(!success, "Should not be able to vote on a non existent proposal");
    }

    function testProposalExecution() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 2, "This should be proposal 2");

        governor1.voteTest(admin, 2);
        governor2.voteTest(admin, 2);
        governor3.voteTest(admin, 2);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 2);
        Assert.ok(isExecutedSuccessfull, "Governor1 must be able to execute after reaching threshold.");

        (, , , , bool executedFlag) = admin.getProposalDetails(2);
        Assert.ok(executedFlag, "Proposal 3's executed flag should be set to true");
    }

    function testProposalReExecution() public {
        bool isExecutedSuccessfull = governor1.executeProposal(admin, 1);
        Assert.ok(isExecutedSuccessfull, "Governor1 must be able to execute the proposal at first time.");

        isExecutedSuccessfull = governor1.executeProposal(admin, 1);
        Assert.ok(!isExecutedSuccessfull, "Governor1 must NOT be able to execute again the proposal.");

        (EduVerifyAdmin.Action action, address target, uint yesVotes, uint snapshotGovernorCount, bool executed) = admin.getProposalDetails(0);
        Assert.ok(!isExecutedSuccessfull, "Governor1 must NOT be able to execute again the proposal.");
        Assert.lesserThan(yesVotes, snapshotGovernorCount / 2 + 1, "Number of yes votes must be lower than quorum");
    }

    function testInsufficientVotesExecution() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 3, "This should be proposal 3");

        governor1.voteTest(admin, 3);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 3);
        Assert.ok(!isExecutedSuccessfull, "Should not execute proposal 3 with only 1 vote (threshold has not been reached)");
    }

    function testNonGovernorVoting() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.RevokeGovernor,
            address(governor3)
        );
        Assert.equal(pid, 4, "This should be proposal 4");

        candidateGovernor.voteTest(admin, 4);

        bool isExecutedSuccessfull = candidateGovernor.voteTest(admin, 4);
        Assert.ok(!isExecutedSuccessfull, "CandidateGovernor must not be able to vote!");

        (EduVerifyAdmin.Action action, address target, uint yesVotes, uint snapshotGovernorCount, bool executed) = admin.getProposalDetails(4);
        Assert.equal(yesVotes, 0, "Number of yes votes of proposal must be remained 0");
        Assert.equal(executed, false, "Proposal must not be executed yet");
    }

    function testHistoricalProposals() public {
        Assert.equal(admin.proposalCount(), 5, "Number of proposals must be 5, including also old proposals");
    }

    function testGetInvalidProposal() public {
        (bool success, ) = address(admin).call(abi.encodeWithSignature("getProposalDetails(uint256)", 999));
        Assert.ok(!success, "We must not be able to get an invalid proposal with invalid id.");
    }

    function testAddGovernor() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            address(candidateGovernor)
        );
        Assert.equal(pid, 5, "This should be proposal 5");

        governor1.voteTest(admin, 5);
        governor2.voteTest(admin, 5);
        governor3.voteTest(admin, 5);

        bool isExecutedSuccessfull = governor2.executeProposal(admin, 5);
        Assert.ok(isExecutedSuccessfull, "Governer1 neet to be able to add new governer as threshold is reached.");

        Assert.equal(admin.governorCount(), 4, "Now there should be 4 governors");
        Assert.ok(admin.isGovernor(address(candidateGovernor)), "CandidateGovernor need to be in the governor list");

        Assert.equal(admin.calculateThreshold(), 3, "Threshold is increased to 3");
    }

   function testAddExistingGovernor() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            address(candidateGovernor)
        );
        Assert.equal(pid, 6, "This should be proposal 6");

        governor1.voteTest(admin, 6);
        governor2.voteTest(admin, 6);
        governor3.voteTest(admin, 6);

        Assert.equal(admin.getThresholdForProposal(6), (admin.governorCount() / 2) + 1, "Now threshold must be 3");


        bool isExecutedSuccessfull = governor2.executeProposal(admin, 6);
        Assert.ok(!isExecutedSuccessfull, "CandidateGovernor is already in the governor list.");

        Assert.equal(admin.governorCount(), 4, "Now there should be still 4 governors");
    }
  
   function testThresholdCalculation() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 7, "This should be proposal 7");
        Assert.equal(admin.getThresholdForProposal(7), (admin.governorCount() / 2) + 1, "Now threshold must be 3");

        governor1.voteTest(admin, 7);
        governor2.voteTest(admin, 7);

        (
            , 
            , 
            uint256 yesVotes, 
            uint256 snapshotCount, 
            
        ) = admin.getProposalDetails(7);

        uint256 threshold = admin.getThresholdForProposal(7);
        Assert.equal(threshold, (snapshotCount / 2) + 1, "Threshold need to follow the 51% rule");
        Assert.equal(yesVotes, 2, "There should be exactly 2 yes votes now");
    }

    function testRemoveGovernor() public {
        uint256 pid = candidateGovernor.proposeTest(
            admin,
            EduVerifyAdmin.Action.RevokeGovernor,
            address(governor1)
        );
        Assert.equal(pid, 8, "This is proposal 8");

        candidateGovernor.voteTest(admin, 8);
        governor2.voteTest(admin, 8);
        governor3.voteTest(admin, 8);
        Assert.ok(admin.hasVoted(8, address(governor2)), "Now Governor2 need to be marked as voted");

        bool isExecutedSuccessfull = candidateGovernor.executeProposal(admin, 8);
        Assert.ok(isExecutedSuccessfull, "Governer1 must be removed.");

        Assert.equal(admin.governorCount(), 3, "We still have 3 governors total");
        Assert.ok(!admin.isGovernor(address(governor1)), "governor1 was removed");
        Assert.equal(admin.calculateThreshold(), 2, "Threshold is decreased to 2");
    }

    function testAddInstitution() public {
        uint256 pid = candidateGovernor.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            address(governor1)
        );
        Assert.equal(pid, 9, "This is proposal 9");

        candidateGovernor.voteTest(admin, 9);
        governor2.voteTest(admin, 9);
        governor3.voteTest(admin, 9);
        Assert.ok(admin.hasVoted(9, address(governor2)), "Now Governor2 need to be marked as voted");

        bool isExecutedSuccessfull = governor3.executeProposal(admin, 9);
        Assert.ok(isExecutedSuccessfull, "Call executed properly");
        Assert.ok(eduVerify.authorizedInstitutions(address(governor1)), "governor1 is an institution");
    }

    function testRevokeInstitution() public {
        uint256 pid = candidateGovernor.proposeTest(
            admin,
            EduVerifyAdmin.Action.RevokeInstitution,
            address(governor1)
        );
        Assert.equal(pid, 10, "This is proposal 10");

        candidateGovernor.voteTest(admin, 10);
        governor2.voteTest(admin, 10);
        governor3.voteTest(admin, 10);
        Assert.ok(admin.hasVoted(10, address(governor2)), "Now Governor2 need to be marked as voted");

        bool isExecutedSuccessfull = candidateGovernor.executeProposal(admin, 10);
        Assert.ok(isExecutedSuccessfull, "Call executed properly");
        Assert.ok(!eduVerify.authorizedInstitutions(address(governor1)), "governor1 is not an institution");
    }

    function testRemoveNonExistingGovernor() public {
        Assert.ok(!admin.isGovernor(address(governor1)), "governor1 is not included removed");
        uint256 pid = candidateGovernor.proposeTest(
            admin,
            EduVerifyAdmin.Action.RevokeGovernor,
            address(governor1)
        );
        Assert.equal(pid, 11, "This is proposal 11");

        candidateGovernor.voteTest(admin, 11);
        governor2.voteTest(admin, 11);
        governor3.voteTest(admin, 11);
        Assert.ok(admin.hasVoted(11, address(governor2)), "Now Governor2 need to be marked as voted");

        bool isExecutedSuccessfull = candidateGovernor.executeProposal(admin, 8);
        Assert.ok(!isExecutedSuccessfull, "Governer1 must not be removed, since it's not a governor.");
    }

    
    

}
