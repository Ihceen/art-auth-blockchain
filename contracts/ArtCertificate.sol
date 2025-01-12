// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ArtNFT is ERC721, AccessControl {
    uint256 public tokenCounter;

    // Define a custom role for artists
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");

    // Mapping from token ID to metadata
    mapping(uint256 => Metadata) private _tokenMetadata;

    // Event to emit when an NFT is minted
    event ArtNFTMinted(address indexed creator, uint256 tokenId, string tokenURI);

    // Struct to store all the metadata on-chain
    struct Metadata {
        string artistName;
        string artworkTitle;
        string artworkDescription;
        uint256 creationDate;
        string digitalFingerprint; // Hash of the artwork file
        address smartContractAddress; // The address of the contract
        string ipfsHash; // IPFS link where the artwork is stored
    }

    constructor() ERC721("ArtNFT", "ART") {
        // Grant the deployer the admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // Grant the deployer the artist role for testing
        _grantRole(ARTIST_ROLE, msg.sender);

        tokenCounter = 0; 
    }

    // Override supportsInterface to resolve ambiguity
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // check if the sender has the artist role
    modifier onlyArtist() {
        require(hasRole(ARTIST_ROLE, msg.sender), "Caller is not an artist");
        _;
    }

    // Function to mint a new NFT, restricted to artists only
    function mintNFT(
        string memory artistName,
        string memory artworkTitle,
        string memory artworkDescription,
        string memory digitalFingerprint,
        string memory ipfsHash
    ) public onlyArtist {
        uint256 newTokenId = tokenCounter;

        // Create Metadata struct for the NFT
        Metadata memory metadata = Metadata({
            artistName: artistName,
            artworkTitle: artworkTitle,
            artworkDescription: artworkDescription,
            creationDate: block.timestamp,  
            digitalFingerprint: digitalFingerprint,
            smartContractAddress: address(this),  
            ipfsHash: ipfsHash  
        });

        // Mint the NFT
        _safeMint(msg.sender, newTokenId);  
        _setTokenMetadata(newTokenId, metadata);  

        tokenCounter++;  
        
        emit ArtNFTMinted(msg.sender, newTokenId, ipfsHash);  
    }

    // Function to store metadata for the token
    function _setTokenMetadata(uint256 tokenId, Metadata memory metadata) internal {
        _tokenMetadata[tokenId] = metadata;
    }

    // Function to retrieve the metadata for a particular token
    function getTokenMetadata(uint256 tokenId) public view returns (Metadata memory) {
        return _tokenMetadata[tokenId];
    }

    // Public function to get the digital fingerprint 
    function getDigitalFingerprint(uint256 tokenId) public view returns (string memory) {
        return _tokenMetadata[tokenId].digitalFingerprint;
    }

    // Admin function to add an artist
    function addArtist(address artist) public {
        grantRole(ARTIST_ROLE, artist); 
    }

    // Admin function to remove an artist
    function removeArtist(address artist) public {
        revokeRole(ARTIST_ROLE, artist); 
    }
}
