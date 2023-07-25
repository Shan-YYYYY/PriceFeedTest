// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library FullMath {
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // overflow only happens if the result is >= 2^256.
        // in that case, solidity will automatically revert.
        uint256 prod0 = a * b;
        uint256 prod1 = prod0 / denominator;
        return prod1;
    }
}
