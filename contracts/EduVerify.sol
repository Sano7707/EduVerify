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

    struct CredentialReference {
    address issuer;
    string credentialId;
}



    address public adminContract;
    mapping(address => bool) public authorizedInstitutions;
    mapping(address => mapping(string => Credential)) public credentials;
    mapping(address => string[]) public institutionCredentials;
    mapping(string => address) public cidToIssuer;          
    mapping(string => string) public cidToCredentialId;   
    mapping(address => CredentialReference[]) public studentCredentials;


    event CredentialIssued(string indexed credentialId, address indexed issuer, address indexed student);
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
        require(authorizedInstitutions[msg.sender], "Institution not authorized");
        
        require(bytes(credentials[msg.sender][credentialId].degree).length == 0,  "Credential ID already used by your institution" );
        
        credentials[msg.sender][credentialId] = Credential({
            studentName: studentName,
            institution: institution,
            degree: degree,
            issueDate: block.timestamp,
            cid: cid,
            issuer: msg.sender,
            studentAddress: studentAddress
        });
        
        studentCredentials[studentAddress].push(CredentialReference({
         issuer: msg.sender,
        credentialId: credentialId
    }));
            institutionCredentials[msg.sender].push(credentialId);
        cidToCredentialId[cid] = credentialId;
        cidToIssuer[cid] = msg.sender;
        
        emit CredentialIssued(credentialId, msg.sender, studentAddress);
    }

    function getCredential(address issuer, string memory credentialId) public view returns (Credential memory)  {
        return credentials[issuer][credentialId];
    }

    function getCredentialByCID(string memory cid) public view returns (Credential memory)    {
        address issuer = cidToIssuer[cid];
        require(issuer != address(0), "Credential not found");
        string memory credentialId = cidToCredentialId[cid];
        return credentials[issuer][credentialId];
    }

   function getStudentCredentialsFull(address student)  public   view  returns (Credential[] memory) {
    CredentialReference[] memory refs = studentCredentials[student];
    Credential[] memory creds = new Credential[](refs.length);
    
    for (uint i = 0; i < refs.length; i++) {
        creds[i] = credentials[refs[i].issuer][refs[i].credentialId];
    }
    return creds;
}

    function getInstitutionCredentials(address institution)  public view returns (string[] memory)    {
        return institutionCredentials[institution];
    }
}