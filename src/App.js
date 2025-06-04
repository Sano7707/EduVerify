import React, { useState, useEffect } from 'react';
import { Container, Spinner, Button } from 'react-bootstrap';
import { initWeb3, getCurrentAccount, loadContract } from './utils/web3';
import CustomNavbar from './components/Navbar';
import GovernorDashboard from './components/GovernorDashboard';
import InstitutionView from './components/InstitutionView';
import StudentView from './components/StudentView';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';

// Load contract ABIs
const EduVerifyAbi = require('./contracts/EduVerify.json').abi;
const GovernorAbi = require('./contracts/EduVerifyAdmin.json').abi;

function App() {
  const [account, setAccount] = useState(null);
  const [role, setRole] = useState(null);
  const [eduVerifyContract, setEduVerifyContract] = useState(null);
  const [governorContract, setGovernorContract] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [walletConnected, setWalletConnected] = useState(false);

  // Reset application state
  const resetApp = () => {
    setAccount(null);
    setRole(null);
    setEduVerifyContract(null);
    setGovernorContract(null);
    setWalletConnected(false);
    setError('');
  };

  // Initialize application after wallet connection
  const initializeApp = async () => {
    try {
      setLoading(true);
      setError('');
      
      // Initialize Web3
      const web3Initialized = await initWeb3();
      if (!web3Initialized) {
        setError('Please install MetaMask to continue');
        setLoading(false);
        return;
      }
      
      // Get current account
      const acc = await getCurrentAccount();
      if (!acc) {
        resetApp();
        setLoading(false);
        return;
      }
      setAccount(acc);
      
      // Load contract addresses from environment variables
      const eduVerifyAddress = process.env.REACT_APP_EDU_VERIFY_ADDRESS;
      const governorAddress = process.env.REACT_APP_GOVERNOR_ADDRESS;
      
      if (!eduVerifyAddress || !governorAddress) {
        setError('Contract addresses not configured');
        setLoading(false);
        return;
      }
      
      // Load contracts
      const eduVerify = loadContract(eduVerifyAddress, EduVerifyAbi);
      const governor = loadContract(governorAddress, GovernorAbi);
      
      setEduVerifyContract(eduVerify);
      setGovernorContract(governor);
      
      // Determine user role
      try {
        const isGov = await governor.isGovernor(acc);
        if (isGov) {
          setRole('governor');
        } else {
          const isInst = await eduVerify.authorizedInstitutions(acc);
          setRole(isInst ? 'institution' : 'student');
        }
      } catch (err) {
        console.error('Role detection error:', err);
        setRole('student');
      }
      
      setWalletConnected(true);
    } catch (err) {
      console.error('Initialization error:', err);
      setError('Failed to initialize application: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Setup wallet event listeners
  useEffect(() => {
    const handleAccountsChanged = (accounts) => {
      if (accounts.length === 0) {
        // Wallet disconnected
        resetApp();
      } else if (accounts[0] !== account) {
        // Account changed
        setAccount(accounts[0]);
        // Re-initialize with new account
        initializeApp();
      }
    };

    const handleChainChanged = () => {
      // Network changed - full reload needed
      window.location.reload();
    };

    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', handleChainChanged);
      
      // Check initial connection
      const checkConnection = async () => {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
          initializeApp();
        }
      };
      
      checkConnection();

      return () => {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        window.ethereum.removeListener('chainChanged', handleChainChanged);
      };
    }
  }, [account]);

  // Render loading state
  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center vh-100">
        <Spinner animation="border" />
        <p className="mt-3">Loading application...</p>
      </div>
    );
  }

  // Render error state
  if (error) {
    return (
      <div className="d-flex justify-content-center align-items-center vh-100">
        <div className="text-center">
          <h4>Application Error</h4>
          <p className="text-danger">{error}</p>
          <Button variant="primary" onClick={initializeApp}>
            Retry
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="App bg-light min-vh-100">
      <CustomNavbar 
        account={account} 
        role={role} 
        onDisconnect={resetApp}
      />
      
      <Container className="py-4">
        {!account ? (
          <div className="text-center mt-5 pt-5">
            <h1 className="mb-4">EduVerify Platform</h1>
            <p className="lead mb-5">Blockchain-based academic credential verification</p>
            
            <div className="card p-4 mb-4 mx-auto shadow" style={{ maxWidth: '500px' }}>
              <h3 className="mb-4">Connect Your Wallet</h3>
              <Button 
                variant="primary"
                size="lg"
                className="mb-3 w-100"
                onClick={initializeApp}
              >
                Connect with MetaMask
              </Button>
              <p className="text-muted mt-3">
                You'll need to install MetaMask to use this application
              </p>
            </div>
            
            <div className="row mt-5">
              <div className="col-md-4 mb-4">
                <div className="card h-100 shadow-sm">
                  <div className="card-body text-center p-4">
                    <div className="bg-primary text-white rounded-circle p-3 mb-3 d-inline-block">
                      <i className="bi bi-person fs-1"></i>
                    </div>
                    <h5>For Students</h5>
                    <p>Manage and share your academic credentials</p>
                  </div>
                </div>
              </div>
              <div className="col-md-4 mb-4">
                <div className="card h-100 shadow-sm">
                  <div className="card-body text-center p-4">
                    <div className="bg-success text-white rounded-circle p-3 mb-3 d-inline-block">
                      <i className="bi bi-building fs-1"></i>
                    </div>
                    <h5>For Institutions</h5>
                    <p>Issue verifiable credentials to students</p>
                  </div>
                </div>
              </div>
              <div className="col-md-4 mb-4">
                <div className="card h-100 shadow-sm">
                  <div className="card-body text-center p-4">
                    <div className="bg-danger text-white rounded-circle p-3 mb-3 d-inline-block">
                      <i className="bi bi-shield-lock fs-1"></i>
                    </div>
                    <h5>For Governors</h5>
                    <p>Manage institution authorizations</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ) : role === 'governor' ? (
          <GovernorDashboard 
            governorContract={governorContract} 
            account={account} 
          />
        ) : role === 'institution' ? (
          <InstitutionView 
            contract={eduVerifyContract} 
            account={account} 
          />
        ) : (
          <StudentView 
            contract={eduVerifyContract} 
            account={account} 
          />
        )}
      </Container>
    </div>
  );
}

export default App;