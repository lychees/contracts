pragma solidity ^0.4.23;

contract Minable {
    uint256 public rate_numerator;
    uint256 public rate_denominator;

    constructor() public {
    }
 
    function setRate(uint256 _rate_numerator, uint256 _rate_denominator) public {
        rate_numerator = _rate_numerator;
        rate_denominator = _rate_denominator;
  	}

    function getBonusTokenByEther(uint256 _ether) public returns (uint256 _bonusToken){
        return _ether * rate_numerator / rate_denominator; 
    }
}
