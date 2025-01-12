// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ArtCertificate.sol"; 

contract Marketplace is AccessControl {
    struct Listing {
        address seller;
        uint256 price; // Price at which the seller wants to sell the NFT
    }

    // Mapping from tokenId to listing information (if listed for sale)
    mapping(uint256 => Listing) private _listings;

    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");

    // Royalties percentage 
    uint256 public constant ROYALTY_PERCENTAGE = 500; // 5%

    // Events
    event ListedForSale(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Sold(address indexed buyer, uint256 indexed tokenId, uint256 price, uint256 royalty);
    event Canceled(address indexed seller, uint256 indexed tokenId);
    event AuthenticityVerified(bool isAuthentic, uint256 indexed tokenId);

    ArtNFT private _artNFT;

    constructor(address artNFTAddress) {
        _artNFT = ArtNFT(artNFTAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant admin role to deployer
        _grantRole(ARTIST_ROLE, msg.sender); // Grant artist role to deployer for testing
        _grantRole(OWNER_ROLE, msg.sender); // Grant owner role to deployer for testing
        _grantRole(BUYER_ROLE, msg.sender); // Grant buyer role to deployer for testing
    }

    // Restrict listing to artists or owners
    modifier onlyArtist() {
        require(hasRole(ARTIST_ROLE, msg.sender), "Caller is not an artist");
        _;
    }

    modifier onlyOwner() {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not an owner");
        _;
    }

    modifier onlyBuyer() {
        require(hasRole(BUYER_ROLE, msg.sender), "Caller is not a buyer");
        _;
    }

    // Function to list an NFT for sale (only owners or artists can list)
    function listNFT(uint256 tokenId, uint256 price) public onlyOwner {
        require(_artNFT.ownerOf(tokenId) == msg.sender, "You must own the NFT to list it.");
        require(price > 0, "Price must be greater than zero.");

        // Transfer the NFT to the marketplace contract
        _artNFT.safeTransferFrom(msg.sender, address(this), tokenId);

        // Store the listing information
        _listings[tokenId] = Listing(msg.sender, price);

        emit ListedForSale(msg.sender, tokenId, price);
    }

    // Function to buy an NFT (only buyers can buy)
    function buyNFT(uint256 tokenId) public payable onlyBuyer {
        Listing memory listing = _listings[tokenId];
        require(listing.price > 0, "NFT is not listed for sale.");
        require(msg.value >= listing.price, "Insufficient funds to purchase.");

        // Calculate royalties
        uint256 royalty = (listing.price * ROYALTY_PERCENTAGE) / 10000;

        // Retrieve the artist's address
        address artist = _artNFT.getTokenMetadata(tokenId).smartContractAddress;

        // Transfer royalty to the artist
        payable(artist).transfer(royalty);

        // Transfer the remaining amount to the seller 
        uint256 sellerAmount = listing.price - royalty;
        payable(listing.seller).transfer(sellerAmount);

        // Transfer the NFT to the buyer
        _artNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        // Remove the listing after purchase
        delete _listings[tokenId];

        emit Sold(msg.sender, tokenId, listing.price, royalty);
    }

    // Function to cancel a listing
    function cancelListing(uint256 tokenId) public onlyOwner {
        Listing memory listing = _listings[tokenId];
        require(listing.seller == msg.sender, "You must be the seller to cancel the listing.");

        // Transfer the NFT back to the seller
        _artNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        // Remove the listing
        delete _listings[tokenId];

        emit Canceled(msg.sender, tokenId);
    }

    // Function to check if an NFT is listed for sale
    function getListing(uint256 tokenId) public view returns (address seller, uint256 price) {
        Listing memory listing = _listings[tokenId];
        return (listing.seller, listing.price);
    }

    // Function to verify the authenticity of an NFT
    function verifyAuthenticity(uint256 tokenId, string memory buyerFingerprint) public {
        // Retrieve the digital fingerprint stored on-chain
        string memory storedFingerprint = _artNFT.getDigitalFingerprint(tokenId);

        // Compare fingerprints
        bool isAuthentic = (keccak256(abi.encodePacked(buyerFingerprint)) == keccak256(abi.encodePacked(storedFingerprint)));

        emit AuthenticityVerified(isAuthentic, tokenId);
    }

    // Admin function to add an artist
    function addArtist(address artist) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ARTIST_ROLE, artist);
    }

    // Admin function to remove an artist
    function removeArtist(address artist) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ARTIST_ROLE, artist);
    }

    // Admin function to add an owner
    function addOwner(address owner) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(OWNER_ROLE, owner);
    }

    // Admin function to remove an owner
    function removeOwner(address owner) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(OWNER_ROLE, owner);
    }

    // Admin function to add a buyer
    function addBuyer(address buyer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BUYER_ROLE, buyer);
    }

    // Admin function to remove a buyer
    function removeBuyer(address buyer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(BUYER_ROLE, buyer);
    }
}
