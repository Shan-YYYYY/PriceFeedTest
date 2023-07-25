// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract XDCOracleTest is PriceFeedTestBase {

    function setUp() public {
        _setUp();
    }

    function test_XDCO_Deployment() public {
        assertEq(xdcOracle.NAME(), "XDCOracle");
        assertEq(xdcOracle.USDC(), 0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
        assertEq(xdcOracle.pool(), curvePool);
    }

    function test_XDCO_getPrice_Success() public {
        uint256 price = xdcOracle.getPrice();
        assertGt(price, 0);
        emit log_uint(price);
    }

    function test_XDCO_isSecondTokenUSDC_Success() public {
        assertTrue(xdcOracle.isSecondTokenUSDC(xdcOracle.pool()));
    }

    
}
