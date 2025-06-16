// SPDX-License-Identifier: UniTrento
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/EduVerify.sol";
import "../contracts/EduVerifyAdmin.sol";

contract EduVerifyTest {
    EduVerify eduVerify;
    EduVerifyAdmin admin;
    
    address authorizedInstitution1 = address(0x1);
    address authorizedInstitution2 = address(0x2);
    address student = address(0x3);
    address unauthorizedInstitution = address(0x4);
    
    string credentialId1 = "111";
    string credentialId2 = "222";
    string cid1 = "QmABC111";
    string cid2 = "QmABC222";
    
    uint nextProposalId = 0;

    function beforeAll() public {
        address[] memory initialGovernors = new address[](1);
        initialGovernors[0] = address(this);
        admin = new EduVerifyAdmin(initialGovernors, address(0));
        
        eduVerify = new EduVerify(address(admin));
        admin.setEduVerifyAddress(address(eduVerify));
        
        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, authorizedInstitution1);
        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, authorizedInstitution2);
        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, address(this));
    }
    
    function _createAndExecuteProposal(EduVerifyAdmin.Action action, address target) private {
        uint proposalId = admin.propose(action, target);
        admin.vote(proposalId);
        admin.executeProposal(proposalId);
        nextProposalId++;
    }
    
    function testAuthorizeInstitution() public {
        Assert.ok(eduVerify.authorizedInstitutions(authorizedInstitution1), "Institution1 should be authorized");
        Assert.ok(eduVerify.authorizedInstitutions(authorizedInstitution2), "Institution2 should be authorized");
        Assert.ok(!eduVerify.authorizedInstitutions(unauthorizedInstitution), "Unauthorized should not be authorized");
    }
    
    function testRevokeInstitution() public {
        _createAndExecuteProposal(EduVerifyAdmin.Action.RevokeInstitution, authorizedInstitution1);
        Assert.ok(!eduVerify.authorizedInstitutions(authorizedInstitution1), "Institution1 should be revoked");
                _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, authorizedInstitution1);
    }
    
    function testIssueCredential() public {
        eduVerify.issueCredential(
            credentialId1,
            "Alice",
            student,
            "UniTrento",
            "BSc CS",
            cid1
        );
        
        EduVerify.Credential memory cred = eduVerify.getCredential(address(this), credentialId1);
        Assert.equal(cred.studentName, "Alice", "Student name should match");
        Assert.equal(cred.degree, "BSc CS", "Degree should match");
        Assert.equal(cred.cid, cid1, "CID should match");
    }
    
    function testIssueDuplicateCredential() public {
        try eduVerify.issueCredential(
            credentialId1, 
            "Francesco",
            student,
            "UniTrento",
            "Masters",
            cid2
        ) {
            Assert.ok(false, "Duplicate credential ID should fail");
        } catch {
            Assert.ok(true, "Duplicate credential ID failed as expected");
        }
    }
    
    function testUnauthorizedIssuance() public {
        _createAndExecuteProposal(EduVerifyAdmin.Action.RevokeInstitution, address(this));
        
        try eduVerify.issueCredential(
            credentialId2,
            "Alessandra",
            student,
            "UniTrento",
            "PhD",
            cid2
        ) {
            Assert.ok(false, "Unauthorized issuance should fail");
        } catch {
            Assert.ok(true, "Unauthorized issuance failed as expected");
        }

        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, address(this));
    }
    
    function testStudentCredentials() public {
        EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(student);
        
        Assert.equal(creds.length, 1, "Student should have 1 credential");
        Assert.equal(creds[0].studentName, "Alice", "Student name should match");
        Assert.equal(creds[0].degree, "BSc CS", "Degree should match");
    }
    
    function testInstitutionCredentials() public {
        string memory testCredId = "333";
        string memory testCid = "Qm333";
        
        eduVerify.issueCredential(
            testCredId,
            "Mario",
            student,
            "UniTrento",
            "Test Degree",
            testCid
        );
        
        EduVerify.Credential memory cred = eduVerify.getCredentialByCID(testCid);
        Assert.equal(cred.studentName, "Mario", "Student name should match");
        Assert.equal(cred.degree, "Test Degree", "Degree should match");
    }
}