// Import ethers from hardhat
const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const MyContract = await ethers.getContractFactory("ArtNFT");

    const myContract = await MyContract.deploy();
    const contract_address=  await myContract.getAddress();
    console.log("MyContract deployed to:", contract_address);
    console.log("Deploying contracts with the account:", deployer.address);

    // Get the address of the deployed ArtNFT contract (replace this with the correct address)
    const artNFTAddress = contract_address;

    // Deploy the Marketplace contract and pass the ArtNFT contract address to the constructor
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy(artNFTAddress); // Pass the ArtNFT address here
    const marketplace_address=  await marketplace.getAddress();
    console.log("Marketplace contract deployed to:", marketplace_address);
  }


  
main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
 