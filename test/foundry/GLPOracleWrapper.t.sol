// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract GLPOracleWrapperTest is PriceFeedTestBase {

    function setUp() public {
        _setUp();
    }
    
    function test_GOW_Deployment() public {
        IOracleWrapper.SavedResponse memory savedResponse; 
        (savedResponse.price, savedResponse.lastPrice, savedResponse.updateTime) = glpOracleWrapper.savedResponse();
        assertEq(savedResponse.price, 0);
        assertEq(savedResponse.lastPrice, 0);
        assertEq(savedResponse.updateTime, 0);
        assertEq(glpOracleWrapper.oracle(), address(glpOracle));
    }

    function test_GOW_retrieveSavedResponse_Success() public {
        glpOracleWrapper.fetchPrice(sGLP);
        IOracleWrapper.SavedResponse memory savedResponse = glpOracleWrapper.retrieveSavedResponse(sGLP);
        assertGt(savedResponse.price, 0);
        assertGt(savedResponse.lastPrice, 0);
        assertGt(savedResponse.updateTime, 0);
    }

    function test_GOW_fetchPrice_Success() public {
        glpOracleWrapper.fetchPrice(sGLP);
    }

    function test_GOW_getCurrentPrice_Success() public {
        glpOracleWrapper.fetchPrice(sGLP);
        uint256 curPrice = glpOracleWrapper.getCurrentPrice(sGLP);
        assertGt(curPrice, 0);
    }

    function test_GOW_getLastPrice_Success() public {
        glpOracleWrapper.fetchPrice(sGLP);
        glpOracleWrapper.fetchPrice(sGLP);
        uint256 lastPrice = glpOracleWrapper.getLastPrice(sGLP);
        assertGt(lastPrice, 0);
    }

    function test_GOW_getUpdateTime_Success() public {
        glpOracleWrapper.fetchPrice(sGLP);
        uint256 updateTime = glpOracleWrapper.getUpdateTime(sGLP);
        assertGt(updateTime, 0);
    }

    function test_GOW_getOraclePrice_Success() public {
        uint256 oraclePrice = glpOracleWrapper.getOraclePrice(sGLP);
        assertGt(oraclePrice, 0);
    }

}