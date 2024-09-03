// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {BasefriendsBase} from "./BasefriendsBase.t.sol";
import {Basefriends} from "src/Basefriends.sol";

contract AddFollows is BasefriendsBase {
    function test_reverts_ifUnauthorized() public {
        vm.expectRevert(abi.encodeWithSelector(Basefriends.NotAuthroized.selector, d[userA].node, userB));
        vm.prank(userB);
        bf.addFollows(d[userA].node, _getFollowArray());
    }

    function test_allowsNameholder_toAddFollows() public {
        vm.expectEmit(address(bf));
        emit Basefriends.FollowerAdded(d[userB].node, d[userA].node);
        vm.expectEmit(address(bf));
        emit Basefriends.FollowerAdded(d[userC].node, d[userA].node);
        vm.expectEmit(address(bf));
        emit Basefriends.FollowsAdded(d[userA].node, _getFollowArray());
        vm.prank(userA);
        bf.addFollows(d[userA].node, _getFollowArray());
    }

    function _getFollowArray() internal view returns (bytes32[] memory) {
        bytes32[] memory newFollows = new bytes32[](2);
        newFollows[0] = d[userB].node;
        newFollows[1] = d[userC].node;
        return newFollows;
    }
}