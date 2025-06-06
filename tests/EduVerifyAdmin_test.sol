// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/EduVerifyAdmin.sol";

import "./Governor.sol";

contract EduVerifyAdminTest {
    
    EduVerifyAdmin admin;
    address eduVerifyAddr = address(0x1); 

    Governor governor1;
    Governor governor2;
    Governor governor3;

    address newGovernor = address(0x5);
    address institution = address(0x6);
    address nonGovernor = address(0x7);

    address[] initialGovernors;

    function beforeAll() public {
        governor1 = new Governor();
        governor2 = new Governor();
        governor3 = new Governor();

        initialGovernors.push(address(governor1));
        initialGovernors.push(address(governor2));
        initialGovernors.push(address(governor3));

        admin = new EduVerifyAdmin(initialGovernors, eduVerifyAddr);
    }


    function testInitialSetup() public {
        Assert.equal(admin.governorCount(), 3, "Initial governor count need to be 3");
        Assert.ok(admin.isGovernor(address(governor1)), "governor1 must be a governor");
        Assert.ok(!admin.isGovernor(nonGovernor), "Random address (non governor) should not be a governor");
    }

    function testProposalCreation() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 0, "First proposal ID need to be 0");
        Assert.equal(admin.proposalCount(), 1, "Number of proposals need to be 1");
    }

    function testNonGovernorCannotpropose() public {
        (bool success, ) = address(admin).call(
            abi.encodeWithSignature(
                "proposeTest(uint8,address)",
                uint8(EduVerifyAdmin.Action.AddInstitution),
                institution
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

        bool successfulVote2 = governor2.voteTest(admin, 1);
        Assert.ok(successfulVote2, "Governor2 also must be able to vote");

        bool successfulVote2_again = governor2.voteTest(admin, 1);
        Assert.ok(!successfulVote2_again, "Governor2 must not be able to vote twice");
    }

    function testThresholdCalculation() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 2, "This should be proposal 2");

        governor1.voteTest(admin, 2);
        governor2.voteTest(admin, 2);

        (
            , 
            , 
            uint256 yesVotes, 
            uint256 snapshotCount, 
            
        ) = admin.getProposalDetails(2);

        uint256 threshold = admin.getThresholdForProposal(2);
        Assert.equal(threshold, (snapshotCount / 2) + 1, "Threshold need to follow the 51% rule");
        Assert.equal(yesVotes, 2, "There should be exactly 2 yes votes now");
    }

    function testProposalExecution() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 3, "This should be proposal 3");

        governor1.voteTest(admin, 3);
        governor2.voteTest(admin, 3);
        governor3.voteTest(admin, 3);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 3);
        Assert.ok(isExecutedSuccessfull, "Governor1 must be able to execute after reaching threshold.");

        (, , , , bool executedFlag) = admin.getProposalDetails(3);
        Assert.ok(executedFlag, "Proposal 3's executed flag should be set to true");
    }

    function testInsufficientVotesExecution() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 4, "This should be proposal 4");

        governor1.voteTest(admin, 4);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 4);
        Assert.ok(!isExecutedSuccessfull, "Should not execute 4 with only 1 vote (threshold has not been reached)");
    }


    function testAddGovernor() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            newGovernor
        );
        Assert.equal(pid, 5, "This should be proposal 5");

        governor1.voteTest(admin, 5);
        governor2.voteTest(admin, 5);
        governor3.voteTest(admin, 5);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 5);
        Assert.ok(isExecutedSuccessfull, "Governer1 neet to be able to add new governer as threshold is reached.");

        Assert.equal(admin.governorCount(), 4, "Now there should be 4 governors");
        Assert.ok(admin.isGovernor(newGovernor), "NewGovernor need to be in the governor list");
    }

    function testAddExistingGovernor() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            newGovernor
        );
        Assert.equal(pid, 6, "This is proposal 6");

        governor1.voteTest(admin, 6);
        governor2.voteTest(admin, 6);
        governor3.voteTest(admin, 6);

        bool isExecutedSuccessfull = governor1.executeProposal(admin, 6);
        Assert.ok(!isExecutedSuccessfull, "Should not add an already existing governor");
    }

    function testRemoveGovernor() public {
        uint256 pid = governor1.proposeTest(
            admin,
            EduVerifyAdmin.Action.RevokeGovernor,
            address(governor1)
        );
        Assert.equal(pid, 7, "This is proposal #7");

        governor1.voteTest(admin, 7);
        governor2.voteTest(admin, 7);
        governor3.voteTest(admin, 7);


        bool isExecutedSuccessfull = governor2.executeProposal(admin, 7);
        Assert.ok(isExecutedSuccessfull, "Governer1 must be removed.");

        Assert.equal(admin.governorCount(), 3, "We still have 3 governors total");
        Assert.ok(!admin.isGovernor(address(governor1)), "governor1 was removed");
    }


    function testVoteOnInvalidProposal() public {
        bool success = governor1.voteTest(admin, 999);
        Assert.ok(!success, "Should not be able to vote on a non existent proposal");
    }

    function testGetInvalidProposal() public {
        (bool success, ) = address(admin).call(abi.encodeWithSignature("getProposalDetails(uint256)", 999));
        Assert.ok(!success, "We must not be able to get an invalid proposal with invalid id.");
    }
}
