require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // To read from .env

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = process.env.RPC_URL;

module.exports = {
  solidity: {
      compilers: [
          { version: "0.8.18" }, // Add all required versions
          { version: "0.8.20" },
      ],
  },
  networks: {
    customNetwork: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};



