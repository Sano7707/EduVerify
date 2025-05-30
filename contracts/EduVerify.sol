// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduVerify {
    struct Credential {
        string studentName;
        string institution;
        string degree;
        uint issueDate;
        string fileId;  // Changed from ipfsHash to fileId for clarity
        address issuer;
        address studentAddress;
    }

    mapping(string => Credential) private credentials;
    mapping(string => string) public cidToCredentialId;  // CID to credential ID mapping
    address public owner;
    mapping(address => bool) public authorizedInstitutions;
    mapping(address => string[]) public institutionCredentials;
    mapping(address => string[]) private studentCredentials;
    
    // Track all institutions for admin view
    address[] private allInstitutions;
    uint private authorizedCount;
    
    event CredentialIssued(string indexed credentialId, address indexed studentAddress);
    event InstitutionAuthorized(address indexed institution);
    event InstitutionRevoked(address indexed institution);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedInstitutions[msg.sender], "Not authorized institution");
        _;
    }

    // Institution management
    function authorizeInstitution(address _institution) external onlyOwner {
        require(!authorizedInstitutions[_institution], "Already authorized");
        authorizedInstitutions[_institution] = true;
        allInstitutions.push(_institution);
        authorizedCount++;
        emit InstitutionAuthorized(_institution);
    }

    function revokeInstitution(address _institution) external onlyOwner {
        require(authorizedInstitutions[_institution], "Not authorized");
        authorizedInstitutions[_institution] = false;
        authorizedCount--;
        emit InstitutionRevoked(_institution);
    }

    function getAuthorizedInstitutions() external view returns (address[] memory) {
        address[] memory institutions = new address[](authorizedCount);
        uint count = 0;
        for(uint i = 0; i < allInstitutions.length; i++) {
            if(authorizedInstitutions[allInstitutions[i]]) {
                institutions[count] = allInstitutions[i];
                count++;
            }
        }
        return institutions;
    }

    // Credential management
    function issueCredential(
        string memory _credentialId,
        string memory _studentName,
        address _studentAddress,
        string memory _institution,
        string memory _degree,
        string memory _fileId  // CID of the document
    ) external onlyAuthorized {
        require(bytes(_fileId).length > 0, "Invalid file ID");
        require(bytes(credentials[_credentialId].fileId).length == 0, "Credential ID exists");
        
        credentials[_credentialId] = Credential({
            studentName: _studentName,
            institution: _institution,
            degree: _degree,
            issueDate: block.timestamp,
            fileId: _fileId,
            issuer: msg.sender,
            studentAddress: _studentAddress
        });
        
        // Map CID to credential ID
        cidToCredentialId[_fileId] = _credentialId;
        
        // Add credential to student's list
        studentCredentials[_studentAddress].push(_credentialId);
        
        // Add credential to institution's list
        institutionCredentials[msg.sender].push(_credentialId);
        
        emit CredentialIssued(_credentialId, _studentAddress);
    }

    // Verification functions
    function getCredentialByCID(string memory _cid)
        external
        view
        returns (
            string memory credentialId,
            string memory studentName,
            string memory institution,
            string memory degree,
            uint issueDate,
            string memory fileId,
            address issuer,
            address studentAddress
        )
    {
        credentialId = cidToCredentialId[_cid];
        require(bytes(credentialId).length > 0, "Credential not found for CID");
        
        Credential memory cred = credentials[credentialId];
        return (
            credentialId,
            cred.studentName,
            cred.institution,
            cred.degree,
            cred.issueDate,
            cred.fileId,
            cred.issuer,
            cred.studentAddress
        );
    }

    function verifyCredential(string memory _credentialId)
        external
        view
        returns (
            string memory studentName,
            string memory institution,
            string memory degree,
            uint issueDate,
            string memory fileId,
            address issuer,
            address studentAddress
        )
    {
        Credential memory cred = credentials[_credentialId];
        require(bytes(cred.fileId).length > 0, "Credential not found");
        return (
            cred.studentName,
            cred.institution,
            cred.degree,
            cred.issueDate,
            cred.fileId,
            cred.issuer,
            cred.studentAddress
        );
    }

    // Get credentials
    function getStudentCredentials(address _student) external view returns (string[] memory) {
        return studentCredentials[_student];
    }

    function getInstitutionCredentials(address _institution) external view returns (string[] memory) {
        return institutionCredentials[_institution];
    }

    // Admin functions
    function isOwner() external view returns (bool) {
        return msg.sender == owner;
    }
}