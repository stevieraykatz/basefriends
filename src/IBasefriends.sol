// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IBasefriends {
    function getFollowNodes(bytes32 node) external view returns (bytes32[] memory);
    function getFollowers(bytes32 node) external view returns (string[] memory);
    function getFollowerNodes(bytes32 node) external view returns (bytes32[] memory);
    function getFollows(bytes32 node) external view returns (string[] memory);
}
