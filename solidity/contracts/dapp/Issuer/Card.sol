pragma solidity ^0.4.23;
import '../../lib/ERC721.sol';

/*
    Test crowdsale controller with start time < now < end time
*/
contract CryptoHeroCard is ERC721 {
    mapping (uint256 => address) private characterOfToken;   
    
    uint256[] characterRatio = [500, 250, 10, 1];

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

    /* Issue */  
    function drawToken() public payable {
        uint256 id = total;
        ownerOfToken[id] = msg.sender;   
    }
}
