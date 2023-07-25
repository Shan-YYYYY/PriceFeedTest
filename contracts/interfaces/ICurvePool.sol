// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface ICurvePool {
    /**
     * @notice Adds liquidity to the pool.
     * @param amounts An array of amounts to add for each coin.
     * @param min_mint_amount The minimum amount of LP tokens to mint from the deposit.
     */
    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external;

    /**
     * @notice Returns the amplification coefficient (A) value of the pool. 
     * @dev A value determines the amplification of the curve and has an impact on the slippage.
     * @return The current A value of the pool.
     */
    function A() external view returns (uint256);

    /**
     * @notice Provides the address of the coin (token) at a given index.
     * @param i The index of the coin.
     * @return The address of the coin at the given index.
     */
    function coins(uint256 i) external view returns (address);

    /**
     * @notice Calculates the amount of coin j that will be received for swapping dx amount of coin i.
     * @param i The index of the input coin.
     * @param j The index of the output coin.
     * @param dx The amount of coin i to be swapped.
     * @return The amount of coin j that will be received.
     */
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);
}
