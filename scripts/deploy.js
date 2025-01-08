// Import ethers from hardhat
const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const MyContract = await ethers.getContractFactory("ArtCertificate");
    const myContract = await MyContract.deploy();
    const contract_address=  await myContract.getAddress();
    // console.log("Deployed address:" + myContract.address);
    console.log("MyContract deployed to:", contract_address);
  }


  
main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
 