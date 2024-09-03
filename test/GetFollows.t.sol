// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {BasefriendsBase} from "./BasefriendsBase.t.sol";
import {Basefriends} from "src/Basefriends.sol";
import {console} from "forge-std/console.sol";

contract GetFollows is BasefriendsBase {
    function test_returnsListOfFollowNames() public {
        vm.prank(userA);
        bf.addFollows(d[userA].node, _getFollowArray());
        string[] memory followNames = bf.getFollows(d[userA].node);

        console.log("UserA Follows:");
        for (uint256 i; i < followNames.length; i++) {
            console.log(followNames[i]);
        }

        console.log("UserB Followers:");
        string[] memory userBFollowerNames = bf.getFollowers(d[userB].node);
        for (uint256 i; i < userBFollowerNames.length; i++) {
            console.log(userBFollowerNames[i]);
        }

        console.log("UserC Followers");
        string[] memory userCFollowerNames = bf.getFollowers(d[userC].node);
        for (uint256 i; i < userCFollowerNames.length; i++) {
            console.log(userCFollowerNames[i]);
        }
    }

    function _getFollowArray() internal view returns (bytes32[] memory) {
        bytes32[] memory newFollows = new bytes32[](2);
        newFollows[0] = d[userB].node;
        newFollows[1] = d[userC].node;
        return newFollows;
    }
}
