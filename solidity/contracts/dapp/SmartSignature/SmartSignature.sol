pragma solidity ^0.4.23;

import '../../lib/ERC721.sol';
import '../../lib/AddressUtils.sol';

contract SmartSignature is ERC721{
    using AddressUtils for address;
    address DappTokenContractAddr;    
    mapping (uint256 => mapping(address => uint256)) public balanceOfSign;

    modifier onlySignOwner(uint256 _signId) {
        require(msg.sender == ownerOf(_signId),
            "Only owner can call this function."
        );
        _;
    }        

    constructor() public {
        owner = msg.sender;
        admins[owner] = true;    
    }

    function withdrawFromSign(uint256 _signId) onlySignOwner(_signId) public {
        // To be implement.
        uint256 value = balanceOfSign[_signId][msg.sender];
        balanceOfSign[_signId][msg.sender] = 0;
        msg.sender.transfer(value / 2);
        IDappTokenContract DappTokenContract = IDappTokenContract(DappTokenContractAddr);
        DappTokenContract.transfer(_referer, DappTokenContract.getBonusTokenByEther(value / 2));
    }
}

interface IDappTokenContract {
    function getBonusTokenByEther(uint256 _ether) external view returns (uint256 _bonusToken);
    function transfer(address _to, uint256 _value) external returns (bool success);
}