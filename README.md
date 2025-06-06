# EduVerify - Academic Credential Verification System

![EduVerify Demo](demo.gif)

EduVerify is a decentralized platform for issuing, managing, and verifying academic credentials using blockchain technology. Built on Polygon with a governance model for institutions, this system provides a tamper-proof solution for academic credential verification.

---

## Table of Contents

1. [Features](#features)  
2. [Technology Stack](#technology-stack)  
3. [Installation Guide](#installation-guide)  
4. [Configuration](#configuration)  
5. [Initial Governance Setup](#initial-governance-setup)  
6. [Running the Application](#running-the-application)  
7. [Project Structure](#project-structure)  
8. [Testing](#testing)  
9. [Team](#team)  
10. [License](#license)  
11. [Acknowledgments](#acknowledgments)  

---

## Features

- 🎓 Issue verifiable academic credentials as NFTs  
- 🔍 Verify credentials instantly using blockchain  
- 🗳️ Multi-signature governance for institutions  
- 🔒 Secure document storage on IPFS via Pinata  
- 👨‍🎓 Student-friendly credential management  
- 🏫 Institution dashboard for credential issuance  

---

## Technology Stack

### Blockchain
- **Polygon PoS** – Low-cost, scalable transactions  
- **Solidity** – Smart contract development  
- **OpenZeppelin** – Battle-tested contract libraries  

### Frontend
- **React.js** – Component-based UI  
- **React Bootstrap** – Responsive UI components  
- **Ethers.js** – Blockchain interactions  
- **Web3.js** – Wallet connectivity  

### Storage
- **IPFS** – Decentralized file storage  
- **Pinata** – IPFS pinning service  

---

## Installation Guide

### Prerequisites
- Node.js (v16+)  
- npm (v8+)  
- MetaMask wallet (configured for Polygon Mumbai testnet)  
- Pinata account (for IPFS storage)  

### Frontend Setup
1. **Clone the repo**  
    ```bash
    git clone https://github.com/your-username/EduVerify.git
    cd EduVerify/frontend
    ```
2. **Install dependencies**  
    ```bash
    npm install
    ```
3. **Configure environment**  
    Create a `.env` file in `frontend/`:
    ```env
    REACT_APP_EDU_VERIFY_ADDRESS=0xYourEduVerifyContractAddress
    REACT_APP_GOVERNOR_ADDRESS=0xYourGovernorContractAddress
    REACT_APP_PINATA_API_KEY=your_pinata_api_key
    REACT_APP_PINATA_JWT=your_pinata_jwt
    ```
4. **Start development server**  
    ```bash
    npm start
    ```

### Smart Contract Deployment (Optional)
1. **Install Hardhat**  
    ```bash
    cd ../contracts
    npm install
    ```
2. **Configure** `hardhat.config.js` with your wallet and RPC details.  
3. **Deploy**  
    ```bash
    npx hardhat run scripts/deploy.js --network polygonMumbai
    ```

---

## Configuration

### MetaMask Setup
1. Install [MetaMask](https://metamask.io/) extension.  
2. Add Polygon Mumbai Testnet:  
   - **Network Name:** Mumbai Testnet  
   - **RPC URL:** https://rpc-mumbai.maticvigil.com/  
   - **Chain ID:** 80001  
   - **Currency Symbol:** MATIC  
3. Get test MATIC from the [Polygon Faucet](https://faucet.polygon.technology/).  

### Pinata Setup
1. Create a [Pinata account](https://www.pinata.cloud/).  
2. Generate API keys under Dashboard → API Keys.  
3. Add them to `.env` as shown above.  

---

## Initial Governance Setup

Pre-configured governor wallets (multi-sig):
- `0xGovernorAddress1`  
- `0xGovernorAddress2`  
- `0xGovernorAddress3`  

Use any of these addresses to access the Governor Dashboard.

---

## Running the Application

1. **Start the frontend**  
    ```bash
    cd frontend
    npm start
    ```
2. **Open** [http://localhost:3000](http://localhost:3000).  
3. **Connect** MetaMask.  

Depending on your address, you will see:  
- **Governor Dashboard** (if wallet is a governor)  
- **Institution View** (if authorized institution)  
- **Student/Verifier View** (otherwise)  

---
Team
Sanasar Hambardzumyan – s.hambardzumyan@studenti.unitn.it

Gabriele Volani – gabriele.volana@studenti.unitn.it


Course: Blockchain Technologies
Professor: [Professor’s Name]
University: [Your University]
Academic Year: 2023–2024

License
This project is licensed under the MIT License. See the LICENSE file for details.
