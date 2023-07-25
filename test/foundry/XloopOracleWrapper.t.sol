// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract XloopOracleWrapperTest is PriceFeedTestBase {

    function setUp() public {
        _setUp();
    }
    
    function test_XOW_Deployment() public {
        IOracleWrapper.SavedResponse memory savedResponse;
        (savedResponse.price, savedResponse.lastPrice, savedResponse.updateTime) = xloopOracleWrapper.savedResponse(xloop);
        assertEq(savedResponse.price, 0);
        assertEq(savedResponse.lastPrice, 0);
        assertEq(savedResponse.updateTime, 0);
        assertEq(address(xloopOracleWrapper.xloopOracle()),address(xloopOracle));
    }

     function test_XOW_retrieveSavedResponse_Success() public {
        xloopOracleWrapper.fetchPrice(address(xloop));
        IOracleWrapper.SavedResponse memory savedResponse = xloopOracleWrapper.retrieveSavedResponse(xloop);
        assertGt(savedResponse.price, 0);
        assertGt(savedResponse.lastPrice, 0);
        assertGt(savedResponse.updateTime, 0);
    }

    function test_XOW_fetchPrice_Success() public {
        xloopOracleWrapper.fetchPrice(address(xloop));
    }

    function test_XOW_getPrice_Success() public {
        xloopOracleWrapper.fetchPrice(xloop);
        uint256 curPrice = xloopOracleWrapper.getCurrentPrice(address(xloop));
        assertGt(curPrice, 0);
    }

    function test_XOW_getLastPrice_Success() public {
        xloopOracleWrapper.fetchPrice(xloop);
        uint256 lastPrice = xloopOracleWrapper.getLastPrice(address(xloop));
        assertGt(lastPrice, 0);
    }

    function test_XOW_getUpdateTime_Success() public {
        xloopOracleWrapper.fetchPrice(xloop);
        uint256 updateTime = xloopOracleWrapper.getUpdateTime(address(xloop));
    }

    function test_XOW_getOraclePrice_Success() public {
        uint256 oraclePrice = xloopOracleWrapper.getOraclePrice(address(xloop));
        assertGt(oraclePrice, 0);
    }
}