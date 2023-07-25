// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IStableSwap {

    /**
    * @notice Calculate the quantity dy that will be received on swapping quantity dx of token i to token j.
    * @param i The index of token to be swapped from.
    * @param j The index of token to be swapped to.
    * @param dx Quantity of token i to be swapped.
    * @return The amount of token j that will be received.
    */
    function get_dy(
        int128 i, 
        int128 j, 
        uint256 dx
    ) external view returns (uint256);

    /**
    * @notice Swap dx amount of token i to token j. The minimum quantity of token j to be received from this swap is specified by _min_dy. The _receiver will receive the swapped tokens.
    * @param i The index of token to be swapped from.
    * @param j The index of token to be swapped to.
    * @param _dx Quantity of token i to be swapped.
    * @param _min_dy Minimum amount of token j expected to be received from the swap.
    * @param _receiver The address which will receive the swapped tokens.
    * @return Actual amount of token j that was returned from the swap.
    */
    function exchange(
        int128 i, 
        int128 j, 
        uint256 _dx, 
        uint256 _min_dy,
        address _receiver
    ) external returns (uint256);
}
