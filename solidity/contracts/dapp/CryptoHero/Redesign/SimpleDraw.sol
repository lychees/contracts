pragma solidity ^0.4.23;

/*
    No dependency
*/
interface TokenContract {
  function printCard(address to, uint256[] heroIds) external returns(uint256[] memory tokenIds);
  function ownerOf (uint256 _tokenId) external view returns (address _owner);
}

contract CryptoHeroDrawer {
    address contractOwner;
    address tokenContract;
    address sharePoolContractAddr;

    // Events
    event Draw(address from, uint256[] tokenIds, uint256[] characterIds);
    
    uint256[] characterRatio = [500, 250, 10, 1];
    uint256 drawPrice;
    uint256 currentDrawable;

    constructor() public {
        contractOwner = msg.sender;
        drawPrice = 0.00001 ether;
        currentDrawable = 100;
    }

    modifier onlyOwner() {
        assert(msg.sender == contractOwner);
        _;
    }

    function addDrawable(uint256 qty) public onlyOwner {
        currentDrawable += qty;
    }

    function setTokenContract(address _addr) public onlyOwner {
        tokenContract = _addr;
    }

    function setSharePoolContractAddr(address _addr) public onlyOwner {
        sharePoolContractAddr = _addr;
    }

    function getCharacter(uint256 rnd) internal view
    returns (uint256 offset, uint256 count) {
        // to comply the rule: security/no-assign-params
        uint256 r = rnd;
        if (r <= characterRatio[1] * 36) {
            return (1, 36);        
        }
        r -= characterRatio[1] * 36;
        if (r <= characterRatio[0] * 72) {
            return (37, 72);
        }
        r -= characterRatio[0] * 72;
        if (r <= characterRatio[2] * 6) {
            return (109, 6);
        }
        return (0, 1);
    }

    function getDrawPrice() public view returns(uint256 result) {
        return drawPrice;        
    }

    function getDrawCardsLeft() public view returns(uint256 result) {
        return currentDrawable;
    }

    function getDrawCount(uint256 value) internal view returns (uint256 result) {
        return value / drawPrice;
    }

    function getRandomInt(uint256 n) internal returns (uint256 result) {
      /* get a random number. */
        return uint256(keccak256(abi.encodePacked(block.difficulty, now))) % n;
    }
  
    function sendBonusTo(address _referer, uint256 _bonus) internal {
        _referer.transfer(_bonus / 2);
        IDappTokenContract DappTokenContract = IDappTokenContract(sharePoolContractAddr);
        DappTokenContract.transfer(_referer, DappTokenContract.getBonusTokenByEther(_bonus / 2));
    }
    /* Issue */
    function rollDice(address _referer) public payable {
        uint256 n = getDrawCount(msg.value);
        assert(n < currentDrawable);
        uint256[] memory heroIds = new uint256[](n);
        TokenContract issuer = TokenContract(tokenContract);
        
        if (_referer != 0){
            uint256 back = msg.value / 100;
            sendBonusTo(_referer, back);
            sharePoolContractAddr.transfer(msg.value / 100 * 99);
        }else{
            sharePoolContractAddr.transfer(msg.value);
        }
        for (uint256 i = 0; i < n; i++) {
            uint256 offset;
            uint256 count;
            (offset, count) = getCharacter(getRandomInt(45061));
            uint256 heroId = offset + getRandomInt(count);
            heroIds[i] = heroId;
        }
        uint256[] memory tokenIds = issuer.printCard(msg.sender, heroIds);
        currentDrawable -= n;
        emit Draw(msg.sender, tokenIds, heroIds);
    }
}

interface IDappTokenContract {
    function getBonusTokenByEther(uint256 _ether) external view returns (uint256 _bonusToken);
    function transfer(address _to, uint256 _value) external returns (bool success);
}