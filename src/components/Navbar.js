import React from 'react';
import { Container, Navbar, Badge } from 'react-bootstrap';

const CustomNavbar = ({ account, role }) => {
  const getRoleBadge = () => {
    if (!account) return null;
    
    if (role === 'governor') {
      return <Badge bg="danger" className="ms-2">Governor</Badge>;
    }
    
    if (role === 'institution') {
      return <Badge bg="success" className="ms-2">Institution</Badge>;
    }
    
    return <Badge bg="info" className="ms-2">Student/Verifier</Badge>;
  };

  return (
    <Navbar bg="dark" variant="dark" expand="lg">
      <Container>
        <Navbar.Brand href="/">
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
            <div className="text-light">Connect your wallet</div>
          )}
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default CustomNavbar;