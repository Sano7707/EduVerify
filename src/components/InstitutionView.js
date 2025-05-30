import React, { useState } from 'react';
import { Card, Alert, Button, Badge } from 'react-bootstrap';
import IssueCredential from './IssueCredential';
import VerifyCredential from './VerifyCredential';
import InstitutionCredentials from './InstitutionCredentials';

const InstitutionView = ({ contract, account, isInstitution }) => {
const [showIssueForm, setShowIssueForm] = useState(false);

  

  return (
    
    <>
    {isInstitution && (
    <Card className="mb-4 shadow-sm">
        <Card.Body>
        <div className="d-flex justify-content-between align-items-center">
            <div>
            <Card.Title>Institution Management</Card.Title>
            <Card.Subtitle className="text-muted">
                {account}
            </Card.Subtitle>
            </div>
            <Badge bg={isInstitution ? "success" : "warning"}>
            {isInstitution ? "Authorized" : "Pending Authorization"}
            </Badge>
        </div>
        
        {!isInstitution && (
            <Alert variant="warning" className="mt-3">
            <p className="mb-0">
                Your institution is not yet authorized to issue credentials.
                Please contact the admin to request authorization.
            </p>
            </Alert>
        )}
        </Card.Body>
    </Card>
    )}

      {!isInstitution && (
        <Alert variant="warning" className="mb-4">
          Your wallet is not authorized as an institution. Only authorized institutions can issue credentials.
        </Alert>
      )}

      <Card className="mb-4 shadow-sm">
        <Card.Body>
          <div className="d-flex justify-content-between align-items-center mb-3">
            <Card.Title>Institution Dashboard</Card.Title>
            {isInstitution && (
              <Button 
                variant={showIssueForm ? "secondary" : "primary"} 
                onClick={() => setShowIssueForm(!showIssueForm)}
              >
                {showIssueForm ? "Cancel" : "Issue New Credential"}
              </Button>
            )}
          </div>
          
          {showIssueForm && isInstitution && (
            <IssueCredential contract={contract} account={account} />
          )}
        </Card.Body>
      </Card>

      {isInstitution && (
        <InstitutionCredentials contract={contract} account={account} />
      )}

      <VerifyCredential />
    </>
  );
};

export default InstitutionView;