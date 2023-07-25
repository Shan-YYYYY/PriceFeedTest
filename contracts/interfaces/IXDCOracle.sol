// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IXDCOracle {
    /**
     * @notice Fetches the latest price of XDC.
     * @return The latest price of XDC in a uint256 format.
     */
    function getPrice() external view returns (uint256);

    /**
     * @notice Determines if the second token in the provided Curve pool is USDC.
     * @param curvePool The address of the Curve pool.
     * @return isUSDC A boolean indicating whether the second token in the Curve pool is USDC.
     */
    function isSecondTokenUSDC(address curvePool) 
        external 
        view 
        returns (bool isUSDC);
}
