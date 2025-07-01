// SPDX-License-Identifier: UniTrento
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../new-contracts/EduVerify.sol";
import "../new-contracts/EduVerifyAdmin.sol";
import "./Governor.sol";
import "./Institution.sol";
import "hardhat/console.sol";


contract EduVerifyTest {

    EduVerify eduVerify;
    EduVerifyAdmin admin;

    Governor governor1;
    Governor governor2;
    Governor governor3;

    address[] initialGovernors;

    address student = address(0x3);
    Institution institution1;
    Institution institution2;

    string credentialId1 = "111";
    string credentialId2 = "222";
    string cid1 = "QmABC111";
    string cid2 = "QmABC222";
    
    uint nextProposalId = 0;

    function beforeAll() public {
        institution1 = new Institution();
        institution2 = new Institution();

        governor1 = new Governor();
        governor2 = new Governor();
        governor3 = new Governor();

        initialGovernors.push(address(governor1));
        initialGovernors.push(address(governor2));
        initialGovernors.push(address(governor3));

        admin = new EduVerifyAdmin(initialGovernors);
        eduVerify = new EduVerify(address(admin));
        governor1.setEduVerify(admin, address(eduVerify));

        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, address(institution1));
    }
    
    function _createAndExecuteProposal(EduVerifyAdmin.Action action, address target) private {
        uint proposalId = governor1.proposeTest(admin, action, target);
        governor1.voteTest(admin, proposalId);
        governor2.voteTest(admin, proposalId);
        governor3.executeProposal(admin, proposalId);
        nextProposalId++;
    }

    function testInitialSetup() public {
        Assert.equal(eduVerify.getStudentCredentialsFull(student).length, 0, "No credentials at the beginning for the student");
        Assert.ok(eduVerify.authorizedInstitutions(address(institution1)), "institution1 is an authorized institution");
        Assert.ok(!eduVerify.authorizedInstitutions(address(institution2)), "institution2 is NOT an authorized institution");
    }

    
    function testAuthorizeInstitution() public {
        _createAndExecuteProposal(EduVerifyAdmin.Action.AddInstitution, address(institution2));
        Assert.ok(eduVerify.authorizedInstitutions(address(institution2)), "Institution2 should be now authorized");
    }
    
    function testRevokeInstitution() public {
        _createAndExecuteProposal(EduVerifyAdmin.Action.RevokeInstitution, address(institution2));
        Assert.ok(!eduVerify.authorizedInstitutions(address(institution2)), "Institution2 should be no more authorized");
    }
    
    function testIssueCredential() public {
        Assert.ok(eduVerify.authorizedInstitutions(address(institution1)), "institution1 is an authorized institution");
       try institution1.issueCredential(
            eduVerify,
            credentialId1,
            student,
            "UniTrento",
            "BSc CS",
            cid1
        ) returns (bool result) {
            Assert.ok(result, "Issuing went well");
        
            EduVerify.Credential memory cred = eduVerify.getCredential(address(institution1), credentialId1);
            Assert.equal(cred.institution, "UniTrento", "Institution should match");
            Assert.equal(cred.degree, "BSc CS", "Degree should match");
            Assert.equal(cred.cid, cid1, "CID should match");
            Assert.equal(cred.issuer, address(institution1), "Issuer should match");
            Assert.equal(cred.studentAddress, student, "Student should match");
        
            cred = eduVerify.getCredentialByCID(cid1);
            Assert.equal(cred.institution, "UniTrento", "Institution should match");
            Assert.equal(cred.degree, "BSc CS", "Degree should match");
            Assert.equal(cred.cid, cid1, "CID should match");
            Assert.equal(cred.issuer, address(institution1), "Issuer should match");
            Assert.equal(cred.studentAddress, student, "Student should match");

            EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(student);
            Assert.equal(creds.length, 1, "Student should have 1 credential");
            Assert.equal(creds[0].cid, cid1, "CID should match");

            string[] memory creds_id = eduVerify.getInstitutionCredentials(address(institution1));
            Assert.equal(creds_id.length, 1, "Institution 1 should have 1 credential");
            Assert.equal(creds_id[0], credentialId1, "CredentialId should match");

        } catch {
            Assert.ok(false, "We should not be here because issuing must have been successful");
        }


    }

    
    function testIssueDuplicateCredential() public {
        try institution1.issueCredential(
            eduVerify,
            credentialId1,
            student,
            "UniTrento duplicated",
            "BSc CS duplicated",
            cid1
        ) {
            //if we are here it means issuing went well
            Assert.ok(false, "We should not be here: issuing should not have gone well");
        } catch {
            Assert.ok(true, "Issuing did not went well because of duplication");
            EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(student);
            Assert.equal(creds.length, 1, "Student should have STILL 1 credential");

            string[] memory creds_id = eduVerify.getInstitutionCredentials(address(institution1));
            Assert.equal(creds_id.length, 1, "Institution 1 should have STILL 1 credential");
        }

        
    }
    
    function testUnauthorizedIssuance() public {
        Assert.ok(!eduVerify.authorizedInstitutions(address(institution2)), "Institution2 should be no authorized");

        try institution2.issueCredential(
            eduVerify,
            credentialId2,
            student,
            "UniTrento 2",
            "BSc CS 2",
            cid2
        ) {
            //if we are here it means issuing went well
            Assert.ok(false, "We should not be here: issuing should not have gone well");
        } catch {
            Assert.ok(true, "Issuing did not went well because institution2 is not authorized");
            
            EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(student);
            Assert.equal(creds.length, 1, "Student should have STILL 1 credential");

            string[] memory creds_id = eduVerify.getInstitutionCredentials(address(institution2));
            Assert.equal(creds_id.length, 0, "Institution 2 has 0 credentials");
        }
        
    }

    function testGetCredential() public {
        EduVerify.Credential memory cred = eduVerify.getCredential(address(institution1), credentialId1);
        Assert.equal(cred.institution, "UniTrento", "Institution should match");
        Assert.equal(cred.degree, "BSc CS", "Degree should match");
        Assert.equal(cred.cid, cid1, "CID should match");
        Assert.equal(cred.issuer, address(institution1), "Issuer should match");
        Assert.equal(cred.studentAddress, student, "Student should match");
    }

    function testGetCredentialWithNonExistingId() public {
        EduVerify.Credential memory cred = eduVerify.getCredential(address(institution1), "nonExistingId");
        Assert.equal(cred.institution, "", "Institution should be default");
        Assert.equal(cred.degree, "", "Degree should be default");
        Assert.equal(cred.cid, "", "CID should be default");
        Assert.equal(cred.issuer, address(0x00), "Issuer should be default");
        Assert.equal(cred.studentAddress, address(0x00), "Student be default");
    }

    function testGetCredentialWithNonExistingIssuer() public {
        EduVerify.Credential memory cred = eduVerify.getCredential(address(0x00), "nonExistingId");
        Assert.equal(cred.institution, "", "Institution should be default");
        Assert.equal(cred.degree, "", "Degree should be default");
        Assert.equal(cred.cid, "", "CID should be default");
        Assert.equal(cred.issuer, address(0x00), "Issuer should be default");
        Assert.equal(cred.studentAddress, address(0x00), "Student be default");
    }

    function getCredentialbyCid() public {
        EduVerify.Credential memory cred = eduVerify.getCredentialByCID(cid1);
        Assert.equal(cred.institution, "UniTrento", "Institution should match");
        Assert.equal(cred.degree, "BSc CS", "Degree should match");
        Assert.equal(cred.cid, cid1, "CID should match");
        Assert.equal(cred.issuer, address(institution1), "Issuer should match");
        Assert.equal(cred.studentAddress, student, "Student should match");
    }

    function getCredentialbyNonExistingCid() public {
        try eduVerify.getCredentialByCID("nonExistingCid") returns (EduVerify.Credential memory cred) {
            //if we are here it means getting went well
            Assert.ok(false, "We should not be here: getting should not have reverted");
        } catch {
            Assert.ok(true, "It has properly revert due to CID not existing");
        }
    }


    
    function testStudentCredentials() public {
        EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(student);
        
        Assert.equal(creds.length, 1, "Student should have 1 credential");
        Assert.equal(creds[0].degree, "BSc CS", "Degree should match");
        Assert.equal(creds[0].institution, "UniTrento", "Institution should match");
        Assert.equal(creds[0].cid, cid1, "CID should match");
        Assert.equal(creds[0].issuer, address(institution1), "Issuer should match");
        Assert.equal(creds[0].studentAddress, student, "Student should match");
    }

    function testNonExistingStudentCredentials() public {
        EduVerify.Credential[] memory creds = eduVerify.getStudentCredentialsFull(address(0x00));
        
        Assert.equal(creds.length, 0, "Student should have 0 credentials");
    }

    
    function testInstitutionCredentials() public {
        string[] memory creds_id = eduVerify.getInstitutionCredentials(address(institution1));
        Assert.equal(creds_id.length, 1, "Institution 1 should have 1 credential");
        Assert.equal(creds_id[0], credentialId1, "CredentialId should match");
    }

    function testEmptyInstitutionCredentials() public {
        string[] memory creds_id = eduVerify.getInstitutionCredentials(address(institution2));
        Assert.equal(creds_id.length, 0, "Institution 2 should have 0 credentials");
    }
}