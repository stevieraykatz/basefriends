// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Console.sol";
import {Basefriends} from "src/Basefriends.sol";

contract Deploy is Script {
    function run() public {
        address registry = 0x1493b2567056c2181630115660963E13A8E32735; //https://sepolia.basescan.org/address/0x1493b2567056c2181630115660963E13A8E32735

        Basefriends bf = new Basefriends(registry);
        console.log(address(bf));
    }
}
