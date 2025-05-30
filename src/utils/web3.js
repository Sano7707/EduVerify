import { ethers } from 'ethers';

let provider = null;
let signer = null;

export const initWeb3 = async () => {
  if (window.ethereum) {
    try {
      // Check if we're already connected
      const accounts = await window.ethereum.request({ method: 'eth_accounts' });
      if (accounts.length > 0) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        return true;
      }
      
      // Request connection if not connected
      await window.ethereum.request({ method: 'eth_requestAccounts' });
      provider = new ethers.providers.Web3Provider(window.ethereum);
      signer = provider.getSigner();
      return true;
    } catch (error) {
      console.error("User denied account access", error);
      return false;
    }
  } else {
    console.error("MetaMask not installed");
    return false;
  }
};

export const getCurrentAccount = async () => {
  if (signer) {
    try {
      return await signer.getAddress();
    } catch (error) {
      console.error("Error getting account:", error);
      return null;
    }
  }
  
  // Fallback to eth_accounts
  try {
    const accounts = await window.ethereum.request({ method: 'eth_accounts' });
    return accounts[0] || null;
  } catch (error) {
    console.error("Error getting accounts:", error);
    return null;
  }
};


export const loadContract = (address, abi) => {
  if (!provider) {
    throw new Error("Web3 provider not initialized");
  }
  return new ethers.Contract(address, abi, signer);
};