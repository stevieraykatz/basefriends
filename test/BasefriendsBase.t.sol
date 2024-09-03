// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";
import {Basefriends} from "src/Basefriends.sol";
import {Registry} from "basenames/src/L2/Registry.sol";
import {ETH_NODE, BASE_ETH_NODE} from "basenames/src/util/Constants.sol";
import {MockNameResolver} from "basenames/test/mocks/MockNameResolver.sol";

contract BasefriendsBase is Test {
    Basefriends public bf;
    Registry public registry;
    MockNameResolver public resolver;

    struct Data {
        bytes32 node;
        string name;
    }

    address owner = makeAddr("owner");
    address userA = makeAddr("A");
    address userB = makeAddr("B");
    address userC = makeAddr("C");
    mapping(address user => Data data) public d;

    function setUp() public {
        registry = new Registry(owner);
        bf = new Basefriends(address(registry));
        resolver = new MockNameResolver();
        _establishNamespace();
        _establishNameFor(userA, "alice");
        _establishNameFor(userB, "bob");
        _establishNameFor(userC, "charlie");
    }

    function _establishNamespace() public virtual {
        bytes32 ethLabel = keccak256("eth");
        bytes32 baseLabel = keccak256("base");
        vm.prank(owner);
        registry.setSubnodeOwner(0x0, ethLabel, owner);
        vm.prank(owner);
        registry.setSubnodeOwner(ETH_NODE, baseLabel, owner);
    }

    function _establishNameFor(address nameOwner, string memory name) internal {
        bytes32 nameLabel = keccak256(bytes(name));
        vm.prank(owner);
        bytes32 node = registry.setSubnodeOwner(BASE_ETH_NODE, nameLabel, nameOwner);
        vm.startPrank(nameOwner);
        registry.setResolver(node, address(resolver));
        resolver.setName(node, name);
        d[nameOwner].name = name;
        d[nameOwner].node = node;
        vm.stopPrank();
    }
}
