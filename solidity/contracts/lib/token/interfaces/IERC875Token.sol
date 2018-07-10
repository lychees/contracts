pragma solidity ^0.4.23;

/*
    ERC875 Standard Token interface
*/
contract IERC875Token {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function balanceOf(address _owner) public view returns (uint256[] _balances);
    function transfer(address _to, uint256[] _tokens) public;
    function transferFrom(address _from, address _to, uint256[] _tokens) public;

    //optional
    function totalSupply() public view returns (uint256 _totalSupply);
    function trade(uint256 expiryTimeStamp, uint256[] tokenIndices, uint8 v, bytes32 r, bytes32 s) public payable;
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
}