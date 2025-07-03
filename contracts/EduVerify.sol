// SPDX-License-Identifier: UniTrento
pragma solidity ^0.8.0;

contract EduVerify {
    
    struct Credential {
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

    address public immutable adminContract;

    mapping(address => bool) public authorizedInstitutions;
    
    //student_address => (credentialId => credential)
    mapping(address => mapping(string => Credential)) public credentials;
    //instution_address => id of credentials issued by that institutions
    mapping(address => string[]) public institutionCredentials;
    //cid => address of who issued it
    mapping(string => address) public cidToIssuer;
    //cid => credential id
    mapping(string => string) public cidToCredentialId;
    //student_address => credential references associated
    mapping(address => CredentialReference[]) public studentCredentials;

    event CredentialIssued(string indexed credentialId, address indexed issuer, address indexed student);
    event InstitutionAuthorized(address indexed institution);
    event InstitutionRevoked(address indexed institution);

    //we set the EduVerifyAdmin contract when we deploy it
    constructor(address _adminContract) {
        adminContract = _adminContract;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminContract, "Not authorized");
        _;
    }

    //authorize an institution - can be only called by the contract EduVerifyAdmin
    function authorizeInstitution(address institution) external onlyAdmin {
        authorizedInstitutions[institution] = true;
        emit InstitutionAuthorized(institution);
    }

    //revoke an institution - can be only called by the contract EduVerifyAdmin
    function revokeInstitution(address institution) external onlyAdmin {
        authorizedInstitutions[institution] = false;
        emit InstitutionRevoked(institution);
    }

    function issueCredential(
        string memory credentialId,     //university has its own id of the credential
        address studentAddress,         //address of student's wallet
        string memory institution,      //university name
        string memory degree,           //type of the degree      
        string memory cid               //cid to identify the document on IPFS
    ) external {
        
        require(authorizedInstitutions[msg.sender], "Institution not authorized");
        require(bytes(credentials[msg.sender][credentialId].degree).length == 0,  "Credential ID already used by your institution" );
        
        credentials[msg.sender][credentialId] = Credential({
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

    function getCredential(address issuer, string memory credentialId) external view returns (Credential memory)  {
        return credentials[issuer][credentialId];
    }

    function getCredentialByCID(string memory cid) external view returns (Credential memory)    {
        address issuer = cidToIssuer[cid];
        require(issuer != address(0), "Credential not found");
        string memory credentialId = cidToCredentialId[cid];
        return credentials[issuer][credentialId];
    }

   function getStudentCredentialsFull(address student) external view  returns (Credential[] memory) {
        CredentialReference[] memory refs = studentCredentials[student];
        Credential[] memory creds = new Credential[](refs.length);
        
        uint length = refs.length;
        for (uint i = 0; i < length;) {
            creds[i] = credentials[refs[i].issuer][refs[i].credentialId];
            unchecked { ++i; }
        }
        return creds;
    }

    function getInstitutionCredentials(address institution) external view returns (string[] memory)    {
        return institutionCredentials[institution];
    }
}