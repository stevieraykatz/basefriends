// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;


interface IBasefriends {
    function getFollowers(bytes32 node) external view returns (string[] memory);
    function getFollows(bytes32 node) external view returns (string[] memory);
}