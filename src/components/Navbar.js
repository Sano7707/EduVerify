import React from 'react';
import { Container, Navbar, Badge } from 'react-bootstrap';

const CustomNavbar = ({ account, isInstitution, role, isOwner }) => {
  const getRoleBadge = () => {
    if (!account) return null;
    
    if (role === 'institution') {
      return isInstitution ? (
        <Badge bg="success" className="ms-2">Authorized Institution</Badge>
      ) : (
        <Badge bg="warning" className="ms-2">Unverified Institution</Badge>
      );
    }
    
    if (role === 'admin') {
      return isOwner ? (
        <Badge bg="danger" className="ms-2">Admin</Badge>
      ) : (
        <Badge bg="secondary" className="ms-2">Unauthorized</Badge>
      );
    }
    
    return <Badge bg="info" className="ms-2">Student</Badge>;
  };

  return (
    <Navbar bg="dark" variant="dark" expand="lg">
      <Container>
        <Navbar.Brand href="#">
          <span className="fw-bold">EduVerify</span>
          <span className="ms-2 text-muted">Academic Credentials</span>
        </Navbar.Brand>
        <Navbar.Toggle />
        <Navbar.Collapse className="justify-content-end">
          {account ? (
            <div className="d-flex align-items-center">
              {getRoleBadge()}
              <Navbar.Text className="ms-2">
                {`${account.substring(0, 6)}...${account.substring(account.length - 4)}`}
              </Navbar.Text>
            </div>
          ) : (
            <div className="text-light">Select your role to begin</div>
          )}
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default CustomNavbar;