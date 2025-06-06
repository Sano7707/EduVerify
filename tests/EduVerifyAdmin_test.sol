// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/EduVerifyAdmin.sol";
import "./GovernorHelper.sol";

contract EduVerifyAdminTest {
    EduVerifyAdmin admin;
    address eduVerifyAddr = address(0x123);

    GovernorHelper helper1;
    GovernorHelper helper2;
    GovernorHelper helper3;

    address newGovernor = address(0x4);
    address institution = address(0x5);
    address nonGovernor = address(0x6);

    address[] initialGovernors;

    function beforeAll() public {
        helper1 = new GovernorHelper();
        helper2 = new GovernorHelper();
        helper3 = new GovernorHelper();

        initialGovernors.push(address(helper1));
        initialGovernors.push(address(helper2));
        initialGovernors.push(address(helper3));

        admin = new EduVerifyAdmin(initialGovernors, eduVerifyAddr);
    }


    function testInitialSetup() public {
        Assert.equal(admin.governorCount(), 3, "Initial governor count should be 3");
        Assert.ok(admin.isGovernor(address(helper1)), "Helper1 must be a governor");
        Assert.ok(!admin.isGovernor(nonGovernor), "Random address should not be a governor");
    }

    function testProposalCreation() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 0, "First proposal ID should be 0");
        Assert.equal(admin.proposalCount(), 1, "Now proposalCount() == 1");
    }

    function testNonGovernorCannotPropose() public {
        (bool ok, ) = address(admin).call(
            abi.encodeWithSignature(
                "propose(uint8,address)",
                uint8(EduVerifyAdmin.Action.AddInstitution),
                institution
            )
        );
        Assert.ok(!ok, "A non governor must not be able to propose()");
    }

    function testVoting() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 1, "This should be proposal #1");

        bool success1 = helper1.vote(admin, 1);
        Assert.ok(success1, "helper1 must be able to vote");
        Assert.ok(admin.hasVoted(1, address(helper1)), "helper1 should be marked as voted");

        bool success2 = helper2.vote(admin, 1);
        Assert.ok(success2, "helper2 must be able to vote");

        bool success2_again = helper2.vote(admin, 1);
        Assert.ok(!success2_again, "helper2 must not be able to vote twice");
    }

    function testThresholdCalculation() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 2, "This should be proposal #2");

        helper1.vote(admin, 2);
        helper2.vote(admin, 2);

        (
            , 
            , 
            uint256 yesVotes, 
            uint256 snapshotCount, 
            
        ) = admin.getProposalDetails(2);

        uint256 threshold = admin.getThresholdForProposal(2);
        Assert.equal(threshold, (snapshotCount / 2) + 1, "Threshold is 50% + 1");
        Assert.equal(yesVotes, 2, "There should be exactly 2 yes votes now");
    }

    function testProposalExecution() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 3, "This should be proposal #3");

        helper1.vote(admin, 3);
        helper2.vote(admin, 3);
        helper3.vote(admin, 3);

        bool executedOK = helper1.executeProposal(admin, 3);
        Assert.ok(executedOK, "helper1.executeProposal(3) must succeed");

        (, , , , bool executedFlag) = admin.getProposalDetails(3);
        Assert.ok(executedFlag, "Proposal #3s `executed` flag should be true");
    }

    function testInsufficientVotesExecution() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddInstitution,
            institution
        );
        Assert.equal(pid, 4, "This should be proposal #4");

        helper1.vote(admin, 4);

        bool execOK = helper1.executeProposal(admin, 4);
        Assert.ok(!execOK, "Should not execute #4 with only 1 vote (threshold = 2)");
    }


    function testAddGovernor() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            newGovernor
        );
        Assert.equal(pid, 5, "This should be proposal #5");

        helper1.vote(admin, 5);
        helper2.vote(admin, 5);
        helper3.vote(admin, 5);

        bool ok = helper1.executeProposal(admin, 5);
        Assert.ok(ok, "helper1.executeProposal(5) must succeed");

        Assert.equal(admin.governorCount(), 4, "Now there should be 4 governors");
        Assert.ok(admin.isGovernor(newGovernor), "newGovernor must be in the governor list");
    }

    function testAddExistingGovernor() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.AddGovernor,
            newGovernor
        );
        Assert.equal(pid, 6, "This is proposal #6");

        helper1.vote(admin, 6);
        helper2.vote(admin, 6);
        helper3.vote(admin, 6);

        bool execOK = helper1.executeProposal(admin, 6);
        Assert.ok(!execOK, "Should not add an already existing governor");
    }

    function testRemoveGovernor() public {
        uint256 pid = helper1.propose(
            admin,
            EduVerifyAdmin.Action.RevokeGovernor,
            address(helper1)
        );
        Assert.equal(pid, 7, "This is proposal #7");

        helper1.vote(admin, 7);
        helper2.vote(admin, 7);
        helper3.vote(admin, 7);

        bool execOK = helper1.executeProposal(admin, 7);
        Assert.ok(execOK, "helper1.executeProposal(7) must succeed");

        Assert.equal(admin.governorCount(), 3, "We still have 3 governors total");
        Assert.ok(!admin.isGovernor(address(helper1)), "helper1 was removed");
    }


    function testVoteOnInvalidProposal() public {
        bool ok = helper1.vote(admin, 999);
        Assert.ok(!ok, "Should not be able to vote on a non existent proposal");
    }

    function testGetInvalidProposal() public {
        (bool ok, ) = address(admin).call(
            abi.encodeWithSignature("getProposalDetails(uint256)", 999)
        );
        Assert.ok(!ok, "getProposalDetails(999) must revert via low level call");
    }
}
