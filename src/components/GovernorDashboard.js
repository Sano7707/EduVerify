import React, { useState, useEffect } from 'react';
import { Card, Button, Form, Alert, Spinner, Table } from 'react-bootstrap';

const GovernorDashboard = ({ governorContract, account }) => {
  const [proposals, setProposals] = useState([]);
  const [action, setAction] = useState(0);
  const [target, setTarget] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [threshold, setThreshold] = useState(0);
  const [governors, setGovernors] = useState([]);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      setError('');
      try {
        // Load governance settings
        const thresh = await governorContract.governorCount(); // Example threshold calculation
        setThreshold(Math.floor(thresh.toNumber()/2) + 1);
        
        // Load governors
        const govCount = await governorContract.governorCount();
        const govs = [];
        for (let i = 0; i < govCount.toNumber(); i++) {
          govs.push(await governorContract.governors(i));
        }
        setGovernors(govs);
        
        // Load proposals
        const count = await governorContract.proposalCount();
        const props = [];
        
        for (let i = 0; i < count.toNumber(); i++) {
          const details = await governorContract.getProposalDetails(i);
          const hasVoted = await governorContract.hasVoted(i, account);
          const requiredThreshold = Math.floor(details[3].toNumber() / 2) + 1;
          
          props.push({
            id: i,
            action: details[0],
            target: details[1],
            yesVotes: details[2].toNumber(),
            snapshotGovCount: details[3].toNumber(),
            executed: details[4],
            threshold: requiredThreshold,
            hasVoted
          });
        }
        
        setProposals(props);
      } catch (err) {
        console.error('Error loading data:', err);
        setError('Failed to load governance data: ' + err.message);
      } finally {
        setLoading(false);
      }
    };
    
    if (governorContract) {
      loadData();
    }
  }, [governorContract, account]);

  const createProposal = async () => {
    setLoading(true);
    setError('');
    setSuccess('');
    
    try {
      const tx = await governorContract.propose(action, target);
      await tx.wait();
      setSuccess('Proposal created successfully!');
      setTarget('')
        const timer = setTimeout(() => {
        window.location.reload();
      }, 2000);
      return () => clearTimeout(timer);
    } catch (err) {
      setError('Failed to create proposal: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const voteOnProposal = async (id) => {
    setLoading(true);
    try {
      const tx = await governorContract.vote(id);
      await tx.wait();
      setSuccess(`Voted on proposal #${id}`);
        const timer = setTimeout(() => {
        window.location.reload();
      }, 2000);
      return () => clearTimeout(timer);
    } catch (err) {
      setError('Failed to vote: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const executeProposal = async (id) => {
    setLoading(true);
    try {
      const tx = await governorContract.executeProposal(id);
      await tx.wait();
      setSuccess(`Proposal #${id} executed`);
      
      const timer = setTimeout(() => {
        window.location.reload();
      }, 2000);
      return () => clearTimeout(timer);
     

    } catch (err) {
      setError('Execution failed: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="governor-dashboard">
      {error && <Alert variant="danger" className="mb-4">{error}</Alert>}
      {success && <Alert variant="success" className="mb-4">{success}</Alert>}
      
      <Card className="mb-4 shadow-sm">
        <Card.Body>
          <Card.Title>Governance Dashboard</Card.Title>
          
          <Form className="mt-4">
            <Form.Group className="mb-3">
              <Form.Label>Action Type</Form.Label>
              <Form.Select 
                value={action} 
                onChange={(e) => setAction(parseInt(e.target.value))}
              >
                <option value="0">Add Institution</option>
                <option value="1">Revoke Institution</option>
                <option value="2">Add Governor</option>
                <option value="3">Revoke Governor</option>
              </Form.Select>
            </Form.Group>
            
            <Form.Group className="mb-3">
              <Form.Label>Target Address</Form.Label>
              <Form.Control
                type="text"
                value={target}
                onChange={(e) => setTarget(e.target.value)}
                placeholder="0x..."
              />
            </Form.Group>
            
            <Button 
              variant="primary"
              onClick={createProposal}
              disabled={loading || !target}
            >
              {loading ? (
                <Spinner animation="border" size="sm" />
              ) : 'Create Proposal'}
            </Button>
          </Form>
        </Card.Body>
      </Card>

      <Card className="mb-4 shadow-sm">
        <Card.Body>
          <Card.Title>Active Proposals</Card.Title>
          
          {loading ? (
            <div className="text-center">
              <Spinner animation="border" />
              <p>Loading proposals...</p>
            </div>
          ) : proposals.length === 0 ? (
            <Alert variant="info">No active proposals</Alert>
          ) : (
            <Table striped bordered hover responsive>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Action</th>
                  <th>Target</th>
                  <th>Votes</th>
                  <th>Threshold</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {proposals.map((p) => (
                  <tr key={p.id}>
                    <td>{p.id}</td>
                    <td>
                      {p.action === 0 && 'Add Institution'}
                      {p.action === 1 && 'Revoke Institution'}
                      {p.action === 2 && 'Add Governor'}
                      {p.action === 3 && 'Revoke Governor'}
                    </td>
                    <td className="text-truncate" style={{ maxWidth: '200px' }}>{p.target}</td>
                    <td>{p.yesVotes}</td>
                    <td>{p.threshold}</td>
                    <td>
                      {p.executed ? (
                        <span className="text-success">Executed</span>
                      ) : p.yesVotes >= p.threshold ? (
                        <span className="text-warning">Ready to Execute</span>
                      ) : (
                        <span className="text-info">Pending</span>
                      )}
                    </td>
                    <td>
                      {!p.executed && !p.hasVoted && (
                        <Button 
                          variant="success" 
                          size="sm"
                          onClick={() => voteOnProposal(p.id)}
                          disabled={loading}
                        >
                          Vote
                        </Button>
                      )}
                      {!p.executed && p.yesVotes >= p.threshold && (
                        <Button 
                          variant="primary" 
                          size="sm"
                          className="ms-2"
                          onClick={() => executeProposal(p.id)}
                          disabled={loading}
                        >
                          Execute
                        </Button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </Table>
          )}
        </Card.Body>
      </Card>

      <Card className="shadow-sm">
        <Card.Body>
          <Card.Title>Governance Information</Card.Title>
          <p><strong>Vote Threshold:</strong> {threshold} votes</p>
          
          <div className="mt-3">
            <h5>Current Governors</h5>
            {governors.length === 0 ? (
              <Alert variant="warning">No governors found</Alert>
            ) : (
              <ul>
                {governors.map((g, i) => (
                  <li key={i} className="mb-2">
                    <code>{g}</code>
                    {g.toLowerCase() === account.toLowerCase() && (
                      <span className="badge bg-info ms-2">You</span>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </Card.Body>
      </Card>
    </div>
  );
};

export default GovernorDashboard;