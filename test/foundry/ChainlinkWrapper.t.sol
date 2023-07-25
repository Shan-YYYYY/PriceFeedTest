// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/Imports.sol";
import "./utils/PriceFeedTestBase.sol";

import "forge-std/Test.sol";

contract ChainlinkWrapperTest is PriceFeedTestBase {
    
    event OracleAdded(address indexed _token, address _priceAggregator);
    event OracleRemoved(address indexed _token);

    function setUp() public {
        _setUp();
    }
    
    function test_CW_Deployment() public {
        assertEq(chainlinkWrapper.NAME(), "ChainlinkWrapper");
        assertEq(chainlinkWrapper.SEQUENCER_UPTIME_FEED(), 0xFdB631F5EE196F0ed6FAa767959853A9F217697D);
        assertEq(chainlinkWrapper.TARGET_DIGITS(), 18);
        assertEq(chainlinkWrapper.GRACE_PERIOD_TIME(), 3600);
        assertEq(chainlinkWrapper.TIMEOUT(), 4 hours);
        assertEq(address(chainlinkWrapper.aggregators(address(0))), address(0));
        assertEq(chainlinkWrapper.owner(), address(this));
    }

    function test_CW_GMXORACLE_latestRoundData_Success() public {
        AggregatorV3Interface aggregator = AggregatorV3Interface(CHAINLINK_GMX_USD_ORACLE);
        (
            uint80 roundId, 
            int256 answer, 
            uint256 startedAt, 
            uint256 updatedAt, 
            uint80 answeredInRound
        ) = aggregator.latestRoundData();
        assertGt(roundId, 0);
        assertGt(answer, 0);
        assertGt(startedAt, 0);
        assertGt(updatedAt, 0);
        assertGt(answeredInRound, 0);    
    }

    function test_CW_retrieveSavedResponse_Success() public {
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        IChainlinkWrapper.SavedResponse memory savedResponse = chainlinkWrapper.retrieveSavedResponse(GMX);
        assertGt(savedResponse.price, 0);
        assertGt(savedResponse.lastPrice, 0);
        assertGt(savedResponse.updateTime, 0);
    }

    // TODO: this test is not complete. Need to figure out the result of calling fetchPrice
    function test_CW_fetchPrice_Success() public {
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        chainlinkWrapper.fetchPrice(GMX);
    }

    function test_CW_addOracle_Success() public {
        assertEq(address(chainlinkWrapper.aggregators(GMX)), address(0));
        vm.expectEmit(true, true, true, true);
        emit OracleAdded(GMX, CHAINLINK_GMX_USD_ORACLE);
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        assertEq(address(chainlinkWrapper.aggregators(GMX)), CHAINLINK_GMX_USD_ORACLE);
    }

    function test_CW_removeOracle_Success() public {
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        assertEq(address(chainlinkWrapper.aggregators(GMX)), CHAINLINK_GMX_USD_ORACLE);
        vm.expectEmit(true, true, true, true);
        emit OracleRemoved(GMX);
        chainlinkWrapper.removeOracle(GMX);
        assertEq(address(chainlinkWrapper.aggregators(GMX)), address(0));
    }

    function test_CW_getCurrentPrice_Success() public {
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        uint256 currentPrice = chainlinkWrapper.getCurrentPrice(GMX);
        assertGt(currentPrice, 0);
    }
     
    function test_CW_getLastPrice_Success() public  {
        chainlinkWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        uint256 lastPrice = chainlinkWrapper.getLastPrice(GMX);
        assertGt(lastPrice, 0);
    }

    function test_CW_retrieveSavedResponse_GivenZeroTokenAddress_Fail() public {
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, address(0));
        vm.expectRevert(revertError);
        chainlinkWrapper.retrieveSavedResponse(address(0));
    }

    function test_CW_retrieveSavedResponse_GivenNotRegisteredToken_Fail() public {
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, USDC);
        vm.expectRevert(revertError);
        chainlinkWrapper.retrieveSavedResponse(USDC);
    }

    // TODO: this can be expanded into a few more cases
    function test_CW_retrieveSavedResponse_GivenBrokenOracle_ReturnOldValues_Success() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        chainlinkWrapper.addOracle(GMX, address(assetOracle));
        IChainlinkWrapper.SavedResponse memory lastResponse = chainlinkWrapper.retrieveSavedResponse(GMX);
        assetOracle.setUp(0, 0, 0, 0, false);
        IChainlinkWrapper.SavedResponse memory response = chainlinkWrapper.retrieveSavedResponse(GMX);
        assertEq(response.price, lastResponse.price);
        assertEq(response.lastPrice, lastResponse.lastPrice);
        assertEq(response.updateTime, lastResponse.updateTime);
    }

    function test_CW_fetchPrice_GivenZeroTokenAddress_Fail() public {
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, address(0));
        vm.expectRevert(revertError);
        chainlinkWrapper.fetchPrice(address(0));
    }

    // TODO: bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, USDC);
    // This can be put in a private function and called by all the tests that need it
    function test_CW_fetchPrice_GivenNotRegisteredToken_Fail() public {
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, USDC);
        vm.expectRevert(revertError);
        chainlinkWrapper.fetchPrice(USDC);
    }

    function test_CW_fetchPrice_GivenBokenOracle_ReturnOldValues_Success() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        chainlinkWrapper.addOracle(GMX, address(assetOracle));
        chainlinkWrapper.fetchPrice(GMX);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapper.savedResponses(GMX);
        vm.warp(block.timestamp + 1000);
        assetOracle.setUp(0, 0, 0, 0, false);
        chainlinkWrapper.fetchPrice(GMX);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapper.savedResponses(GMX);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }

    function test_CW_fetchPrice_OracleResponseTimeOut_ReturnOldValues_Success() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        chainlinkWrapper.addOracle(GMX, address(assetOracle));
        chainlinkWrapper.fetchPrice(GMX);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapper.savedResponses(GMX);
        assetOracle.setUp(11, 25e18, block.timestamp, 18, false);
        vm.warp(block.timestamp + 5 hours);
        chainlinkWrapper.fetchPrice(GMX);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapper.savedResponses(GMX);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }

    function test_CW_addOracle_CallerNotOwner_Fail() public {
        vm.prank(alice);
        vm.expectRevert(REVERT_NOT_OWNER);
        chainlinkWrapper.addOracle(address(0), address(0));
    }

    function test_CW_addOracle_GivenZeroTokenAddress_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapper.addOracle(address(0), address(CHAINLINK_GMX_USD_ORACLE));
    }

    function test_CW_addOracle_GivenTokenAddressIsNotContract_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapper.addOracle(alice, address(CHAINLINK_GMX_USD_ORACLE));
    }

    function test_CW_addOracle_GivenZeroAggregatorAddress_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapper.addOracle(GMX, address(0));
    }

    function test_CW_addOracle_GivenAggregatorAddressIsNotContract_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapper.addOracle(GMX, alice);
    }

    function test_CW_addOracle_GivenBrokenPriceOracle_Fail() public{
        assetOracle.setUpAll(0, 0, 0, 0);
        vm.expectRevert(REVERT_INVALID_RESPONSE);
        chainlinkWrapper.addOracle(GMX, address(assetOracle));
    }

    function test_CW_removeOracle_CallerNotOwner_Fail() public {
        vm.prank(alice);
        vm.expectRevert(REVERT_NOT_OWNER);
        chainlinkWrapper.removeOracle(GMX);
    }
}
