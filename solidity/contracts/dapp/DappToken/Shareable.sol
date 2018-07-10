pragma solidity ^0.4.23;

import "../../bancor/token/SmartToken.sol";

/*
 * @param ownedEth is amount eth(in wei) multiply time(in second) between recent two tx.
 */

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Shareable is SmartToken {
    using SafeMath for uint256;
    uint256 globalTokenAge;
    uint256 globalLastShareTime;

    mapping(address => uint256) lastShareTime;
    mapping(address => uint256) tokenAge;

    constructor(string _name, string _symbol, uint8 _decimals)
        public
        SmartToken(_name, _symbol, _decimals) {
            globalTokenAge = 0;
            globalLastShareTime = now;
    }

    function updateGlobalTokenAge() internal {
        globalTokenAge += (now - globalLastShareTime) * totalSupply;
        globalLastShareTime = now;
    }

    function updateTokenAge(address _address) internal {
        tokenAge[_address] += (now - lastShareTime[_address]) * balanceOf[_address];    
        lastShareTime[_address] = now;
    }

    function share(address _address) public {    
        updateGlobalTokenAge();
        updateTokenAge(_address);
        uint256 delta = tokenAge[_address] / globalTokenAge * address(this).balance;        
        _address.transfer(delta);   
        globalTokenAge -= tokenAge[_address];
        tokenAge[_address] = 0;
    }

    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        updateTokenAge(msg.sender);
        updateTokenAge(_to);
        assert(super.transfer(_to, _value));
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        updateTokenAge(msg.sender);
        updateTokenAge(_to);
        assert(super.transferFrom(_from, _to, _value));
        return true;
	}
}
