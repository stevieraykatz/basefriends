// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Basefriends} from "src/Basefriends.sol";

contract AddFollows is Script {
    uint256 pkey = vm.envUint("PRIVATE_KEY");
    address basefriends = vm.envAddress("BASEFRIENDS_ADDRESS");
    function run() public {
        bytes32 myNode = 0x907cf04b19077519eedb812c58f5c6978be3d3f9507e1b530c9a4fd2c3ff1bfc;
        bytes32 friendNode = 0x92989a3525ec0a673a1f3db9770978cd429577929a928a8e5dcddc59bcdc3e79;
        
        bytes32[] memory friends = new bytes32[](1);
        friends[0] = friendNode;

        vm.startBroadcast(pkey);
        Basefriends(basefriends).addFollows(myNode, friends);
    }
}