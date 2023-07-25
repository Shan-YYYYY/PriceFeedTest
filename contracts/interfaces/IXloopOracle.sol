// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IXloopOracle {
    /**
     * @notice Fetches the latest price of Xloop in USD.
     * @return The latest price of Xloop in a uint256 format.
     */
    function getXloopPriceInUSD() external view returns (uint256);

    /**
     * @notice Fetches the latest price of Xloop in terms of Wrapped GLP (WGLP).
     * @return xloopPriceInWGLP The latest price of Xloop in terms of WGLP.
     */
    function getXloopPriceInWGlp() external view returns (uint256 xloopPriceInWGLP);
    
    /**
     * @notice Fetches the latest price of Wrapped GLP (WGLP) in USD.
     * @return wGLPPriceInUSD The latest price of WGLP in USD.
     */
    function getWGlpPrice() external view returns (uint256 wGLPPriceInUSD);
}
