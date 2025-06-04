import React, { useState } from 'react';
import { Card, Form, Button, Alert, Spinner } from 'react-bootstrap';
import { getFileDownloadLink } from '../utils/pinata';

const VerifyCredential = ({ contract }) => {
  const [cid, setCid] = useState('');
  const [studentAddress, setStudentAddress] = useState('');
  const [credentialData, setCredentialData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [verificationResult, setVerificationResult] = useState(null);

  const handleVerify = async () => {
    if (!cid || !studentAddress) {
      setError('Please enter both document CID and student address');
      return;
    }
    
    setLoading(true);
    setError('');
    setCredentialData(null);
    setVerificationResult(null);
    
    try {
      // Use getCredentialByCID instead of verifyCredential
      const credential = await contract.getCredentialByCID(cid);
      const addressMatches = credential.studentAddress.toLowerCase() === studentAddress.toLowerCase();

      // Check if credential exists
      if (!addressMatches) {
        setVerificationResult({
          valid: false,
          message: "Credential not found"
        });
        return;
      }
            
      // Prepare result
      setCredentialData({
        studentName: credential.studentName,
        institution: credential.institution,
        degree: credential.degree,
        issueDate: new Date(Number(credential.issueDate) * 1000).toLocaleDateString(),
        issuer: credential.issuer,
        studentAddress: credential.studentAddress,
        cid: credential.cid
      });
      
      setVerificationResult({
        valid: addressMatches,
        message: "Credential is valid and matches student address" 
         
      });
      
    } catch (err) {
      console.error('Verification error:', err);
      setVerificationResult({
        valid: false,
        message: "Credential not found"
      });
    } finally {
      setLoading(false);
    }
  };

  const renderDocument = () => {
    return (
      <div className="mt-3">
        <h6>Document Preview:</h6>
        <div className="border rounded overflow-hidden mb-2">
          <iframe 
            src={getFileDownloadLink(cid)} 
            title="Credential Document"
            style={{ width: '100%', height: '500px' }}
          />
        </div>
        
        <a 
          href={getFileDownloadLink(cid)} 
          download="credential-document.pdf"
          className="btn btn-primary"
        >
          <i className="bi bi-download me-2"></i>Download Document
        </a>
      </div>
    );
  };

  return (
    <Card className="shadow-sm">
      <Card.Body>
        <Card.Title>Verify Credential</Card.Title>
        
        <Form>
          <Form.Group className="mb-3">
            <Form.Label>Document CID</Form.Label>
            <Form.Control
              type="text"
              value={cid}
              onChange={(e) => setCid(e.target.value)}
              placeholder="Enter document CID"
              required
            />
            <Form.Text className="text-muted">
              Found at the bottom of your credential document
            </Form.Text>
          </Form.Group>
          
          <Form.Group className="mb-3">
            <Form.Label>Student Wallet Address</Form.Label>
            <Form.Control
              type="text"
              value={studentAddress}
              onChange={(e) => setStudentAddress(e.target.value)}
              placeholder="Enter student's wallet address"
              required
            />
          </Form.Group>
          
          <Button 
            variant="primary" 
            onClick={handleVerify}
            disabled={loading}
          >
            {loading ? (
              <>
                <Spinner animation="border" size="sm" /> Verifying...
              </>
            ) : 'Verify Credential'}
          </Button>
        </Form>
        
        {error && <Alert variant="danger" className="mt-3">{error}</Alert>}
        
        {verificationResult && (
          <div className="mt-4">
            <Alert variant={verificationResult.valid ? "success" : "warning"}>
              <h5>Verification Result</h5>
              <p>{verificationResult.message}</p>
            </Alert>
          </div>
        )}
        
        {credentialData && verificationResult?.valid && (
          <div className="mt-4">
            <div className="border p-3 rounded bg-light">
              <p><strong>Student:</strong> {credentialData.studentName}</p>
              <p><strong>Institution:</strong> {credentialData.institution}</p>
              <p><strong>Degree:</strong> {credentialData.degree}</p>
              <p><strong>Issued Date:</strong> {credentialData.issueDate}</p>
              <p><strong>Issuer Address:</strong> {credentialData.issuer}</p>
              <p><strong>Student Address:</strong> {credentialData.studentAddress}</p>
              <p><strong>Document CID:</strong> {credentialData.cid}</p>
              
              {/* Document preview section */}
              {renderDocument()}
            </div>
          </div>
        )}
      </Card.Body>
    </Card>
  );
};

export default VerifyCredential;