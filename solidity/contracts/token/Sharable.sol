pragma solidity ^0.4.23;

import './SmartToken.sol';

/*
 * @param sharedPool is the total shared for every day
 * @param lastTxTime is the address last tx time point
 * @param ownedEth is amount eth(in wei) multiply time(in second) between recent two tx.
 */

contract Sharable is SmartToken {
    uint256 sharedPool;
    mapping(address => uint256) lastTxTime; 
    mappign(address => uint265) ownedEth;

    function setShared(address _address) internal {
        uint256 ownedTime;
        uint256 addEth;
        if(lastTxTime[_address] == 0) {
            lastTxTime[_address] = now;                          
        } else {
            ownedTime = now.sub(lastTxTime[_address]);
            addEth = ownedTime.mul(balanceOf(_address));
            ownedEth[_address] = ownedEth[_address].add(addEth);
            lastTxTime[_address] = now; 
        }
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

    function getEth() public {
        uint256 amount = ownedEth[msg.sender];

        if(amount > 0) {
            ownedEth[msg.sender] = 0;
            uint256 realEth = sharedPool.mul( ownedEth[msg.sender].div(totalSupply().mul(1 day)) );
            if (!msg.sender.send(realEth)) {
                ownedEth[msg.sender] = amount;
                return false;
            }

        }
        return true;
    } 
}
