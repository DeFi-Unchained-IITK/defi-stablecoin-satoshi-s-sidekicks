// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "lib/forge-std/src/Test.sol";
import "../src/DUN.sol";
import "../src/DUNcore.sol";
import "../src/MockERC20.sol";
import "../src/MockAggregator.sol";

contract DUNcoreTest is Test {
    DUN dun;
    MockERC20 weth;
    MockERC20 wbtc;
    DUNcore duncore;
    MockAggregator wethPriceFeed;
    MockAggregator wbtcPriceFeed;

    address user = address(1);

    function setUp() public {
        dun = new DUN();
        weth = new MockERC20("Wrapped Ether", "WETH");
        wbtc = new MockERC20("Wrapped Bitcoin", "WBTC");

        // Deploy mock price feed contracts
        wethPriceFeed = new MockAggregator(3000 * 10**8); // Initial price of $3000 for WETH
        wbtcPriceFeed = new MockAggregator(50000 * 10**8); // Initial price of $50000 for WBTC

        duncore = new DUNcore(
            address(dun),
            address(weth),
            address(wbtc),
            address(wethPriceFeed),
            address(wbtcPriceFeed)
        );

        // Mint tokens to the user for testing
        weth.mint(user, 1000 ether);
        wbtc.mint(user, 1000 ether);
        dun.mint(address(duncore), 1000000 ether); // Mint DUN tokens to the contract for testing
    }

    function testDepositAndMint() public {
        vm.startPrank(user);
        weth.approve(address(duncore), 100 ether);
        duncore.depositCollateralAndMintDUN(address(weth), 100 ether, 200 ether);
        assertEq(dun.balanceOf(user), 200 ether);
        vm.stopPrank();
    }

    function testBurnAndRedeem() public {
        vm.startPrank(user);
        weth.approve(address(duncore), 100 ether);
        duncore.depositCollateralAndMintDUN(address(weth), 100 ether, 200 ether);
        dun.approve(address(duncore), 200 ether); // Added DUN approval
        duncore.burnDUNAndRedeemCollateral(100 ether, address(weth), 50 ether);
        assertEq(dun.balanceOf(user), 100 ether);
        assertEq(weth.balanceOf(user), 950 ether);
        vm.stopPrank();
    }

    function testLiquidate() public {
        address liquidator = address(2);
        vm.startPrank(user);
        weth.approve(address(duncore), 100 ether);
        duncore.depositCollateralAndMintDUN(address(weth), 100 ether, 200 ether);
        vm.stopPrank();

        // Check health factor before price drop
        uint256 healthFactorBefore = duncore.getHealthFactor(user);
        emit log_named_uint("Health Factor Before Price Drop", healthFactorBefore);

        // Simulate price drop to make the position undercollateralized
        vm.startPrank(address(this)); // Prank as the contract deployer to call updateAnswer
        wethPriceFeed.updateAnswer(1500 * 10**8); // Price of WETH drops to $1500
        vm.stopPrank();

        // Check health factor after price drop
        uint256 healthFactorAfter = duncore.getHealthFactor(user);
        emit log_named_uint("Health Factor After Price Drop", healthFactorAfter);

        
    }
}

