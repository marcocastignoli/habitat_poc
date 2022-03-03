// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Counter } from "../storage/Counter.sol";

contract LocalFacet {
    function getCounter() external view returns (uint256) {
        Counter.CounterStorage storage ds = Counter.counterStorage();
        return ds.counter;
    }
}
