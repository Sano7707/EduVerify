import React, { useState, useEffect } from 'react';
import { initWeb3, getCurrentAccount, loadContract } from './utils/web3';
import Dashboard from './components/Dashboard';
import IssueCredential from './components/IssueCredential';
import VerifyCredential from './components/VerifyCredential';
import Navbar from './components/Navbar';
import StudentView from './components/StudentView';
import InstitutionView from './components/InstitutionView';
import contractABI from './contracts/EduVerify.json';
import 'bootstrap/dist/css/bootstrap.min.css';
import AdminView from './components/AdminView';
import './App.css';

function App() {
    const [isOwner, setIsOwner] = useState(false);
  const [account, setAccount] = useState('');
  const [isInstitution, setIsInstitution] = useState(false);
  const [contract, setContract] = useState(null);
  const [loading, setLoading] = useState(false);
  const [role, setRole] = useState(null); // 'student' or 'institution'
  
  const CONTRACT_ADDRESS = "0x997d26eadaCC61CdAa19f0b72bc6D2400ae27372";

const connectWallet = async (selectedRole) => {
  setLoading(true);
  try {
    const web3Available = await initWeb3();
    if (!web3Available) {
      alert('Please install MetaMask!');
      setLoading(false);
      return;
    }

    const acc = await getCurrentAccount();
    setAccount(acc);
    
    const contractInstance = loadContract(CONTRACT_ADDRESS, contractABI.abi);
    setContract(contractInstance);
    
    // Check role-specific permissions AFTER contract is loaded
    if (selectedRole === 'admin') {
      try {
        const ownerStatus = await contractInstance.isOwner();
        setIsOwner(ownerStatus);
        
        if (!ownerStatus) {
          alert('Your wallet is not the contract owner. Only the contract owner can access the admin panel.');
        }
      } catch (err) {
        console.error('Admin check error:', err);
        alert('Failed to verify admin status: ' + err.message);
      }
    } else if (selectedRole === 'institution') {
      try {
        const institutionStatus = await contractInstance.authorizedInstitutions(acc);
        setIsInstitution(institutionStatus);
      } catch (err) {
        console.error('Institution check error:', err);
        alert('Failed to verify institution status: ' + err.message);
      }
    }
    
    // Set role based on selection
    setRole(selectedRole);
    
  } catch (error) {
    console.error("Connection error:", error);
    
    // More specific error messages
    if (error.code === 4001) {
      alert('Connection rejected by user');
    } else if (error.code === -32002) {
      alert('Connection request already pending. Please check MetaMask.');
    } else {
      alert('Failed to connect wallet: ' + error.message);
    }
  } finally {
    setLoading(false);
  }
};

 return (
    <div className="App">
      <Navbar 
        account={account} 
        isInstitution={isInstitution} 
        role={role}
        isOwner={isOwner}
      />
      
      <div className="container mt-4">
        <h1 className="text-center mb-4">EduVerify: Academic Credential Verification</h1>
        
        {!account ? (
          <Dashboard onRoleSelect={connectWallet} loading={loading} />
        ) : (
          <>
            {role === 'student' && (
              <StudentView contract={contract} account={account} />
            )}
            
            {role === 'institution' && (
              <InstitutionView 
                contract={contract} 
                account={account}
                isInstitution={isInstitution}
              />
            )}
            
            {role === 'admin' && (
              <AdminView contract={contract} account={account} />
            )}
          </>
        )}
      </div>
    </div>
  );
}


export default App;