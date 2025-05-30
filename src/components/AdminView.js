import React, { useState, useEffect } from 'react';
import { Card, Button, ListGroup, Spinner, Alert, Form } from 'react-bootstrap';
import { ethers } from 'ethers';

const AdminView = ({ contract, account }) => {
  const [institutions, setInstitutions] = useState([]);
  const [newInstitution, setNewInstitution] = useState('');
  const [isOwner, setIsOwner] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

 
 
  useEffect(() => {
    const checkOwner = async () => {
      if (contract && account) {
        const ownerStatus = await contract.isOwner();
        setIsOwner(ownerStatus);
      }
    };
    
    const fetchInstitutions = async () => {
      if (contract && account && isOwner) {
        setLoading(true);
        try {
          const instAddresses = await contract.getAuthorizedInstitutions();
          setInstitutions(instAddresses);
        } catch (err) {
          console.error('Error fetching institutions:', err);
          setError('Failed to load institutions');
        } finally {
          setLoading(false);
        }
      }
    };
    
    checkOwner();
    if (isOwner) {
      fetchInstitutions();
    }
  }, [contract, account, isOwner]);

  const authorizeNewInstitution = async () => {
    if (!newInstitution || !ethers.utils.isAddress(newInstitution)) {
      setError('Please enter a valid Ethereum address');
      return;
    }
    
    setLoading(true);
    setError('');
    setSuccess('');
    
    try {
      const tx = await contract.authorizeInstitution(newInstitution);
      await tx.wait();
      setSuccess(`Institution ${newInstitution} authorized successfully!`);
      setNewInstitution('');
      
      // Refresh list
      const instAddresses = await contract.getAuthorizedInstitutions();
      setInstitutions(instAddresses);
    } catch (err) {
      console.error('Authorization error:', err);
      setError(err.message || 'Failed to authorize institution');
    } finally {
      setLoading(false);
    }
  };

const revokeInstitution = async (address) => {
  if (!window.confirm(`Revoke authorization for ${address}?`)) return;
  
  setLoading(true);
  try {
    const tx = await contract.revokeInstitution(address);
    await tx.wait();
    
    // Refresh institutions list
    const updatedInstitutions = institutions.filter(inst => inst !== address);
    setInstitutions(updatedInstitutions);
    
    setSuccess(`Institution ${address} revoked`);
  } catch (err) {
    setError(`Revocation failed: ${err.message}`);
  } finally {
    setLoading(false);
  }
};

  if (!isOwner) {
    return (
      
      <Card className="mb-4 shadow-sm">
        <Card.Body className="text-center">
          <Alert variant="danger">
            <h4>Access Denied</h4>
            <p>Your wallet is not authorized as the contract owner.</p>
            <p>Only the contract owner can access the admin panel.</p>
          </Alert>
        </Card.Body>
      </Card>
    );
  }

  return (
    <div className="admin-view">
      <Card className="mb-4 shadow-sm">
        <Card.Body>
          <Card.Title>Admin Dashboard</Card.Title>
          <p className="text-muted">
            Manage authorized institutions on the EduVerify platform
          </p>
          
          {error && <Alert variant="danger">{error}</Alert>}
          {success && <Alert variant="success">{success}</Alert>}
          
          <div className="d-flex mb-4">
            <Form.Control
              type="text"
              value={newInstitution}
              onChange={(e) => setNewInstitution(e.target.value)}
              placeholder="Enter institution wallet address"
              className="me-2"
            />
            <Button 
              variant="primary"
              onClick={authorizeNewInstitution}
              disabled={loading}
            >
              {loading ? (
                <Spinner animation="border" size="sm" />
              ) : 'Authorize Institution'}
            </Button>
          </div>
          
          <Card.Subtitle className="mb-3">
            Authorized Institutions ({institutions.length})
          </Card.Subtitle>
          
          {loading ? (
            <div className="text-center">
              <Spinner animation="border" />
              <p>Loading institutions...</p>
            </div>
          ) : institutions.length === 0 ? (
            <Alert variant="info">
              No institutions have been authorized yet
            </Alert>
          ) : (
            <ListGroup>
              {institutions.map((address, index) => (
                <ListGroup.Item 
                  key={index} 
                  className="d-flex justify-content-between align-items-center"
                >
                  <div>
                    <span className="font-monospace">{address}</span>
                  </div>
                  <Button 
                    variant="danger"
                    size="sm"
                    onClick={() => revokeInstitution(address)}
                    disabled={loading}
                  >
                    Revoke
                  </Button>
                </ListGroup.Item>
              ))}
            </ListGroup>
          )}
        </Card.Body>
      </Card>
      
      <Card className="shadow-sm">
        <Card.Body>
          <Card.Title>Contract Information</Card.Title>
          <div className="row">
            <div className="col-md-6">
              <p><strong>Contract Owner:</strong></p>
              <p className="font-monospace">{account}</p>
            </div>
            <div className="col-md-6">
              <p><strong>Total Institutions:</strong> {institutions.length}</p>
              <p><strong>Authorized Institutions:</strong> {institutions.length}</p>
            </div>
          </div>
        </Card.Body>
      </Card>
    </div>
  );
};

export default AdminView;