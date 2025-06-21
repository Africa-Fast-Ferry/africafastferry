
## 🚀 Smart Contract Deployment Instructions: Africa Fast Ferry Ltd

This guide outlines how to deploy the `AfricaFastFerryToken.sol` smart contract to an Ethereum-compatible blockchain network using Hardhat.

---

### 📦 Prerequisites

Ensure the following are installed:

- [Node.js](https://nodejs.org/)
- [Hardhat](https://hardhat.org/)
- `ethers`, `dotenv`, and `@openzeppelin/contracts`

```bash
npm install --save-dev hardhat
npm install @openzeppelin/contracts ethers dotenv
```

---

### 🛠️ Step-by-Step Deployment Guide

#### 1. **Clone the Repository**

```bash
git clone https://github.com/Africa-Fast-Ferry/africafastferry.git
cd africafastferry
```

#### 2. **Set Up Hardhat**

If not already done:

```bash
npx hardhat init
```

Choose *"Create a basic sample project"*, then follow prompts.

#### 3. **Add the Contract**

Place `AfricaFastFerryToken.sol` inside the `contracts/` directory.

#### 4. **Configure Deployment Script**

Create a file `scripts/deploy.js`:

```js
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const AFF = await hre.ethers.getContractFactory("AfricaFastFerryToken");

  const affeqHolders = [deployer.address];
  const affeqAmounts = [500_000_000];
  const affrHolders = [deployer.address];
  const affrAmounts = [250_000_000];

  const contract = await AFF.deploy(affeqHolders, affeqAmounts, affrHolders, affrAmounts);

  await contract.deployed();
  console.log("Contract deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

#### 5. **Update Hardhat Configuration**

In `hardhat.config.js`, set your network configuration (e.g., for Sepolia or Polygon):

```js
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
```

#### 6. **Create a `.env` File**

```
PRIVATE_KEY=your_wallet_private_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
```

⚠️ **Never share your private key publicly.**

#### 7. **Deploy**

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

---

### ✅ Post Deployment Tasks

- Verify contract on [Etherscan](https://sepolia.etherscan.io/)
- Add contract address to `README.md`
- Update project docs with deployment details
