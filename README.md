NFT Marketplace with Royalties
This project is a smart contract-based NFT marketplace that supports royalty payments to creators on each secondary sale. The contract is written in Solidity and deployed using Hardhat.

🛠 Features
Mint, list, and sell NFTs

Royalties for creators on secondary sales

Supports ERC-721 standard NFTs

Simple, modular, and easy to extend

📦 Project Structure
bash
Copy
Edit
NFT-Marketplace-with-Royalties/
│
├── contracts/
│   └── NFTMarketplace.sol      # Main smart contract
│
├── scripts/
│   └── deploy.js              # Deployment script
│
├── hardhat.config.js          # Hardhat configuration
├── .env                       # Environment variables (private keys, RPC URLs, etc.)
├── package.json
└── README.md                  # Project documentation
🚀 Deployment
Prerequisites
Node.js & npm

Hardhat installed (npm install --save-dev hardhat)

Create a .env file in the root directory:

PRIVATE_KEY=your_wallet_private_key
RPC_URL=https://goerli.infura.io/v3/YOUR_INFURA_PROJECT_ID
ETHERSCAN_API_KEY=your_etherscan_api_key (optional for contract verification)
Install dependencies

npm install
Compile contracts

npx hardhat compile
Deploy to local Hardhat network

npx hardhat run scripts/deploy.js
Deploy to a testnet (e.g., Goerli)

npx hardhat run scripts/deploy.js --network goerli
Verify on Etherscan (optional)
If you set up the ETHERSCAN_API_KEY in .env, the script will attempt contract verification automatically after deployment.

🧱 Contract
NFTMarketplace.sol
This contract allows users to:

Mint NFTs

List NFTs for sale

Buy NFTs

Ensure royalties are paid to creators on every sale

📚 License
This project is licensed under the MIT License.

💡 Contributing
Contributions are welcome! Please fork the repo, make your changes, and submit a pull request.com

contract address :- OxbF1Ac2a2c8808152159C85e5B00F40CD85F4416c

![image](https://github.com/user-attachments/assets/0edca6eb-46f9-4e17-86b7-4bae9b71dc17)
