EduVerify - Academic Credential Verification System
https://demo.gif

EduVerify is a decentralized platform for issuing, managing, and verifying academic credentials using blockchain technology. Built on Polygon with a governance model for institutions, this system provides a tamper-proof solution for academic credential verification.

Features
🎓 Issue verifiable academic credentials as NFTs

🔍 Verify credentials instantly using blockchain

🗳️ Multi-signature governance for institutions

🔒 Secure document storage on IPFS via Pinata

👨‍🎓 Student-friendly credential management

🏫 Institution dashboard for credential issuance

Technology Stack
Blockchain
Polygon PoS - For low-cost transactions

Solidity - Smart contracts development

OpenZeppelin - Secure contract templates

Frontend
React.js - User interface

React Bootstrap - UI components

Ethers.js - Blockchain interaction

Web3.js - Wallet connectivity

Storage
IPFS - Decentralized file storage

Pinata - IPFS pinning service

Installation Guide
Prerequisites
Node.js (v16+)

npm (v8+)

MetaMask wallet (with Polygon Mumbai testnet configured)

Pinata account (for IPFS storage)

Frontend Setup
Clone the repository:

bash
git clone https://github.com/your-username/EduVerify.git
cd EduVerify/frontend
Install dependencies:

bash
npm install
Create a .env file in the frontend directory:

env
REACT_APP_EDU_VERIFY_ADDRESS=0xYourEduVerifyContractAddress
REACT_APP_GOVERNOR_ADDRESS=0xYourGovernorContractAddress
REACT_APP_PINATA_API_KEY=your_pinata_api_key
REACT_APP_PINATA_JWT=your_pinata_jwt
Start the development server:

bash
npm start
Smart Contract Deployment (Optional)
To deploy your own contracts:

Install Hardhat:

bash
cd ../contracts
npm install
Configure hardhat.config.js with your wallet and Polygon RPC

Deploy contracts:

bash
npx hardhat run scripts/deploy.js --network polygonMumbai
Configuration
MetaMask Setup
Install MetaMask extension

Connect to Polygon Mumbai Testnet:

Network Name: Mumbai Testnet

RPC URL: https://rpc-mumbai.maticvigil.com/

Chain ID: 80001

Currency Symbol: MATIC

Get test MATIC from Polygon Faucet

Pinata Setup
Create a Pinata account

Get API keys from Dashboard > API Keys

Add keys to your .env file as REACT_APP_PINATA_API_KEY and REACT_APP_PINATA_JWT

Initial Governance Setup
The system comes pre-configured with 3 governor wallets. To access the governance dashboard, use one of these accounts:

0xGovernorAddress1

0xGovernorAddress2

0xGovernorAddress3

Running the Application
Start the frontend:

bash
npm start
Open your browser to: http://localhost:3000

Connect your MetaMask wallet

Depending on your wallet address, you'll see:

Governor Dashboard - If you're one of the initial governors

Institution View - If your address is authorized as an institution

Student/Verifier View - For all other users

Project Structure
text
EduVerify/
├── contracts/                  # Smart contracts
│   ├── EduVerify.sol           # Main credential contract
│   ├── EduVerifyAdmin.sol      # Governance contract
│   ├── scripts/                # Deployment scripts
│   └── test/                   # Smart contract tests
│
├── frontend/                   # React application
│   ├── public/
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── contracts/          # Contract ABIs
│   │   ├── utils/              # Utility functions
│   │   ├── App.js              # Main application
│   │   └── index.js            # Entry point
│   ├── .env                    # Environment variables
│   └── package.json            # Frontend dependencies
│
├── .gitignore
└── README.md                   # This file
Testing
Smart Contract Tests
bash
cd contracts
npx hardhat test
Frontend Testing
bash
cd frontend
npm test
Team
[Your Name]

[Team Member 2]

[Team Member 3]

Course: Blockchain Technologies
Professor: [Professor's Name]
University: [Your University]
Academic Year: 2023-2024

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Polygon team for the excellent documentation

OpenZeppelin for secure contract templates

Pinata for IPFS pinning services

Our professor for guidance and support
