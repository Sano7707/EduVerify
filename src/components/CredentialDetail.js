import React, { useState, useEffect } from 'react';
import { Alert, Spinner, Button, Card } from 'react-bootstrap';
import { fetchFromPinata } from '../utils/pinata';

const CredentialDetail = ({ contract, credentialId }) => {
  const [credentialData, setCredentialData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [documentUrl, setDocumentUrl] = useState('');

  useEffect(() => {
    const fetchCredential = async () => {
      if (!contract || !credentialId) return;
      
      setLoading(true);
      setError('');
      
      try {
        const data = await contract.verifyCredential(credentialId);
        setCredentialData({
          studentName: data[0],
          institution: data[1],
          degree: data[2],
          issueDate: new Date(Number(data[3]) * 1000),
          ipfsHash: data[4],
          issuer: data[5],
          studentAddress: data[6]
        });
        
        // Fetch document from IPFS
        if (data[4]) {
          const url = await fetchFromPinata(data[4]);
          setDocumentUrl(url);
        }
      } catch (err) {
        console.error('Error fetching credential:', err);
        setError('Failed to load credential details');
      } finally {
        setLoading(false);
      }
    };

    fetchCredential();
  }, [contract, credentialId]);

  if (loading) {
    return (
      <div className="text-center my-4">
        <Spinner animation="border" />
        <p>Loading credential details...</p>
      </div>
    );
  }

  if (error) {
    return <Alert variant="danger">{error}</Alert>;
  }

  if (!credentialData) {
    return <Alert variant="info">No credential data available</Alert>;
  }

  return (
    <Card className="mt-4">
      <Card.Body>
        <Card.Title>Credential Details</Card.Title>
        
        <div className="mb-3">
          <p><strong>Credential ID:</strong> {credentialId}</p>
          <p><strong>Student:</strong> {credentialData.studentName}</p>
          <p><strong>Institution:</strong> {credentialData.institution}</p>
          <p><strong>Degree:</strong> {credentialData.degree}</p>
          <p><strong>Issued Date:</strong> {credentialData.issueDate.toLocaleDateString()}</p>
          <p><strong>Issuer Address:</strong> {credentialData.issuer}</p>
          <p><strong>Student Address:</strong> {credentialData.studentAddress}</p>
        </div>
        
        {documentUrl && (
          <div className="mt-4">
            <h5>Document</h5>
            <div className="border p-3">
              <iframe 
                src={documentUrl} 
                title="Academic Document"
                width="100%" 
                height="500px"
                style={{ border: 'none' }}
              />
              <div className="mt-3 text-center">
                <Button 
                  variant="primary"
                  href={documentUrl}
                  target="_blank"
                  download={`credential-${credentialId}.pdf`}
                >
                  Download Document
                </Button>
              </div>
            </div>
          </div>
        )}

        <div className="mt-4 text-center">
          <div className="badge bg-success p-2">
            ✓ Credential Verified on Blockchain
          </div>
        </div>
      </Card.Body>
    </Card>
  );
};

export default CredentialDetail;