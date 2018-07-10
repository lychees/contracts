pragma solidity ^0.4.23;
import '../../lib/ERC721.sol';

/*
    Test crowdsale controller with start time < now < end time
*/
contract CryptoHeroCard is ERC721 {
    mapping (uint256 => uint256) private characterOfToken;   
    
    uint256[] characterRatio = [500, 250, 10, 1];
    uint256 drawPrice = 1;

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
  
    /* Issue */
    function drawToken() public payable {
        uint256 n = getDrawCount(msg.value);
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
