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

    function transfer(address _to, uint256 _value) public transferAllowed returns (bool success) {
        uint256 ownedTime;
        uint256 addEth;
        if(lastTxTime[msg.sender] == 0) {
            lastTxTime[msg.sender] = now;                          
        } else {
            ownedTime = now.sub(lastTxTime[msg.sender]);
            addEth = ownedTime.mul(balanceOf(msg.sender));
            ownedEth[msg.sender] = ownedEth[msg.sender].add(addEth);
            lastTxTime[msg.sender] = now; 
        }

        if(lastTxTime[_to] == 0) {
            lastTxTime[_to] == now;
        } else {
            ownedTime = now.sub(lastTxTime[_to]);
            addEth = ownedTime.mul(balanceOf(_to));
            ownedEth[_to] = ownedEth[_to].add(addEth);

            lastTxTime[_to] = now;
        }

        assert(super.transfer(_to, value));

        return true;
    }
 

    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        uint256 ownedTime;
        uint256 addEth;
        if(lastTxTime[_from] == 0) {
            lastTxTime[_from] = now;                          
        } else {
            ownedTime = now.sub(lastTxTime[_from]);
            addEth = ownedTime.mul(balanceOf(_from));
            ownedEth[_from] = ownedEth[_from].add(addEth);
            lastTxTime[_from] = now; 
        }

        if(lastTxTime[_to] == 0) {
            lastTxTime[_to] == now;
        } else {
            ownedTime = now.sub(lastTxTime[_to]);
            addEth = ownedTime.mul(balanceOf(_to));
            ownedEth[_to] = ownedEth[_to].add(addEth);

            lastTxTime[_to] = now;
        }


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
