// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC20 } from '@solidstate/contracts/token/ERC20/ERC20.sol';
import { ERC20MetadataStorage } from '@solidstate/contracts/token/ERC20/metadata/ERC20MetadataStorage.sol';
import { MyTokenInit } from "../storage/MyTokenInit.sol";

contract MyToken is ERC20 {
    using ERC20MetadataStorage for ERC20MetadataStorage.Layout;

    function initMyToken() public {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

        MyTokenInit.MyTokenInitStorage storage mti = MyTokenInit.initStorage();

        require(!mti.isInitialized, 'Contract is already initialized!');
        mti.isInitialized = true;

        l.setName("MTK");
        l.setSymbol("MTK");
        l.setDecimals(8);

        _mint(msg.sender, 1000);
    }
}