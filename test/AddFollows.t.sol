// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {BasefriendsBase} from "./BasefriendsBase.t.sol";
import {Basefriends} from "src/Basefriends.sol";

contract AddFollows is BasefriendsBase {
    function test_reverts_ifUnauthorized() public {
        vm.expectRevert(abi.encodeWithSelector(Basefriends.NotAuthroized.selector, records[userA].node, userB));
        vm.prank(userB);
        bf.addFollows(records[userA].node, _getFollowArray());
    }

    function test_allowsNameholder_toAddFollows() public {
        vm.prank(userA);
        bf.addFollows(records[userA].node, _getFollowArray());
    }

    function _getFollowArray() internal view returns (bytes32[] memory) {
        bytes32[] memory newFollows = new bytes32[](2);
        newFollows[0] = records[userB].node;
        newFollows[1] = records[userC].node;
        return newFollows;
    }
}