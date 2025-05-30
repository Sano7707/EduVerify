import React from 'react';
import { Card, Row, Col, Button, Spinner } from 'react-bootstrap';

const Dashboard = ({ onRoleSelect, loading }) => {
  return (
    <Card className="mb-4 shadow-sm">
      <Card.Body>
        <Card.Title className="text-center mb-4">Welcome to EduVerify</Card.Title>
        <Card.Text className="text-center">
          Select your role to get started
        </Card.Text>
        
        <Row className="mt-4 justify-content-center">
          {/* Student Card */}
          <Col md={4} className="mb-4">
            <Card className="h-100 text-center">
              <Card.Body>
                <div className="bg-light p-3 rounded-circle d-inline-block mb-3">
                  <i className="bi bi-person fs-1 text-primary"></i>
                </div>
                <Card.Title>Student</Card.Title>
                <Card.Text>
                  Verify and manage your academic credentials
                </Card.Text>
                <Button 
                  variant="outline-primary" 
                  className="mt-2"
                  onClick={() => onRoleSelect('student')}
                  disabled={loading}
                >
                  {loading ? (
                    <Spinner animation="border" size="sm" />
                  ) : "Continue as Student"}
                </Button>
              </Card.Body>
            </Card>
          </Col>
          
          {/* Institution Card */}
          <Col md={4} className="mb-4">
            <Card className="h-100 text-center">
              <Card.Body>
                <div className="bg-light p-3 rounded-circle d-inline-block mb-3">
                  <i className="bi bi-building fs-1 text-success"></i>
                </div>
                <Card.Title>Institution</Card.Title>
                <Card.Text>
                  Issue and verify academic credentials
                </Card.Text>
                <Button 
                  variant="outline-success" 
                  className="mt-2"
                  onClick={() => onRoleSelect('institution')}
                  disabled={loading}
                >
                  {loading ? (
                    <Spinner animation="border" size="sm" />
                  ) : "Continue as Institution"}
                </Button>
              </Card.Body>
            </Card>
          </Col>
          
          {/* Admin Card */}
          <Col md={4} className="mb-4">
            <Card className="h-100 text-center">
              <Card.Body>
                <div className="bg-light p-3 rounded-circle d-inline-block mb-3">
                  <i className="bi bi-shield-lock fs-1 text-danger"></i>
                </div>
                <Card.Title>Admin</Card.Title>
                <Card.Text>
                  Manage authorized institutions
                </Card.Text>
                <Button 
                  variant="outline-danger" 
                  className="mt-2"
                  onClick={() => onRoleSelect('admin')}
                  disabled={loading}
                >
                  {loading ? (
                    <Spinner animation="border" size="sm" />
                  ) : "Admin Panel"}
                </Button>
              </Card.Body>
            </Card>
          </Col>
        </Row>
        
        <div className="mt-4 p-3 bg-light rounded">
          <h5>How It Works</h5>
          <ol>
            <li>Select your role (Student or Institution)</li>
            <li>Connect your wallet</li>
            <li>Institutions: Issue verifiable credentials to students</li>
            <li>Students: View and share your credentials</li>
            <li>Anyone: Verify credentials using the credential ID</li>
          </ol>
        </div>
      </Card.Body>
    </Card>
  );
};

export default Dashboard;