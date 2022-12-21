// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
 import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
 import "@openzeppelin/contracts/utils/Counters.sol";

import "./IWhitelist.sol";

contract CryptoDev is ERC721Enumerable, ERC721URIStorage, ERC2981, Ownable {
  using Counters for Counters.Counter;
    // string _baseTokenURL;
    string _baseTokenURI;

    Counters.Counter private _tokenIds;

    //  _price is the price of one Crypto Dev NFT
    uint256 public _price = 0.01 ether;

    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // max number of CryptoDevs
    uint256 public maxTokenIds = 10;

    // total number of tokenIds minted
    uint256 public tokenIds;

    // Whitelist contract instance
    IWhitelist whitelist;

    // boolean to keep track of whether presale started or not
    bool public presaleStarted;

    // timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
        _;
}
  constructor (string memory baseURI, address whitelistContract) ERC721("IG Collection", "IG") {
        _setDefaultRoyalty(msg.sender, 500);
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
  }

  function supportsInterface(bytes4 interfaceId)
        public view virtual override(ERC2981, ERC721, ERC721Enumerable)
        returns (bool) {
        return super.supportsInterface(interfaceId);
  }
  
  function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function burnNFT(uint256 tokenId)
        public onlyOwner {
        _burn(tokenId); 
    }

  function startPresale() public onlyOwner {
    presaleStarted = true;

    //Set presaleEnded time as current timestamp + 5minutes
    //Solidity has cool syntax for timestamps (seconds, minutes,hours, days, years)
    presaleEnded = block.timestamp + 5 minutes;
  }

  // dev presaleMint allows a user to mint one NFT per transaction during the presale.

  function presaleMint(address recipient,string memory tokenURI) public payable onlyWhenNotPaused returns (uint256) {
    require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
    require(whitelist.whitelistedAddresses(msg.sender),"You are not whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
    require(msg.value >= _price, "Ether sent is not correct");
    // tokenIds +=1;

    // _safeMinit is a safer version of the _mint function as it ensures that 
    // if the address being minted to is a contract, then it knows how to deal with ERC 721 tokens
    // if the address being minted to is not a contract, it works the same way _mint
    // _safeMint(msg.sender, tokenIds);

    _tokenIds.increment();

     uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
  }

  // dev _baseURL oversides the OpenZeppelin's ERC721 implementation which by default 
  // returned an empty string for the base URI
  function mint(address recipient, string memory tokenURI) public payable onlyWhenNotPaused returns(uint256){
    require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
    require(tokenIds < maxTokenIds, "Exceed maximum IG Collection supply");
    require(msg.value >= _price ,"Ether sent is not correct");
    _tokenIds.increment();

     uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
  }


  // function mintNFT(address recipient, string memory tokenURI)
  //       public onlyOwner
  //       returns (uint256) {
  //       _tokenIds.increment();

  //       uint256 newItemId = _tokenIds.current();
  //       _safeMint(recipient, newItemId);
  //       _setTokenURI(newItemId, tokenURI);

  //       return newItemId;
  //   }

  function mintNFTWithRoyalty(address recipient, string memory tokenURI, address royaltyReceiver, uint96 feeNumerator)
        public onlyOwner
        returns (uint256) {
        uint256 tokenId = mint(recipient, tokenURI);
        _setTokenRoyalty(tokenId, royaltyReceiver, feeNumerator);

        return tokenId;
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function tokenURI(uint256 _tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
    super.tokenURI(_tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 firstTokenId,
    uint256 batchSize
  ) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
  }

  // dev setPaused makes the contract paused or unpaused
  function setPaused(bool val) public onlyOwner {
      _paused = val;
    }
  // dev withdraw sends all the etherin contract ot the owner of the contract
  function withdraw() public onlyOwner {
      address _owner = owner();
      uint256 amout = address(this).balance;
      (bool sent, ) = _owner.call{value: amout}("");
      require(sent, "Failed to send Ether");
    }
  // function to receive Ether, msg.data must be empty
  receive() external payable {}

  // fallback function is called when msg.data is not empty 
  fallback() external payable {}
}