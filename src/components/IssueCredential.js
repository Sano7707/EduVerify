import React, { useState } from 'react';
import { Form, Button, Card, Alert, Spinner } from 'react-bootstrap';
import { uploadToPinata,getFileDownloadLink } from '../utils/pinata';

const IssueCredential = ({ contract, account }) => {
  const [formData, setFormData] = useState({
    credentialId: '',
    studentAddress: '',
    institution: '',
    degree: '',
    document: null
  });
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFileChange = (e) => {
    setFormData({ ...formData, document: e.target.files[0] });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess(false);

    try {
      if (!formData.credentialId || 
          !formData.studentAddress || 
          !formData.institution || 
          !formData.degree || 
          !formData.document) {
        throw new Error('Please fill all fields correctly');
      }

      if (!/^0x[a-fA-F0-9]{40}$/.test(formData.studentAddress)) {
        throw new Error('Invalid student wallet address');
      }

      const uploadResult = await uploadToPinata(formData.document);
      if (!uploadResult || !uploadResult.cid) {
        console.log(uploadResult)
        throw new Error('Failed to upload document to IPFS');
      }

      const cid = uploadResult.cid;
      
      const params = [
        formData.credentialId,
        formData.studentAddress,
        formData.institution,
        formData.degree,
        cid
      ];
      
      
      const tx = await contract.issueCredential(...params);
      
      await tx.wait();
      setSuccess('Credential issued successfully!');
      
      setFormData({
        credentialId: '',
        studentAddress: '',
        institution: '',
        degree: '',
        document: null
      });
    } catch (err) {
      console.error('Error issuing credential:', err);
      setError(err.message || 'Failed to issue credential');
    } finally {
      setLoading(false);
    }
  };
  return (
    <Card className="mt-4 shadow-sm">
      <Card.Body>
        <Card.Title>Issue New Credential</Card.Title>
        
        {success && <Alert variant="success">Credential issued successfully!</Alert>}
        {error && <Alert variant="danger">{error}</Alert>}
        
        <Form onSubmit={handleSubmit}>
          <Form.Group className="mb-3">
            <Form.Label>Credential ID</Form.Label>
            <Form.Control
              type="text"
              name="credentialId"
              value={formData.credentialId}
              onChange={handleChange}
              required
              placeholder="Enter unique credential ID"
            />
          </Form.Group>
          
          <Form.Group className="mb-3">
            <Form.Label>Student Wallet Address</Form.Label>
            <Form.Control
              type="text"
              name="studentAddress"
              value={formData.studentAddress}
              onChange={handleChange}
              required
              placeholder="Enter student's wallet address"
            />
            <Form.Text className="text-muted">
              The student will receive the credential at this address
            </Form.Text>
          </Form.Group>
          
          <Form.Group className="mb-3">
            <Form.Label>Institution</Form.Label>
            <Form.Control
              type="text"
              name="institution"
              value={formData.institution}
              onChange={handleChange}
              required
              placeholder="Enter institution name"
            />
          </Form.Group>
          
          <Form.Group className="mb-3">
            <Form.Label>Degree/Certificate</Form.Label>
            <Form.Control
              type="text"
              name="degree"
              value={formData.degree}
              onChange={handleChange}
              required
              placeholder="Enter degree or certificate name"
            />
          </Form.Group>
          
          <Form.Group className="mb-3">
            <Form.Label>Document (PDF)</Form.Label>
            <Form.Control
              type="file"
              name="document"
              onChange={handleFileChange}
              accept=".pdf"
              required
            />
            <Form.Text className="text-muted">
              Upload the academic document in PDF format
            </Form.Text>
          </Form.Group>
          
          <Button 
            variant="primary" 
            type="submit"
            disabled={loading}
          >
            {loading ? (
              <>
                <Spinner animation="border" size="sm" /> Processing...
              </>
            ) : 'Issue Credential'}
            
          </Button>
        </Form>
      </Card.Body>
    </Card>
  );
};

export default IssueCredential;