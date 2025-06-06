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

    function beforeAll() public {
        address[] memory initialGovernors = new address[](1);
        initialGovernors[0] = address(this);
        admin = new EduVerifyAdmin(initialGovernors, address(0));
        
        eduVerify = new EduVerify(address(admin));
        admin.setEduVerifyAddress(address(eduVerify));
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, authorizedInstitution1);
        admin.vote(0);
        admin.executeProposal(0);
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, authorizedInstitution2);
        admin.vote(1);
        admin.executeProposal(1);
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, address(this));
        admin.vote(2);
        admin.executeProposal(2);
    }
    
    
    function testAuthorizeInstitution() public {
        Assert.ok(eduVerify.authorizedInstitutions(authorizedInstitution1), "Institution1 should be authorized");
        Assert.ok(eduVerify.authorizedInstitutions(authorizedInstitution2), "Institution2 should be authorized");
        Assert.ok(!eduVerify.authorizedInstitutions(unauthorizedInstitution), "Unauthorized should not be authorized");
    }
    
    function testRevokeInstitution() public {
        admin.propose(EduVerifyAdmin.Action.RevokeInstitution, authorizedInstitution1);
        admin.vote(3);
        admin.executeProposal(3);
        
        Assert.ok(!eduVerify.authorizedInstitutions(authorizedInstitution1), "Institution1 should be revoked");
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
        
        EduVerify.Credential memory cred = eduVerify.getCredential(credentialId1);
        Assert.equal(cred.studentName, "Alice", "Student name should match");
        Assert.equal(cred.degree, "BSc CS", "Student degree should match");
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
            Assert.ok(true, "Duplicate credential ID failed as expected by the program");
        }
    }
    
    function testUnauthorizedIssuance() public {
        admin.propose(EduVerifyAdmin.Action.RevokeInstitution, address(this));
        admin.vote(4);
        admin.executeProposal(4);

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

        admin.propose(EduVerifyAdmin.Action.AddInstitution, address(this));
        admin.vote(5);
        admin.executeProposal(5);
    }
    
    
    function testStudentCredentials() public {
        eduVerify.issueCredential(
            credentialId2,
            "Monica",
            student,
            "UniTrento",
            "MBA",
            cid2
        );
        
        string[] memory creds = eduVerify.getStudentCredentials(student);
        Assert.equal(creds.length, 2, "Student should have 2 credentials");
        
        bool foundFirst = false;
        bool foundSecond = false;

        for(uint i = 0; i < creds.length; i++) {
            if(keccak256(bytes(creds[i])) == keccak256(bytes(credentialId1))) {
                foundFirst = true;
            }
            if(keccak256(bytes(creds[i])) == keccak256(bytes(credentialId2))) {
                foundSecond = true;
            }
        }
        Assert.ok(foundFirst, "First credential need to be present exist");
        Assert.ok(foundSecond, "Second credential need to be present");
    }
    
    function testInstitutionCredentials() public {
        string memory testCredId = "333";
        eduVerify.issueCredential(
            testCredId,
            "Mario",
            student,
            "UniTrento",
            "Test Degree",
            "Qm333"
        );
        
        string[] memory creds = eduVerify.getInstitutionCredentials(address(this));
        bool found = false;
        for(uint i = 0; i < creds.length; i++) {
            if(keccak256(bytes(creds[i])) == keccak256(bytes(testCredId))) {
                found = true;
                break;
            }
        }
        Assert.ok(found, "Should find the test credential");
    }
    
}