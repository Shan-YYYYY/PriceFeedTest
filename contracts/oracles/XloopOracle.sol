// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../libs/OracleLibrary.sol";
import "../interfaces/IGLPOracle.sol";

/**
 * @title XloopOracle
 * @dev This contract is an oracle that gives the price of the xloop token.
 */
contract XloopOracle {

    uint32 public constant TWAP_PERIOD = 10 minutes; // Define the time-weighted average period

    address public immutable wGLP; // Address of the wGLP token
    address public immutable xloop; // Address of the xloop token
    address public immutable uniswapV3Pool; // Address of the Uniswap v3 pool
    IGLPOracle public immutable glpOracle; // Instance of the GLPOracle contract

    /**
     * @dev The constructor sets the initial values of wGLP, xloop, uniswapV3Pool, and glpOracle.
     */
    constructor(
        address _wGLP,
        address _xloop,
        address _uniswapV3Pool,
        address _glpOracle
    ) {
        wGLP = _wGLP;
        xloop = _xloop;
        uniswapV3Pool = _uniswapV3Pool;
        glpOracle = IGLPOracle(_glpOracle);
    }

    /**
     * @dev Returns the price of xloop in terms of USD.
     * The price is calculated by first getting the price of xloop in terms of wGLP from Uniswap v3.
     * Then it gets the price of wGLP in terms of USD from the GLPOracle.
     * Finally, it multiplies these two prices to get the price of xloop in terms of USD.
     * @return The price of xloop in USD.
     */
    function getXloopPriceInUSD() public view returns (uint256) {
        // Get price of xloop in wGLP from Uniswap v3
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(uniswapV3Pool, TWAP_PERIOD);
        uint256 xloopPriceInWGLP = OracleLibrary.getQuoteAtTick(arithmeticMeanTick, 1e18, xloop, wGLP);

        // Get price of wGLP in USD from GLPOracle
        uint256 wGLPPriceInUSD = glpOracle.getPrice();

        // Calculate price of xloop in USD
        return xloopPriceInWGLP * wGLPPriceInUSD / 1e18; // Scale down the result after multiplication to maintain decimal precision
    }

    /**
     * @dev Returns the price of xloop in terms of wGLP from Uniswap v3.
     * @return xloopPriceInWGLP The price of xloop in wGLP.
     */
    function getXloopPriceInWGlp() public view returns (uint256 xloopPriceInWGLP) {
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(uniswapV3Pool, TWAP_PERIOD);
        xloopPriceInWGLP = OracleLibrary.getQuoteAtTick(arithmeticMeanTick, 1e18, xloop, wGLP);
    }

    /**
     * @dev Returns the price of wGLP in terms of USD from GLPOracle.
     * @return wGLPPriceInUSD The price of wGLP in USD.
     */
    function getWGlpPrice() public view returns (uint256 wGLPPriceInUSD) {
        wGLPPriceInUSD = glpOracle.getPrice();
    }
}
