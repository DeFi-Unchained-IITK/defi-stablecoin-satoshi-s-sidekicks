// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DUN.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DUNcore {
    DUN public dun;
    IERC20 public weth;
    IERC20 public wbtc;
    AggregatorV3Interface public wethPriceFeed;
    AggregatorV3Interface public wbtcPriceFeed;

    struct UserPosition {
        uint256 wethCollateral;
        uint256 wbtcCollateral;
        uint256 mintedDUN;
    }

    mapping(address => UserPosition) public userPositions;

    uint256 public constant LIQUIDATION_THRESHOLD = 150; // 150%
    uint256 public constant LIQUIDATION_BONUS = 10; // 10%

    constructor(
        address _dun,
        address _weth,
        address _wbtc,
        address _wethPriceFeed,
        address _wbtcPriceFeed
    ) {
        dun = DUN(_dun);
        weth = IERC20(_weth);
        wbtc = IERC20(_wbtc);
        wethPriceFeed = AggregatorV3Interface(_wethPriceFeed);
        wbtcPriceFeed = AggregatorV3Interface(_wbtcPriceFeed);
    }

    function depositCollateralAndMintDUN(address token, uint256 collateralAmount, uint256 mintAmount) external {
        require(token == address(weth) || token == address(wbtc), "Invalid collateral token");

        IERC20 collateralToken = IERC20(token);
        collateralToken.transferFrom(msg.sender, address(this), collateralAmount);

        UserPosition storage position = userPositions[msg.sender];
        if (token == address(weth)) {
            position.wethCollateral += collateralAmount;
        } else if (token == address(wbtc)) {
            position.wbtcCollateral += collateralAmount;
        }

        position.mintedDUN += mintAmount;
        require(getHealthFactor(msg.sender) >= LIQUIDATION_THRESHOLD, "Undercollateralized");

        dun.mint(msg.sender, mintAmount);
    }

    function burnDUNAndRedeemCollateral(uint256 burnAmount, address token, uint256 collateralAmount) external {
        require(token == address(weth) || token == address(wbtc), "Invalid collateral token");

        UserPosition storage position = userPositions[msg.sender];
        require(position.mintedDUN >= burnAmount, "Insufficient DUN balance");
        require((token == address(weth) && position.wethCollateral >= collateralAmount) || (token == address(wbtc) && position.wbtcCollateral >= collateralAmount), "Insufficient collateral balance");

        dun.burnFrom(msg.sender, burnAmount);
        position.mintedDUN -= burnAmount;

        if (token == address(weth)) {
            position.wethCollateral -= collateralAmount;
            weth.transfer(msg.sender, collateralAmount);
        } else if (token == address(wbtc)) {
            position.wbtcCollateral -= collateralAmount;
            wbtc.transfer(msg.sender, collateralAmount);
        }

        require(getHealthFactor(msg.sender) >= LIQUIDATION_THRESHOLD, "Undercollateralized after burn");
    }

    function liquidatePosition(address user, address token, uint256 debtAmount) external {
        require(token == address(weth) || token == address(wbtc), "Invalid collateral token");

        UserPosition storage position = userPositions[user];
        require(getHealthFactor(user) < LIQUIDATION_THRESHOLD, "Cannot liquidate a healthy position");

        uint256 liquidationAmount = debtAmount + (debtAmount * LIQUIDATION_BONUS / 100);
        require((token == address(weth) && position.wethCollateral >= liquidationAmount) || (token == address(wbtc) && position.wbtcCollateral >= liquidationAmount), "Insufficient collateral for liquidation");

        dun.burnFrom(user, debtAmount);
        position.mintedDUN -= debtAmount;

        if (token == address(weth)) {
            position.wethCollateral -= liquidationAmount;
            weth.transfer(msg.sender, liquidationAmount);
        } else if (token == address(wbtc)) {
            position.wbtcCollateral -= liquidationAmount;
            wbtc.transfer(msg.sender, liquidationAmount);
        }

        require(getHealthFactor(user) >= LIQUIDATION_THRESHOLD, "Undercollateralized after liquidation");
    }

    function getHealthFactor(address user) public view returns (uint256) {
        UserPosition storage position = userPositions[user];

        uint256 wethValue = getTokenValue(position.wethCollateral, wethPriceFeed);
        uint256 wbtcValue = getTokenValue(position.wbtcCollateral, wbtcPriceFeed);
        uint256 totalCollateralValue = wethValue + wbtcValue;

        if (position.mintedDUN == 0) {
            return type(uint256).max;
        }

        return (totalCollateralValue * 100) / position.mintedDUN;
    }

    function getTokenValue(uint256 amount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return amount * uint256(price) / 1e8; // Assuming price feed has 8 decimals
    }
}
