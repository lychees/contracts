pragma solidity ^0.4.23;
import '../../../lib/ERC721.sol';

/*
    Test crowdsale controller with start time < now < end time
*/
contract CryptoHeroCard is ERC721 {
    mapping (uint256 => uint256) private characterOfToken;
    mapping (uint256 => uint256) private statusOfToken;
    address public DappTokenContractAddr;    

    // Events
    event Claim(address from);
    event Draw(address from);
    
    uint256[] characterRatio = [500, 250, 10, 1];
    uint256 drawPrice = 1;

    function setDappTokenContractAddr(address _addr) public onlyOwner {
        DappTokenContractAddr = _addr;
    }

    function getCharacter(uint256 r) public returns (uint256 offset, uint256 count) {
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

    function getDrawCount(uint256 value) internal returns (uint256 result) {
        return value / drawPrice;
    }

    function getRandomInt(uint256 n) internal returns (uint256 result) {
      /* get a random number. */
      return uint256(keccak256(abi.encodePacked(block.difficulty, now))) % n;
    }

    function isClaimed(uint256 tokenId) public returns (bool result){
        return statusOfToken[tokenId] & 1 == 0;
    }

    function claim() public {
        uint256[] memory tokens = tokensOf(msg.sender);
        uint256[] memory tags = new uint256[](115);
        uint256 counter = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 id = tokens[i];
            if (isClaimed(id)) continue;
            uint256 heroId = characterOfToken[id];
            if (tags[heroId] == 1) continue;
            if (1 <= heroId && heroId <= 108) {
                tags[heroId] = 1;
                counter += 1;
            }            
        }

        if (counter < 108) return;
        emit Claim(msg.sender);
        for (i = 0; i < tokens.length; i++) { 
            id = tokens[i];          
            if (tags[heroId] == 1) continue;
            tags[heroId] = 2;
            statusOfToken[id] |= 1;
        }
    }
  
    /* Issue */
    function drawToken() public payable {
        uint256 n = getDrawCount(msg.value);
        DappTokenContractAddr.transfer(msg.value);
        while (n > 0) {
            uint256 id = total;
            issueToken();
            uint256 offset;
            uint256 count;
            (offset, count) = getCharacter(getRandomInt(45061));
            characterOfToken[id] = offset + getRandomInt(count);
            n -= 1;
        }
    }
}
