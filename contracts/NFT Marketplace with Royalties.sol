// SPDX-License-Identifier: mit
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title NFT Marketplace with Royalties
 * @dev A decentralized marketplace for NFTs with automatic royalty distribution
 */
contract NFTMarketplace is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard, IERC721Receiver {
    uint256 public constant MARKETPLACE_FEE = 250; // 2.5% in basis points
    uint256 public constant BASIS_POINTS = 10000;

    uint256 private _tokenIdCounter;

    struct RoyaltyInfo {
        address creator;
        uint256 percentage; // in basis points
    }

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => RoyaltyInfo) private _royalties;
    mapping(address => uint256) private _earnings;
    mapping(uint256 => Listing) private _listings;

    // Events
    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI, uint256 royaltyPercentage);
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTDelisted(uint256 indexed tokenId, address indexed seller);
    event RoyaltyPaid(uint256 indexed tokenId, address indexed creator, uint256 amount);

    constructor() ERC721("NFT Marketplace", "NFTM") Ownable(msg.sender) {}

    // Mint NFT with royalty info
    function mintNFT(
        address to,
        string memory uri,
        uint256 royaltyPercentage
    ) public returns (uint256) {
        require(royaltyPercentage <= 1000, "Royalty cannot exceed 10%");
        require(bytes(uri).length > 0, "Token URI cannot be empty");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _royalties[tokenId] = RoyaltyInfo({
            creator: to,
            percentage: royaltyPercentage
        });

        emit NFTMinted(tokenId, to, uri, royaltyPercentage);
        return tokenId;
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can list");
        require(price > 0, "Price must be greater than 0");
        require(!_listings[tokenId].active, "NFT already listed");

        safeTransferFrom(msg.sender, address(this), tokenId);

        _listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });

        emit NFTListed(tokenId, msg.sender, price);
    }

    function purchaseNFT(uint256 tokenId) public payable nonReentrant {
        Listing memory listing = _listings[tokenId];
        require(listing.active, "NFT not listed");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;
        uint256 price = listing.price;
        _listings[tokenId].active = false;

        uint256 marketplaceFee = (price * MARKETPLACE_FEE) / BASIS_POINTS;
        uint256 royaltyAmount = 0;
        address creator = _royalties[tokenId].creator;

        if (seller != creator) {
            royaltyAmount = (price * _royalties[tokenId].percentage) / BASIS_POINTS;
        }

        uint256 sellerAmount = price - marketplaceFee - royaltyAmount;

        _safeTransfer(address(this), msg.sender, tokenId, "");

        _earnings[owner()] += marketplaceFee;
        _earnings[seller] += sellerAmount;

        if (royaltyAmount > 0) {
            _earnings[creator] += royaltyAmount;
            emit RoyaltyPaid(tokenId, creator, royaltyAmount);
        }

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    function delistNFT(uint256 tokenId) public {
        require(_listings[tokenId].seller == msg.sender, "Only seller can delist");
        require(_listings[tokenId].active, "NFT not listed");

        _listings[tokenId].active = false;

        _safeTransfer(address(this), msg.sender, tokenId, "");

        emit NFTDelisted(tokenId, msg.sender);
    }

    function withdrawEarnings() public nonReentrant {
        uint256 amount = _earnings[msg.sender];
        require(amount > 0, "No earnings");

        _earnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // ========== View Functions ==========

    function getListing(uint256 tokenId) public view returns (Listing memory) {
        return _listings[tokenId];
    }

    function getRoyaltyInfo(uint256 tokenId) public view returns (address creator, uint256 percentage) {
        RoyaltyInfo memory royalty = _royalties[tokenId];
        return (royalty.creator, royalty.percentage);
    }

    function getEarnings(address user) public view returns (uint256) {
        return _earnings[user];
    }

    function getTotalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    // ========== Overrides ==========

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId); 
    }
}





