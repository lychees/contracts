pragma solidity ^0.4.23;

import "./SmartToken.sol";

/*
 * @param sharedPool is the total shared for every day
 * @param lastTxTime is the address last tx time point
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

contract Sharable is SmartToken {
    using SafeMath for uint256;
    uint256 sharedPool;
    uint256 globalTokenAge;
    uint256 globalLastShareTime;

    mapping(address => uint256) lastShareTime;
    mapping(address => uint256) tokenAge;

    constructor() public {
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
        uint256 delta = tokenAge[_address] / globalTokenAge * sharedPool;        
        _address.transfer(delta);
        sharedPool -= delta;        
        globalTokenAge -= tokenAge[_address];
        tokenAge[_address] = 0;
    }

    function setShared(address _address) internal returns (bool) {
        /*
        uint256 ownedTime;
        uint256 addEth;
        uint256 amount;

        if(lastTxTime[_address] == 0) {
            lastTxTime[_address] = now;
        } else {
            ownedTime = now.sub(lastTxTime[_address]);
            totalTokenAge = now.sub(STARTTIME).mul(totalSupply);
            addEth = ownedTime.mul(balanceOf[_address]).mul(sharedPool).div(totalTokenAge);
            amount = addEth;
            if (amount > 0) {
                addEth = 0;
                _address.transfer(amount);
				if(!_address.transfer(amount)) {
					return false;
				}
			}
            lastTxTime[_address] = now; 
        }
        return true;
        */
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

    function maintainSharedPool() payable  public {
        sharedPool = sharedPool.add(msg.value);
    }
}
