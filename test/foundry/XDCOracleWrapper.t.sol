// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract XDCOracleWrapperTest is PriceFeedTestBase {
    
    function setUp() public {
        _setUp();
    }

    function test_XDCOW_Deployment() public {
        IOracleWrapper.SavedResponse memory savedResponse; 
        (savedResponse.price, savedResponse.lastPrice, savedResponse.updateTime) = xdcOracleWrapper.savedResponse(xdc);
        assertEq(savedResponse.price, 0);
        assertEq(savedResponse.lastPrice, 0);
        assertEq(savedResponse.updateTime, 0);
        assertEq(xdcOracleWrapper.oracle(), address(xdcOracle));
    }

     function test_XDCOW_fetchPrice_Success() public {
        xdcOracleWrapper.fetchPrice(address(xdc));
    }

    function test_XDCOW_retrieveSavedResponse_Success() public {
        xdcOracleWrapper.fetchPrice(xdc);
        IOracleWrapper.SavedResponse memory savedResponse = xdcOracleWrapper.retrieveSavedResponse(xdc);
        assertGt(savedResponse.price, 0);
        assertGt(savedResponse.lastPrice, 0);
        assertGt(savedResponse.updateTime, 0);
    }

    function test_XDCOW_getCurrentPrice_Success() public {
        xdcOracleWrapper.fetchPrice(xdc);
        uint256 curPrice = xdcOracleWrapper.getCurrentPrice(address(xdc));
        assertGt(curPrice, 0);
    }

    function test_XDCOW_getLastPrice_Success() public {
        xdcOracleWrapper.fetchPrice(xdc);
        uint256 lastPrice = xdcOracleWrapper.getLastPrice(address(xdc));
        assertGt(lastPrice, 0);
    }

    function test_XDCOW_getUpdateTime_Success() public {
        xdcOracleWrapper.fetchPrice(xdc);
        uint256 updateTime = xdcOracleWrapper.getUpdateTime(address(xdc));
    }

    function test_XDCOW_getOraclePrice_Success() public {
        uint256 oraclePrice = xdcOracleWrapper.getOraclePrice(address(xdc));
        assertGt(oraclePrice, 0);
    }
}