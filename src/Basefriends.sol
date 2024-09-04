// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {EnumerableSetLib} from "solady/utils/EnumerableSetLib.sol";
import {Registry} from "basenames/src/L2/Registry.sol";
import {NameResolver} from "ens-contracts/resolvers/profiles/NameResolver.sol";

/// @title Basefriends
///
/// @notice Onchain friends and followers for your basenames. Each name gets two enumerable sets:
///     1. A `follows` set which is the name-holder's "friends".
///     2. A `followers` set which contains all of the names that have added this name to their "friends" list.abi
///
/// @author @stevieraykatz
contract Basefriends {
    using EnumerableSetLib for EnumerableSetLib.Bytes32Set;

    struct Connections {
        EnumerableSetLib.Bytes32Set follows;
        EnumerableSetLib.Bytes32Set followers;
    }

    error NotAuthroized(bytes32 node, address addr);

    event ConnectionsCleared(bytes32 indexed node);
    event FollowerAdded(bytes32 indexed node, bytes32 newFollower);
    event FollowsAdded(bytes32 indexed node, bytes32[] newFollows);

    Registry immutable registry;
    mapping(bytes32 node => uint64 version) public versions;
    mapping(uint64 recordVersions => mapping(bytes32 node => Connections connections)) public graph;

    modifier isAuthorized(bytes32 node) {
        address owner = registry.owner(node);
        if (owner != msg.sender) revert NotAuthroized(node, msg.sender);
        _;
    }

    constructor(address registry_) {
        registry = Registry(registry_);
    }

    function addFollows(bytes32 node, bytes32[] calldata newFollows) external isAuthorized(node) {
        Connections storage connections = graph[versions[node]][node];

        for (uint256 i; i < newFollows.length; i++) {
            bytes32 follow = newFollows[i];
            connections.follows.add(follow);
            _addFollower(follow, node);
        }

        emit FollowsAdded(node, newFollows);
    }

    function removeFollows(bytes32 node, bytes32[] calldata newFollows) external isAuthorized(node) {
        Connections storage connections = _getCurrentConnections(node);

        for (uint256 i; i < newFollows.length; i++) {
            bytes32 follow = newFollows[i];
            connections.follows.remove(follow);
            _removeFollower(follow, node);
        }

        emit FollowsAdded(node, newFollows);
    }

    function getFollowNodes(bytes32 node) public view returns (bytes32[] memory) {
        Connections storage connections = _getCurrentConnections(node);
        return connections.follows.values();
    }

    function getFollows(bytes32 node) external view returns (string[] memory) {
        bytes32[] memory follows = getFollowNodes(node);
        string[] memory followNames = new string[](follows.length);
        for (uint256 i; i < follows.length; i++) {
            followNames[i] = _resolveName(follows[i]);
        }
        return followNames;
    }

    function getFollowerNodes(bytes32 node) public view returns (bytes32[] memory) {
        Connections storage connections = _getCurrentConnections(node);
        return connections.followers.values();
    }

    function getFollowers(bytes32 node) external view returns (string[] memory) {
        bytes32[] memory followers = getFollowerNodes(node);
        string[] memory followerNames = new string[](followers.length);
        for (uint256 i; i < followers.length; i++) {
            followerNames[i] = _resolveName(followers[i]);
        }
        return followerNames;
    }

    function _resolveName(bytes32 node) internal view returns (string memory) {
        address resolver = registry.resolver(node);
        return NameResolver(resolver).name(node);
    }

    function _addFollower(bytes32 node, bytes32 follower) internal {
        Connections storage connections = _getCurrentConnections(node);
        connections.followers.add(follower);
        emit FollowerAdded(node, follower);
    }

    function _removeFollower(bytes32 node, bytes32 follower) internal {
        Connections storage connections = _getCurrentConnections(node);
        connections.followers.remove(follower);
        emit FollowerAdded(node, follower);
    }

    function clearAll(bytes32 node) external isAuthorized(node) {
        versions[node]++;
    }

    function _getCurrentConnections(bytes32 node) internal view returns (Connections storage) {
        return graph[versions[node]][node];
    }
}
