// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//burnable is automatically inheriited from ERC20 burnable
contract DUN is ERC20, ERC20Burnable {
    constructor() ERC20("DUN Stablecoin", "DUN") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
