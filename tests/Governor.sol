// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/EduVerifyAdmin.sol";

contract Governor {

    function proposeTest( EduVerifyAdmin admin,  EduVerifyAdmin.Action action, address target
    ) public returns (uint256) {
        return admin.propose(action, target);
    }

    function voteTest(EduVerifyAdmin admin, uint256 proposalId) public returns (bool) {
        (bool result, ) = address(admin).call(abi.encodeWithSignature("vote(uint256)", proposalId));
        return result;
    }

    function executeProposal(EduVerifyAdmin admin, uint256 proposalId) public returns (bool) {
        (bool result, ) = address(admin).call(abi.encodeWithSignature("executeProposal(uint256)", proposalId));
        return result;
    }
}
