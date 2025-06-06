// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/EduVerify.sol";
import "../contracts/EduVerifyAdmin.sol";

contract EduVerifyTest {
    EduVerify eduVerify;
    EduVerifyAdmin admin;
    
    address institution = address(1);
    address institution2 = address(2);
    address student = address(3);
    address unauthorized = address(4);
    
    string credentialId = "degree-123";
    string credentialId2 = "degree-456";
    string cid = "QmXYZ123";
    string cid2 = "QmXYZ456";

    function beforeAll() public {
        address[] memory initialGovernors = new address[](1);
        initialGovernors[0] = address(this);
        admin = new EduVerifyAdmin(initialGovernors, address(0));
        
        eduVerify = new EduVerify(address(admin));
        admin.setEduVerifyAddress(address(eduVerify));
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, institution);
        admin.vote(0);
        admin.executeProposal(0);
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, institution2);
        admin.vote(1);
        admin.executeProposal(1);
        
        admin.propose(EduVerifyAdmin.Action.AddInstitution, address(this));
        admin.vote(2);
        admin.executeProposal(2);
    }
    
    
    function testAuthorizeInstitution() public {
        Assert.ok(eduVerify.authorizedInstitutions(institution), "Institution1 should be authorized");
        Assert.ok(eduVerify.authorizedInstitutions(institution2), "Institution2 should be authorized");
        Assert.ok(eduVerify.authorizedInstitutions(address(this)), "Test contract should be authorized");
        Assert.ok(!eduVerify.authorizedInstitutions(unauthorized), "Unauthorized should not be authorized");
    }
    
    function testRevokeInstitution() public {
        admin.propose(EduVerifyAdmin.Action.RevokeInstitution, institution2);
        admin.vote(3);
        admin.executeProposal(3);
        
        Assert.ok(!eduVerify.authorizedInstitutions(institution2), "Institution2 should be revoked");
    }
    
    
    function testIssueCredential() public {
        eduVerify.issueCredential(
            credentialId,
            "Alice",
            student,
            "MIT",
            "BSc CS",
            cid
        );
        
        EduVerify.Credential memory cred = eduVerify.getCredential(credentialId);
        Assert.equal(cred.studentName, "Alice", "Student name should match");
        Assert.equal(cred.degree, "BSc CS", "Degree should match");
    }
    
    function testIssueDuplicateCredential() public {
        try eduVerify.issueCredential(
            credentialId,
            "Bob",
            student,
            "Stanford",
            "PhD",
            cid2
        ) {
            Assert.ok(false, "Duplicate credential ID should fail");
        } catch {
            Assert.ok(true, "Duplicate credential ID failed as expected");
        }
    }
    
    function testUnauthorizedIssuance() public {
        admin.propose(EduVerifyAdmin.Action.RevokeInstitution, address(this));
        admin.vote(4);
        admin.executeProposal(4);

        try eduVerify.issueCredential(
            credentialId2,
            "Bob",
            student,
            "Stanford",
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
            "Bob",
            student,
            "Harvard",
            "MBA",
            cid2
        );
        
        string[] memory creds = eduVerify.getStudentCredentials(student);
        Assert.equal(creds.length, 2, "Student should have 2 credentials");
        
        bool foundFirst = false;
        bool foundSecond = false;
        for(uint i = 0; i < creds.length; i++) {
            if(keccak256(bytes(creds[i])) == keccak256(bytes(credentialId))) {
                foundFirst = true;
            }
            if(keccak256(bytes(creds[i])) == keccak256(bytes(credentialId2))) {
                foundSecond = true;
            }
        }
        Assert.ok(foundFirst, "First credential should exist");
        Assert.ok(foundSecond, "Second credential should exist");
    }
    
    function testInstitutionCredentials() public {
        string memory testCredId = "test-cred-789";
        eduVerify.issueCredential(
            testCredId,
            "Charlie",
            student,
            "Test Uni",
            "Test Degree",
            "QmTest"
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