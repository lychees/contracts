pragma solidity ^0.4.23;
import "../../lib/ERC721.sol";

/*
    Test crowdsale controller with start time < now < end time
*/
contract CryptoHeroCard is ERC721 {
    mapping (uint256 => uint256) private characterOfToken;
    mapping (uint256 => uint256) private statusOfToken;

    // Events
    event Claim(address from);

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


    function printCard(address to, uint256[] heroIds) external onlyAdmins returns(uint256[] memory tokenIds) {
        uint256 l = heroIds.length;
        tokenIds = new uint256[](l);
        for (uint256 i = 0; i < heroIds.length; i += 1) {
            uint256 heroId = heroIds[i];
            uint256 newTokenId = issueTokenAndTransfer(to);
            characterOfToken[newTokenId] = heroId;
            tokenIds[i] = newTokenId;
        }
        return tokenIds;
    }
}
