pragma solidity ^0.4.23;

import "./OwnerableContract.sol";

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author MinakoKojima (https://github.com/lychees)
contract ERC721Interface {
// Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    // function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

contract ERC721 is ERC721Interface, OwnerableContract{
    event Bought (uint256 indexed _tokenId, address indexed _owner, uint256 _price);
    event Sold (uint256 indexed _tokenId, address indexed _owner, uint256 _price);

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    uint256 public total;
    mapping (uint256 => address) private ownerOfToken;
    mapping (uint256 => address) private approvedOfToken;


    constructor() public {
        owner = msg.sender;
        admins[owner] = true;    
    }

    /* ERC721 */
    function name() public view returns (string _name) {
        return "smartsignature.io";
    }

    function symbol() public view returns (string _symbol) {
        return "";
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        return total;
    }

    function balanceOf (address _owner) public view returns (uint256 _balance) {
        uint256 counter = 0;
        for (uint256 i = 0; i < total; i++) {
            if (ownerOf(i) == _owner) {
                counter++;
      			}
        }
        return counter;
    }

    function ownerOf (uint256 _tokenId) public view returns (address _owner) {
        return ownerOfToken[_tokenId];
    }

    function tokensOf (address _owner) public view returns (uint256[] _tokenIds) {
        uint256[] memory Tokens = new uint256[](balanceOf(_owner));
        uint256 TokenCounter = 0;
        for (uint256 i = 0; i < total; i++) {
            if (ownerOf(i) == _owner) {
                Tokens[TokenCounter] = i;
                TokenCounter += 1;
            }
        }
        return Tokens;
    }

    function approvedFor(uint256 _tokenId) public view returns (address _approved) {
      return approvedOfToken[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public {
      require(msg.sender != _to);
      require(ownerOf(_tokenId) == msg.sender);

      if (_to == 0) {
        if (approvedOfToken[_tokenId] != 0) {
          delete approvedOfToken[_tokenId];
          emit Approval(msg.sender, 0, _tokenId);
        }
      } else {
        approvedOfToken[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
      }
    }

    /* Transferring a country to another owner will entitle the new owner the profits from `buy` */
    function transfer(address _to, uint256 _tokenId) public {
      require(msg.sender == ownerOf(_tokenId));
      _transfer(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
      require(approvedFor(_tokenId) == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
      require(ownerOf(_tokenId) == _from);
      require(_to != address(0));
      require(_to != address(this));

      ownerOfToken[_tokenId] = _to;
      approvedOfToken[_tokenId] = 0;

      emit Transfer(_from, _to, _tokenId);
    }

    /* Read */    
    function isAdmin(address _admin) public view returns (bool _isAdmin) {
      return admins[_admin];
    }

    /* Issue */  
    function issueToken() onlyAdmins() public {
        uint256 id = total;
        ownerOfToken[id] = msg.sender;   
    }

    function issueTokenAndTransfer(address to) onlyAdmins() public {
        uint256 id = total;
        ownerOfToken[id] = to;
    }      
}