import React, { useState, useEffect } from 'react';
import { Card, ListGroup, Button, Spinner, Alert, Tabs, Tab } from 'react-bootstrap';
import VerifyCredential from './VerifyCredential';
import { getFileDownloadLink } from '../utils/pinata';

const StudentView = ({ contract, account }) => {
  const [credentials, setCredentials] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [previewUrl, setPreviewUrl] = useState(null);
  const [previewFileName, setPreviewFileName] = useState('');
  const fetchCredentials = async () => {
    try {
      const creds = await contract.getStudentCredentialsFull(account);
      
      const formattedCreds = creds.map(cred => ({
        ...cred,
        issueDate: new Date(cred.issueDate * 1000).toLocaleDateString(),
        id: `${cred.issuer}-${cred.cid}`
      }));
      
      setCredentials(formattedCreds);
    } catch (err) {
      console.error("Error fetching credentials:", err);
      setError('Failed to load credentials. Make sure you have credentials issued.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (contract && account) {
      fetchCredentials();
    }
  }, [contract, account]);

    const openDocument = (cid, fileName) => {
    setPreviewFileName(fileName);
    setPreviewUrl(getFileDownloadLink(cid));
  };

  return (
    <>
      <Tabs defaultActiveKey="myCredentials" className="mb-3">
        <Tab eventKey="myCredentials" title="My Credentials">
          <Card className="mb-4 shadow-sm">
            <Card.Body>
              <Card.Subtitle className="mb-2 text-muted">
                {account} is not authorized to issue credentials.<br />
                If you are a student, you can see your credentials below.<br />
                You can verify any credential in the second tab.
              </Card.Subtitle>
              <Card.Title>My Academic Credentials</Card.Title>
              
              {error && <Alert variant="danger">{error}</Alert>}
              
              {loading ? (
                <div className="text-center">
                  <Spinner animation="border" />
                  <p>Loading credentials...</p>
                </div>
              ) : credentials.length === 0 ? (
                <Alert variant="info">
                  You don't have any credentials yet. Institutions will issue them to you.
                </Alert>
              ) : (
                <ListGroup>
                  {credentials.map((cred, index) => (
                    <ListGroup.Item key={index}>
                      <div className="d-flex justify-content-between align-items-center">
                        <div>
                          <h6>{cred.degree}</h6>
                          <div>Issued by: {cred.institution}</div>
                          <div>Issued on: {cred.issueDate}</div>
                          <div className="text-muted small">CID: {cred.cid}</div>
                        </div>
                        <Button 
                          variant="primary"
                          onClick={() => openDocument(cred.cid, `${cred.cid}-${cred.degree}.pdf`)}
                        >
                          View Document
                        </Button>
                      </div>
                    </ListGroup.Item>
                  ))}
                </ListGroup>
              )}
            </Card.Body>
          </Card>

          {previewUrl && (
            <Card className="mb-4 shadow-sm">
              <Card.Body>
                <div className="d-flex justify-content-between align-items-center mb-3">
                  <Card.Title>Document Preview: {previewFileName}</Card.Title>
                  <Button 
                    variant="secondary"
                    onClick={() => setPreviewUrl(null)}
                  >
                    Close
                  </Button>
                </div>
                
                <div className="border rounded overflow-hidden">
                  <iframe 
                    src={previewUrl} 
                    title="Document Preview"
                    style={{ width: '100%', height: '500px' }}
                  />
                </div>
              </Card.Body>
            </Card>
          )}
        </Tab>
        
        <Tab eventKey="verify" title="Verify Credentials">
          <Card className="shadow-sm">
            <Card.Body>
              <Card.Title>Verify Academic Credentials</Card.Title>
              <p className="text-muted">
                As a verifier, you can check the authenticity of any credential
              </p>
              <VerifyCredential contract={contract} />
            </Card.Body>
          </Card>
        </Tab>
      </Tabs>
    </>
  );
};

export default StudentView;