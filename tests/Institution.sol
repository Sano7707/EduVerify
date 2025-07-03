// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/EduVerify.sol";

contract Institution {

    function issueCredential(
        EduVerify eduVerify,
        string memory credentialId,     //university has its own id of the credential
        address studentAddress,         //address of student's wallet
        string memory institution,      //university name
        string memory degree,           //type of the degree      
        string memory cid               //cid to identify the document on IPFS
    ) public returns (bool) {
        /* (bool result, bytes memory data) = address(eduVerify).call(abi.encodeWithSignature("issueCredential(string, address, string, string, string)",
        credentialId, studentAddress, institution, degree, cid)); */
        eduVerify.issueCredential(credentialId, studentAddress, institution, degree, cid);
        return (true);
    }

}
