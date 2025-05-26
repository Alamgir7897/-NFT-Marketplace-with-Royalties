// scripts/deploy.js

require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", hre.ethers.utils.formatEther(await deployer.getBalance()), "ETH");

  // Replace with your contract name
  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");

  // If your contract has constructor arguments, add them here
  // Example: const contract = await NFTMarketplace.deploy(arg1, arg2);
  const contract = await NFTMarketplace.deploy();

  await contract.deployed();

  console.log("NFTMarketplace deployed to:", contract.address);

  // Optional: Verify contract on Etherscan if deploying to public network
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for Etherscan verification...");
    await contract.deployTransaction.wait(5); // Wait for confirmations

    try {
      await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [],
      });
      console.log("Contract verified on Etherscan!");
    } catch (error) {
      console.log("Verification error:", error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
