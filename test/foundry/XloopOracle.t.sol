// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract XloopOracleTest is PriceFeedTestBase {

    function setUp() public {
        _setUp();
    }
    
    function test_XO_Deployment() public {
        assertEq(xloopOracle.TWAP_PERIOD(), 10 minutes);
        assertEq(xloopOracle.wGLP(), address(wGLP));
        assertEq(xloopOracle.xloop(), address(xloop));
        assertEq(xloopOracle.uniswapV3Pool(), poolAddress);
        assertEq(address(xloopOracle.glpOracle()), address(glpOracle));
    }

    function test_XO_getXloopPriceInUSD_Success() public {
        uint256 price = xloopOracle.getXloopPriceInUSD();
        assertGt(price, 0);
    }

    function test_XO_getXloopPriceInWGlp_Success() public {
        uint256 priceInWGlp = xloopOracle.getXloopPriceInWGlp();
        assertGt(priceInWGlp, 0);
    }

    function test_XO_getWGlpPrice_Success() public {
        uint256 wGlpPrice = xloopOracle.getWGlpPrice();
        assertGt(wGlpPrice, 0);
    }
}