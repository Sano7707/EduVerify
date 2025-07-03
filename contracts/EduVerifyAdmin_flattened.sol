
// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}

// File: contracts/EduVerifyAdmin.sol


pragma solidity ^0.8.0;


contract EduVerifyAdmin {
    
    using ECDSA for bytes32;
    
    enum Action { AddInstitution, RevokeInstitution, AddGovernor, RevokeGovernor }

    struct Proposal {
        uint256 id;                             //unique identifier of the proposal
        Action action;                          //type of action of the proposal
        address target;                         //address subject of the proposal
        uint256 yesVotes;                       //number of yes votes
        uint256 snapshotGovernorCount;          //number of governors at the moment of the proposal
        bool executed;                          //quorum is reached and proposal is made effective
        mapping(address => bool) hasVoted;      //mapping to identify if a specific governor has voted or not
    }

    /*
        Three governors at the start, on which we have initial trust (Multi-Sig model).
        Each of them can use a proposal for: authorize or revoke institutions; add another governor or remove a governor.    
    */

    //to cheack easier if an addr is a governor without loops
    mapping(address => bool) public isGovernor;
    //to store the governors
    address[] public governors;
    //address of other SC
    address public eduVerify;
    
    //history of all proposals
    Proposal[] public proposals;
    
    event ProposalCreated(uint256 indexed proposalId, Action action, address target);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event ProposalExecuted(uint256 indexed proposalId);
    event GovernorAdded(address indexed governor);
    event GovernorRemoved(address indexed governor);
    
    modifier onlyGovernor() {
        require(isGovernor[msg.sender], "Not a governor");
        _;
    }
    
    constructor(address[] memory _initialGovernors) {

        uint length = _initialGovernors.length;
        for (uint i = 0; i < length;) {
            address governor = _initialGovernors[i];
            require(governor != address(0), "Invalid governor");
            require(!isGovernor[governor], "Duplicate governor");
            isGovernor[governor] = true;
            governors.push(governor);
            emit GovernorAdded(governor);

            unchecked{ ++i; }
        }
    }

    //we set the address of SC EduVerify once it has been deployed
    function setEduVerifyAddress(address _eduVerify) external onlyGovernor {
        require(eduVerify == address(0), "Address already set");
        eduVerify = _eduVerify;
    }
    
    function calculateThreshold() external view returns(uint) {
        return (governors.length / 2) + 1;
    }
    
    function propose(Action action, address target) external onlyGovernor returns(uint) {
        uint proposalId = proposals.length;
        Proposal storage newProposal = proposals.push();
        newProposal.id = proposalId;
        newProposal.action = action;
        newProposal.target = target;
        newProposal.yesVotes = 0;
        newProposal.snapshotGovernorCount = governors.length;
        newProposal.executed = false;
        
        emit ProposalCreated(proposalId, action, target);
        return proposalId;
    }

    function vote(uint proposalId) external onlyGovernor {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.hasVoted[msg.sender], "Governor already voted");
        require(!proposal.executed, "Proposal already executed");
        
        proposal.hasVoted[msg.sender] = true;
        proposal.yesVotes+=1;
        emit VoteCast(proposalId, msg.sender);
    }
    
    function executeProposal(uint proposalId) external onlyGovernor {
        Proposal storage proposal = proposals[proposalId];
        uint requiredThreshold = (proposal.snapshotGovernorCount / 2) + 1;
        
        require(proposal.yesVotes >= requiredThreshold, "Insufficient votes to execute proposal");
        require(!proposal.executed, "Proposal already executed");
        
        if(proposal.action == Action.AddInstitution) {
            (bool success, ) = eduVerify.call(abi.encodeWithSignature("authorizeInstitution(address)", proposal.target));
            require(success, "Authorization failed");
        }
        else if(proposal.action == Action.RevokeInstitution) {
            (bool success, ) = eduVerify.call(abi.encodeWithSignature("revokeInstitution(address)", proposal.target));
            require(success, "Revocation failed");
        }
        else if(proposal.action == Action.AddGovernor) {
            address _addr_target = proposal.target;
            require(!isGovernor[_addr_target], "Target is already a governor");
            isGovernor[_addr_target] = true;
            governors.push(_addr_target);
            emit GovernorAdded(_addr_target);
        }
        else if(proposal.action == Action.RevokeGovernor) {
            address _addr_target = proposal.target;
            require(isGovernor[_addr_target], "Not a governor");
            require(governors.length >= 2, "Two governors cannot remove each other");
            isGovernor[_addr_target] = false;

            uint length = governors.length;            
            for (uint i = 0; i < length;) {
                if (governors[i] == _addr_target) {
                    governors[i] = governors[length - 1];
                    governors.pop();
                    break;
                }
                unchecked{ ++i; }
            }
            
            emit GovernorRemoved(proposal.target);
        }
        
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
    
    function getProposalDetails(uint proposalId) external view returns(Action action, address target, uint yesVotes, uint snapshotGovernorCount,  bool executed) {
        Proposal storage p = proposals[proposalId];
        return (p.action, p.target, p.yesVotes, p.snapshotGovernorCount, p.executed);
    }
    
    function getThresholdForProposal(uint proposalId) external view returns(uint) {
        Proposal storage p = proposals[proposalId];
        return (p.snapshotGovernorCount / 2) + 1;
    }
    
    function hasVoted(uint proposalId, address governor) external view returns(bool) {
        return proposals[proposalId].hasVoted[governor];
    }
    
    function proposalCount() external view returns(uint) {
        return proposals.length;
    }
    
    function governorCount() external view returns(uint) {
        return governors.length;
    }

}