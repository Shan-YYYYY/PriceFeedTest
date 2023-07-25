// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IGLPOracle {
    /**
     * @notice Returns the latest price fetched by the oracle.
     * @return The latest price in a uint256 format.
     */
    function getPrice() external view returns (uint256);
}
