pragma solidity ^0.4.23;

import './SmartToken.sol';

/*
 * @param sharedPool is the total shared for every day
 * @param lastTxTime is the address last tx time point
 * @param ownedEth is amount eth(in wei) multiply time(in second) between recent two tx.
 */

contract Sharable is SmartToken {
    uint256 sharedPool;
	uint256 totalTokenAge;
	uint256 constant STARTTIME;

    mapping(address => uint256) lastTxTime;

	constructor() public {
		STARTTIME = now;
	}


    function setShared(address _address) internal returns (bool) {
        uint256 ownedTime;
        uint256 addEth;
		uint256 amount;

        if(lastTxTime[_address] == 0) {
            lastTxTime[_addr1ess] = now;                          
        } else {
            ownedTime = now.sub(lastTxTime[_address]);
			totalTokenAge = now.sub(STARTTIME).mul(totalSupply());
            addEth = ownedTime.mul(balanceOf(_address)).mul(sharedPool).div(totalTokenAge);

			amount = addEth;
			if (amount > 0) {
				addEth = 0;
				if(!_address.transfer(amount)) {
					return false;
				}
			}
            lastTxTime[_address] = now; 
        }
		return true;
    }

    function transfer(address _to, uint256 _value) public transferAllowed returns (bool success) {
        setShared(msg.sender);
        setShared(_to);

        assert(super.transfer(_to, value));
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        setShared(_from);
        setShared(_to);

        assert(super.transferFrom(_from, _to, _value));
        return true;
	}

    function maintainSharedPool() payable {
        sharedPool = sharedPool.add(msg.value);
    }
}
