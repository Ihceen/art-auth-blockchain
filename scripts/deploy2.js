// Import ethers from hardhat
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Get the address of the deployed ArtNFT contract (replace this with the correct address)
    const artNFTAddress = "0x4169733c4F2D2f2F86e48933e1Cb92547BEA5836";

    // Deploy the Marketplace contract and pass the ArtNFT contract address to the constructor
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy(artNFTAddress); // Pass the ArtNFT address here
    const contract_address=  await marketplace.getAddress();
    console.log("Marketplace contract deployed to:", contract_address);

    // Optionally, you can interact with the Marketplace contract here, for example:
    // - Listing an NFT
    // - Verifying authenticity
    // - Other operations like setting roles or adding features

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
