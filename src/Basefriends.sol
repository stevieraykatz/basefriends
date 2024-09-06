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

    /// @notice Struct for storing the connections on a per node basis.
    struct Connections {
        /// @notice Enumerable set of all the nodes that this node "follows".
        EnumerableSetLib.Bytes32Set follows;
        /// @notice Enumerable set of all the nodes that "follow" this node.
        EnumerableSetLib.Bytes32Set followers;
    }

    /// @notice The Basenames registry contract.
    Registry immutable registry;

    /// @notice Each node gets a `version` which can be rolled to clear the `Connections` currently stored for it.
    mapping(bytes32 node => uint64 version) public versions;

    /// @notice The full state `graph` contains `connections` for each `node` on a per `recordVersion` basis. 
    mapping(uint64 recordVersions => mapping(bytes32 node => Connections connections)) public graph;

    /// @notice Thrown when a node does not have a valid resolver.
    error InvalidNode(bytes32 node);
    
    /// @notice Thrown when the sender is not authorized to modify records for the node.
    error NotAuthroized(bytes32 node, address addr);

    /// @notice Emitted when the connection `version` for a node is rolled, clearing the current `Connections`.
    ///
    /// @param node The node which had its `Connections` cleared.
    event ConnectionsCleared(bytes32 indexed node);

    /// @notice Emitted when a `node` gets a `newFollower`. 
    ///
    /// @param node The node that got a new follower.
    /// @param newFollower The node that followed param `node`.
    event FollowerAdded(bytes32 indexed node, bytes32 newFollower);

    /// @notice Emitted when a `node` loses a `removedFollower`. 
    ///
    /// @param node The node that got un-followed.
    /// @param removedFollower The node that un-followed param `node`.
    event FollowerRemoved(bytes32 indexed node, bytes32 removedFollower);

    /// @notice Emitted when a `node` adds `newFollows`.
    ///
    /// @param node The node that added new follows.
    /// @param newFollows The list of all new follows.
    event FollowsAdded(bytes32 indexed node, bytes32[] newFollows);

    /// @notice Emitted when a `node` removes `removedFollows`.
    ///
    /// @param node The node that removed follows.
    /// @param removedFollows The list of all removed follows. 
    event FollowsRemoved(bytes32 indexed node, bytes32[] removedFollows);

    /// @notice Decorator for validating that `msg.sender` owns the `node` in the `registry`.
    /// 
    /// @param node The node being validated. 
    modifier isAuthorized(bytes32 node) {
        address owner = registry.owner(node);
        if (owner != msg.sender) revert NotAuthroized(node, msg.sender);
        _;
    }

    /// @notice constructor
    constructor(address registry_) {
        registry = Registry(registry_);
    }

    /// @notice External mechanism for allowing senders to add follows.
    ///
    /// @dev The sender must be the owner of `node` in the `registry`. 
    ///
    /// @param node The namehash of the Basenames name who is adding follows. 
    /// @param newFollows An array of namehashes of names to follow. 
    function addFollows(bytes32 node, bytes32[] calldata newFollows) external isAuthorized(node) {
        Connections storage connections = _getCurrentConnections(node);

        for (uint256 i; i < newFollows.length; i++) {
            bytes32 follow = newFollows[i];
            _validateNode(follow);
            connections.follows.add(follow);
            _addFollower(follow, node);
        }

        emit FollowsAdded(node, newFollows);
    }

    /// @notice External mechanism for removing follows.
    /// 
    /// @dev The sender must be the owner of `node` in the `registry`. 
    ///
    /// @param node The namehash of the Basenames name who is removing follows. 
    /// @param unFollows The list of nodes to un-follow.
    function removeFollows(bytes32 node, bytes32[] calldata unFollows) external isAuthorized(node) {
        Connections storage connections = _getCurrentConnections(node);

        for (uint256 i; i < unFollows.length; i++) {
            bytes32 follow = unFollows[i];
            connections.follows.remove(follow);
            _removeFollower(follow, node);
        }

        emit FollowsRemoved(node, unFollows);
    }

    /// @notice Method for getting all of the `follows` namehashes for a particular node.
    /// 
    /// @param node The queried node.
    /// 
    /// @return The list of all nodes that `node` follows.  
    function getFollowNodes(bytes32 node) public view returns (bytes32[] memory) {
        Connections storage connections = _getCurrentConnections(node);
        return connections.follows.values();
    }

    /// @notice Method for getting all of the `follows` names for a particular node.
    /// 
    /// @dev This mechanism relies on the fact that the Basenames webapp registration flow writes the
    ///     human-readable "name" to the L2Resolver. We fetch this data from the resolver and 
    ///     return that list of names. Names registered against the contract directly likely will not
    ///     have this record set appropriately and will not be returned by this method.
    /// 
    /// @param node The queried node.
    ///
    /// @return The list of all names that `node` follows. 
    function getFollows(bytes32 node) external view returns (string[] memory) {
        bytes32[] memory follows = getFollowNodes(node);
        string[] memory followNames = new string[](follows.length);
        uint256 acc;
        for (uint256 i; i < follows.length; i++) {
            string memory name = _resolveName(follows[i]);
            if(bytes(name).length !=  0) {
                followNames[acc++] = name;
            }
        }
        return followNames;
    }

    /// @notice Method for getting all of the `followers` nodes for a particular node.
    ///
    /// @param node The queried node.
    /// 
    /// @return The list of all nodes that follow `node`. 
    function getFollowerNodes(bytes32 node) public view returns (bytes32[] memory) {
        Connections storage connections = _getCurrentConnections(node);
        return connections.followers.values();
    }

    /// @notice Method for getting all of the `followes` names for a particular node.
    /// 
    /// @dev This mechanism relies on the fact that the Basenames webapp registration flow writes the
    ///     human-readable "name" to the L2Resolver. We fetch this data from the resolver and 
    ///     return that list of names. Names registered against the contract directly likely will not
    ///     have this record set appropriately and will not be returned by this method. 
    /// 
    /// @param node The queried node.
    /// 
    /// @return The list of all names that follow `node`. 
    function getFollowers(bytes32 node) external view returns (string[] memory) {
        bytes32[] memory followers = getFollowerNodes(node);
        string[] memory followerNames = new string[](followers.length);
        uint256 acc; 
        for (uint256 i; i < followers.length; i++) {
            string memory name = _resolveName(followers[i]);
            if(bytes(name).length !=  0) {
                followerNames[acc++] = name;
            }
        }
        return followerNames;
    }

    function _resolveName(bytes32 node) internal view returns (string memory) {
        address resolver = _getResolverForNode(node);
        return resolver == address(0) ? "" : NameResolver(resolver).name(node);
    }   

    function _getResolverForNode(bytes32 node) internal view returns (address) {
        return registry.resolver(node);
    }

    function _addFollower(bytes32 node, bytes32 follower) internal {
        Connections storage connections = _getCurrentConnections(node);
        connections.followers.add(follower);
        emit FollowerAdded(node, follower);
    }

    function _removeFollower(bytes32 node, bytes32 follower) internal {
        Connections storage connections = _getCurrentConnections(node);
        connections.followers.remove(follower);
        emit FollowerRemoved(node, follower);
    }

    function _validateNode(bytes32 node) internal view {
        if(_getResolverForNode(node) == address(0)) revert InvalidNode(node);
    }

    function clearAll(bytes32 node) external isAuthorized(node) {
        versions[node]++;
    }

    function _getCurrentConnections(bytes32 node) internal view returns (Connections storage) {
        return graph[versions[node]][node];
    }
}
