import React, { useState, useEffect } from 'react';
import { Card, ListGroup, Spinner, Alert } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { getFileDownloadLink } from '../utils/pinata';

const InstitutionCredentials = ({ contract, account }) => {
  const [issuedCredentials, setIssuedCredentials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const loadCredentials = async () => {
      try {
        const credentialIds = await contract.getInstitutionCredentials(account);
        
        const creds = await Promise.all(
          credentialIds.map(async (id) => {
            const credential = await contract.getCredential(account,id);
            
            return {
              id,
              studentName: credential.studentName,
              institution: credential.institution,
              degree: credential.degree,
              issueDate: new Date(Number(credential.issueDate) * 1000).toLocaleDateString(),
              cid: credential.cid
            };
          })
        );
        
        setIssuedCredentials(creds);
      } catch (err) {
        console.error("Error loading credentials:", err);
        setError('Failed to load credentials');
      } finally {
        setLoading(false);
      }
    };

    if (account && contract) {
      loadCredentials();
    }
  }, [contract, account]);

  return (
    <Card className="mb-4 shadow-sm">
      <Card.Body>
        <Card.Title>Issued Credentials</Card.Title>
        
        {loading && <Spinner animation="border" />}
        {error && <Alert variant="danger">{error}</Alert>}
        
        {!loading && issuedCredentials.length === 0 && (
          <Alert variant="info">No credentials issued yet</Alert>
        )}
        
        {issuedCredentials.length > 0 && (
          <ListGroup>
            {issuedCredentials.map((cred, index) => (
              <ListGroup.Item key={index}>
                <div className="d-flex justify-content-between">
                  <div>
                    <h6>{cred.degree}</h6>
                    <div>Student: {cred.studentName}</div>
                    <div>Issued: {cred.issueDate}</div>
                    <div className="text-muted small">
                      CID: {cred.cid}
                    </div>
                  </div>
                  <Button 
                    variant="link"
                    href={getFileDownloadLink(cred.cid)}
                    target="_blank"
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
  );
};

export default InstitutionCredentials;