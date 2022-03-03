// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Counter } from "../storage/Counter.sol";

contract LocalFacetTest {
    function setCounter(uint256 amount) public {
        Counter.CounterStorage storage ds = Counter.counterStorage();
        ds.counter += amount;
    }

}
