// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Basefriends} from "src/Basefriends.sol";


contract GetFollows is Script {
    bytes32 bundayTestNode =0x662a9ff3da06f381d3d2f2bf46724f7828b8312eaebf8c434f12010532411f06;
    address basefriends = vm.envAddress("BASEFRIENDS_ADDRESS");

    function run() public view {
        string[] memory names;
        names = Basefriends(basefriends).getFollows(bundayTestNode);
        console.log(names[0]);
    }
}