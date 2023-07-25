// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockXDCToken is ERC20 {

    constructor() ERC20("Xloop Dollar Coin", "XDC") {
        _mint(msg.sender, 1_000_000 * 1e18);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
