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
    event Draw(address from, uint256 tokenId, uint256 characterId);
    
    uint256[] characterRatio = [500, 250, 10, 1];
    uint256 drawPrice = 1;

    function setDappTokenContractAddr(address _addr) public onlyOwner {
        DappTokenContractAddr = _addr;
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

    function getDrawCount(uint256 value) internal view returns (uint256 result) {
        return value / drawPrice;
    }

    function getRandomInt(uint256 n) internal returns (uint256 result) {
      /* get a random number. */
        return uint256(keccak256(abi.encodePacked(block.difficulty, now))) % n;
    }

    function isClaimed(uint256 tokenId) view public returns (bool result){
        return statusOfToken[tokenId] & 1 == 0;
    }

    function getHeroByTokenId(uint256 tokenId) public view returns(uint256 result) {
        uint256 heroId = characterOfToken[tokenId];
        return heroId;
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
    function drawToken(address _referer) public payable {
        uint256 n = getDrawCount(msg.value);
        if (_referer != 0){
            // uint256 back = msg.value.div(100);
            uint256 back = msg.value / 100;
            _referer.transfer(back);
            // DappTokenContractAddr.transfer(msg.value.div(100).mul(99));
            DappTokenContractAddr.transfer(msg.value / 100 * 99);
        }else{
            DappTokenContractAddr.transfer(msg.value);
        }
        while (n > 0) {
            uint256 id = total;
            issueToken();
            uint256 offset;
            uint256 count;
            (offset, count) = getCharacter(getRandomInt(45061));
            characterOfToken[id] = offset + getRandomInt(count);
            emit Draw(msg.sender, id, characterOfToken[id]);
            n -= 1;
        }
    }
}
