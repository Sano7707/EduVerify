import React, { useState,useEffect } from 'react';
import { Spinner } from 'react-bootstrap'; 
import { Card, Alert, Button , Tab} from 'react-bootstrap';
import IssueCredential from './IssueCredential';
import InstitutionCredentials from './InstitutionCredentials';
import VerifyCredential from './VerifyCredential';


const InstitutionView = ({ contract, account }) => {
  const [showIssueForm, setShowIssueForm] = useState(false);
  const [isAuthorized, setIsAuthorized] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAuthorization = async () => {
      try {
        const authorized = await contract.authorizedInstitutions(account);
        setIsAuthorized(authorized);
      } catch (err) {
        console.error('Authorization check failed:', err);
      } finally {
        setLoading(false);
      }
    };
    
    checkAuthorization();
  }, [contract, account]);

  if (loading) {
    return (
      <div className="text-center my-4">
        <Spinner animation="border" />
        <p>Checking institution status...</p>
      </div>
    );
  }

  return (
    <>
      {!isAuthorized ? (
        <Card className="mb-4 shadow-sm">
          <Card.Body>
            <Alert variant="warning">
              <h5>Institution Authorization Required</h5>
              <p className="mb-0">
                Your wallet is not authorized as an institution. Please contact a governor to 
                submit an "Add Institution" proposal for your address.
              </p>
            </Alert>
          </Card.Body>
        </Card>
      ) : (
        <Card className="mb-4 shadow-sm">
          <Card.Body>
            <div className="d-flex justify-content-between align-items-center">
              <div>
                <Card.Title>Institution Dashboard</Card.Title>
                <Card.Subtitle className="text-muted">
                  {account}
                </Card.Subtitle>
              </div>
              <Button 
                variant={showIssueForm ? "secondary" : "primary"} 
                onClick={() => setShowIssueForm(!showIssueForm)}
              >
                {showIssueForm ? "Cancel" : "Issue New Credential"}
              </Button>
              
      
            </div>
             <div eventKey="verify" title="Verify Credentials">
          <Card className="shadow-sm">
            <Card.Body>
              <Card.Title>Verify Academic Credentials</Card.Title>
              <p className="text-muted">
                As a verifier, you can check the authenticity of any credential
              </p>
              <VerifyCredential contract={contract} />
            </Card.Body>
          </Card>
        </div>
            
            {showIssueForm && (
              <IssueCredential contract={contract} account={account} />
            )}
          </Card.Body>
        </Card>
      )}
    

      {isAuthorized && (
        <InstitutionCredentials contract={contract} account={account} />
      )}
    </>
  );
};

export default InstitutionView;