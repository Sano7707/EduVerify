# EduVerify - Academic Credential Verification System

EduVerify is a decentralized platform for issuing, managing, and verifying academic credentials using blockchain technology. Built on Polygon with a governance model for institutions, this system provides a tamper-proof solution for academic credential verification.

---

## Table of Contents

1. [Features](#features)  
2. [Technology Stack](#technology-stack)  
3. [Installation Guide](#installation-guide)  
4. [Configuration](#configuration)  
5. [Initial Governance Setup](#initial-governance-setup)  
6. [Running the Application](#running-the-application)  
7. [Team](#team)  
8. [License](#license)  

---

## Features

- 🎓 Issue verifiable academic credentials   
- 🔍 Verify credentials instantly using blockchain  
- 🗳️ Multi-signature governance   
- 🔒 Secure document storage on IPFS via Pinata  
- 👨‍🎓 Student-friendly credential management  
- 🏫 Institution dashboard for credential issuance  

---

## Technology-Stack

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

## Installation-Guide

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
    REACT_APP_EDU_VERIFY_ADDRESS=0x38C56078D2e5F107136546233258eC92FbdCC2f9
    REACT_APP_GOVERNOR_ADDRESS=0xb77836B0674E9724DaCc42A7B4db0A0beF61fF50
    REACT_APP_PINATA_API_KEY=your_pinata_api_key
    REACT_APP_PINATA_JWT=your_pinata_jwt
    ```


## Configuration

### MetaMask Setup
1. Install [MetaMask](https://metamask.io/) extension.  
2. Add Polygon Apoy Testnet:  
   - **Network Name:** Apoy Testnet  
   - **RPC URL:** [https://rpc-mumbai.maticvigil.com/  ](https://rpc-amoy.polygon.technology/)
   - **Chain ID:** 80002
   - **Currency Symbol:** POL  
3. Get test POL from the [[Polygon Faucet](https://faucet.polygon.technology/). ](https://faucet.stakepool.dev.br/amoy) 

### Pinata Setup
1. Create a [Pinata account](https://www.pinata.cloud/).  
2. Generate API keys under Dashboard → API Keys.  
3. Add them to `.env` as shown above.  

---

## Initial-Governance-Setup

Pre-configured governor wallets (multi-sig):
- `0xGovernorAddress1`  
- `0xGovernorAddress2`  
- `0xGovernorAddress3`  

Use any of these addresses to access the Governor Dashboard.

---

## Running-the-Application

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
## Team
Sanasar Hambardzumyan – s.hambardzumyan@studenti.unitn.it

Gabriele Volani – gabriele.volana@studenti.unitn.it

Course: Blockchain Technologies
University: UniTrento
Academic Year: 2024–2025

## License
This project is licensed under the MIT License. 
