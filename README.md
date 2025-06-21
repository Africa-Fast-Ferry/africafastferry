# Africa Fast Ferry Ltd Security Token Contracts

Welcome to the official smart contract repository for **Africa Fast Ferry Ltd**, a tokenized infrastructure project focused on building and operating high-speed ferry systems across Africa.

This repository contains the production-grade Ethereum smart contract code implementing **AFFEQ** (Equity Tokens) and **AFFR** (Revenue Tokens), based on the **ERC-3643 / ERC-1400** standards for compliant digital securities.

## 🔐 Token Overview

| Token | Symbol  | Supply          | Purpose                        |
|-------|---------|------------------|--------------------------------|
| Equity Token  | AFFEQ   | 500,000,000    | Represents ownership in Africa Fast Ferry Ltd |
| Revenue Token | AFFR    | 250,000,000    | Entitles holders to a share of project revenue |

---

## ⚙️ Core Features

- Fully compliant with **SEC Reg D Rule 506(c)** and **Regulation S**
- Whitelisting & KYC enforcement
- Transfer restrictions during lockup period (365 days)
- Pausable and upgradeable architecture
- Revenue-sharing mechanism for AFFR holders
- Role-based access control using OpenZeppelin's `AccessControl`
- Optimized for **enterprise-grade security**

---

## 📁 Folder Structure

```
contracts/             → Solidity smart contracts
├── AfricaFastFerryToken.sol

scripts/               → Deployment scripts (optional)

test/                  → Test files (optional)

README.md              → This file
LICENSE                → MIT License
.gitignore             → Ignored build files
```

---

## 🚀 Deployment

These contracts are written in Solidity `^0.8.20`. Use [Hardhat](https://hardhat.org/) or [Foundry](https://book.getfoundry.sh/) for deployment and testing.

> Deployment and upgrade scripts will be added as the project progresses.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🛠 Contributors

**Smart Contract Architecture:** Cascadia Blockchain  
**Project Sponsor:** Africa Fast Ferry Ltd  
**Security Token Framework:** Based on ERC-3643  
**Governance:** Abba Platforms Inc.  

---

## 🌐 More Info

Visit the project website [africafastferry.com](https://africafastferry.com)  
Follow us on [LinkedIn](https://linkedin.com/company/africafastferry)  
