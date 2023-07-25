// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IXloopOracle.sol";
import "../interfaces/IStableSwap.sol";
import "../interfaces/ICurvePool.sol";

import "forge-std/Test.sol";

contract XDCOracle is Ownable {

    string public constant NAME = "XDCOracle";
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public immutable pool;

    constructor(address _pool) {
        require(_pool != address(0), "Invalid address");
        require(isSecondTokenUSDC(_pool), "Invalid pool");
        pool = _pool;
    }

    /**
     * @notice Get the latest exchange rate. The pool must be set up in a way 
     * that the first token is XDC and the second token is USDC.
     * @return Amount of XDC for 1 USDC sent, i.e., XDC/USDC rate
     */
    function getPrice() external view returns (uint256) {
        // def get_dy(i: int128, j: int128, dx: uint256) -> uint256:
        // """
        // @notice Calculate the current output dy given input dx
        // @dev Index values can be found via the `coins` public getter method
        // @param i Index value for the coin to send
        // @param j Index valie of the coin to recieve
        // @param dx Amount of `i` being exchanged
        // @return Amount of `j` predicted
        return IStableSwap(pool).get_dy(int128(1), int128(0), 1e6);
    }

    /**
     * @notice Returns if the second token in a curve pool is USDC.
     * @param curvePool The curve pool address
     * @return isUSDC True if the second token is USDC
     */
    function isSecondTokenUSDC(address curvePool) public view returns (bool isUSDC) {
        return ICurvePool(curvePool).coins(1) == USDC;
    }
}
