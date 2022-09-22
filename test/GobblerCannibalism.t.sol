// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ArtGobblers } from "art-gobblers/ArtGobblers.sol";
import { Goo } from "art-gobblers/Goo.sol";
import { Pages } from "art-gobblers/Pages.sol";
import { RandProvider } from "art-gobblers/utils/rand/RandProvider.sol";
import { Utilities } from "../lib/art-gobblers/test/utils/Utilities.sol";

import "../src/GobblerCannibalism.sol";

contract GobblerCannibalismTest is Test {
    // ArtGobblers contract
    ArtGobblers gobblers;

    // Cannibal-ready contract
    GobblerCannibalism menu;

    // Test user
    address malory = address(0x69);

    function setUp() public {
        Utilities utils = new Utilities();

        // Mocks
        address pages = address(0xbeef);
        address randProvider = address(0xa4dee);

        // Deploy Goo
        Goo goo = new Goo(utils.predictContractAddress(address(this), 1), pages);

        // Deploy ArtGobblers
        gobblers = new ArtGobblers(
            keccak256(""),
            block.timestamp,
            goo,
            Pages(pages),
            address(0),
            address(0),
            RandProvider(randProvider),
            "base",
            ""
        );

        // Deploy Cannibalism contract
        menu = new GobblerCannibalism(address(gobblers));

        /// Prime user balance with ArtGobblers

        // 1. Get some Goo
        vm.startPrank(address(gobblers));
        goo.mintForGobblers(malory, gobblers.gobblerPrice() * 3);
        vm.stopPrank();

        // 2. Mint 2 Gobblers
        vm.startPrank(malory);
        gobblers.mintFromGoo(gobblers.gobblerPrice(), false);
        gobblers.mintFromGoo(gobblers.gobblerPrice(), false);
        vm.stopPrank();

        // 3. Verify ownership
        assertEq(gobblers.ownerOf(1), malory);
        assertEq(gobblers.ownerOf(2), malory);
        assertEq(gobblers.balanceOf(malory), 2);
    }

    /// @notice Test that you can cook and cannibalize a Gobbler successfully.
    function testCook() public {
        vm.startPrank(malory);

        // Preconditions
        assertEq(menu.balanceOf(malory), 0);

        // cook Gobbler
        uint256 gobblerId = 1;
        gobblers.approve(address(menu), gobblerId);
        menu.cook(gobblerId);

        // Verify cooked ownership
        uint256 cookedId = 1;
        assertEq(menu.ownerOf(cookedId), malory);
        assertEq(menu.balanceOf(malory), 1);

        // cannibalize Gobbler
        uint256 cannibalGobblerId = 2;
        menu.approve(address(gobblers), cookedId);
        gobblers.gobble(cannibalGobblerId, address(menu), cookedId, false);
    }
}
