import React, { useState, useEffect } from 'react';
import { Card, ListGroup, Button, Spinner, Alert } from 'react-bootstrap';
import { getFileDownloadLink } from '../utils/pinata';

const StudentView = ({ contract, account }) => {
  const [credentials, setCredentials] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [previewUrl, setPreviewUrl] = useState(null);
  const [previewFileName, setPreviewFileName] = useState('');

  const fetchCredentials = async () => {
    try {
      const credentialIds = await contract.getStudentCredentials(account);
      
      const creds = await Promise.all(
        credentialIds.map(async (id) => {
          const data = await contract.verifyCredential(id);
          return {
            id,
            studentName: data[0],
            institution: data[1],
            degree: data[2],
            issueDate: new Date(Number(data[3]) * 1000).toLocaleDateString(),
            cid: data[4],  // Now using CID
            issuer: data[5]
          };
        })
      );
      
      setCredentials(creds);
    } catch (err) {
      setError('Failed to load credentials');
    } finally {
      setLoading(false);
    }
  };


  const openDocument = (fileId, fileName) => {
    setPreviewFileName(fileName);
    setPreviewUrl(getFileDownloadLink(fileId));
  };

  useEffect(() => {
    fetchCredentials();
  }, [contract, account]);

  return (
    <>
    
      <Card className="mb-4 shadow-sm">
        <Card.Body>
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
            onClick={() => openDocument(cred.cid, `${cred.studentName}-${cred.degree}.pdf`)}
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
    </>
  );
};

export default StudentView;