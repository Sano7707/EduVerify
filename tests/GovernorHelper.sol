// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/EduVerifyAdmin.sol";

contract GovernorHelper {
    function propose(
        EduVerifyAdmin admin,
        EduVerifyAdmin.Action action,
        address target
    ) public returns (uint256) {
        return admin.propose(action, target);
    }

    function vote(EduVerifyAdmin admin, uint256 proposalId) public returns (bool) {
        (bool success, ) = address(admin).call(
            abi.encodeWithSignature("vote(uint256)", proposalId)
        );
        return success;
    }

    function executeProposal(EduVerifyAdmin admin, uint256 proposalId) public returns (bool) {
        (bool success, ) = address(admin).call(
            abi.encodeWithSignature("executeProposal(uint256)", proposalId)
        );
        return success;
    }
}
