// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Counter } from "../storage/Counter.sol";
import { LibVotingPower } from '../libraries/LibVotingPower.sol';

contract LocalFacetTest {
    function setCounter(uint256 amount) public {
        Counter.CounterStorage storage ds = Counter.counterStorage();
        ds.counter += amount;
    }

    // function increaseVotingPower(address _address, uint _power) public {
    //     Counter.CounterStorage storage ds = Counter.counterStorage();
    //     ds.votingPower[_address] += _power;
    // }

    function increaseVotingPower(address _address, uint _power) public {
        LibVotingPower._increaseVotingPower(_address, _power);
    }
    
}
