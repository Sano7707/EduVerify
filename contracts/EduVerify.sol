// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduVerify {
    struct Credential {
        string studentName;
        string institution;
        string degree;
        uint256 issueDate;
        string cid;
        address issuer;
        address studentAddress;
    }

    address public adminContract;
    mapping(address => bool) public authorizedInstitutions;
    mapping(string => Credential) public credentials;
    mapping(address => string[]) public studentCredentials;
    mapping(address => string[]) public institutionCredentials;
    mapping(string => string) public cidToCredentialId;

    event CredentialIssued(string indexed credentialId, address indexed student);
    event InstitutionAuthorized(address indexed institution);
    event InstitutionRevoked(address indexed institution);

    constructor(address _adminContract) {
        adminContract = _adminContract;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminContract, "Not authorized");
        _;
    }

    function authorizeInstitution(address institution) external onlyAdmin {
        authorizedInstitutions[institution] = true;
        emit InstitutionAuthorized(institution);
    }

    function revokeInstitution(address institution) external onlyAdmin {
        authorizedInstitutions[institution] = false;
        emit InstitutionRevoked(institution);
    }

    function issueCredential(
        string memory credentialId,
        string memory studentName,
        address studentAddress,
        string memory institution,
        string memory degree,
        string memory cid
    ) external {
        require(authorizedInstitutions[msg.sender], "Not authorized");
        require(bytes(credentials[credentialId].degree).length == 0, "Credential exists");
        
        credentials[credentialId] = Credential({
            studentName: studentName,
            institution: institution,
            degree: degree,
            issueDate: block.timestamp,
            cid: cid,
            issuer: msg.sender,
            studentAddress: studentAddress
        });
        
        studentCredentials[studentAddress].push(credentialId);
        institutionCredentials[msg.sender].push(credentialId);
        cidToCredentialId[cid] = credentialId;
        
        emit CredentialIssued(credentialId, studentAddress);
    }

    function getCredential(string memory credentialId) public view returns (Credential memory) {
        return credentials[credentialId];
    }

    function getCredentialByCID(string memory cid) public view returns (Credential memory) {
        string memory credentialId = cidToCredentialId[cid];
        require(bytes(credentialId).length > 0, "Credential not found");
        return credentials[credentialId];
    }

    function getStudentCredentials(address student) public view returns (string[] memory) {
        return studentCredentials[student];
    }

    function getInstitutionCredentials(address institution) public view returns (string[] memory) {
        return institutionCredentials[institution];
    }
}