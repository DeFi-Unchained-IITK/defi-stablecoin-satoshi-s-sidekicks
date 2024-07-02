// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/DUN.sol";
import "../src/DUNcore.sol";
import "../src/MockERC20.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        MockERC20 wethToken = new MockERC20("Wrapped Ether", "WETH");
        MockERC20 wbtcToken = new MockERC20("Wrapped Bitcoin", "WBTC");
        DUN dunToken = new DUN();

        address wethPriceFeed = 0xCc72039A141c6e34a779eF93AEF5eB4C82A893c7;  // Replace with actual WETH price feed address
        address wbtcPriceFeed = 0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;  // Replace with actual WBTC price feed address

        DUNcore duncore = new DUNcore(address(dunToken), address(wethToken), address(wbtcToken), wethPriceFeed, wbtcPriceFeed);

        vm.stopBroadcast();
    }
}
