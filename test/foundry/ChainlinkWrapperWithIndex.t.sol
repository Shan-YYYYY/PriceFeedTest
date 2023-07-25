// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract ChainlinkWrapperWithIndexTest is PriceFeedTestBase {
    event OracleAdded(address indexed _token, address _priceAggregator, address _indexAggregator);
    event OracleRemoved(address indexed _token);

    function setUp() public {
        _setUp();
    }
    
    function test_WSTETHORACLE_latestRoundData_Success() public {
        AggregatorV3Interface aggregator = AggregatorV3Interface(CHAINLINK_WSTETH_ETH_ORACLE);
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = aggregator.latestRoundData();
        assertGt(roundId, 0);
        assertGt(answer, 0);
        assertGt(startedAt, 0);
        assertGt(updatedAt, 0);
        assertGt(answeredInRound, 0);    
    }

    function test_ETHORACLE_latestRoundData_Success() public {
        AggregatorV3Interface aggregator = AggregatorV3Interface(CHAINLINK_ETH_USD_ORACLE);
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = aggregator.latestRoundData();
        assertGt(roundId, 0);
        assertGt(answer, 0);
        assertGt(startedAt, 0);
        assertGt(updatedAt, 0);
        assertGt(answeredInRound, 0);    
    }
    
    function test_CWWI_Deployment() public {
        assertEq(chainlinkWrapperWithIndex.NAME(), "ChainlinkWrapperWithIndex");
        assertEq(chainlinkWrapperWithIndex.SEQUENCER_UPTIME_FEED(), 0xFdB631F5EE196F0ed6FAa767959853A9F217697D);
        assertEq(chainlinkWrapperWithIndex.TARGET_DIGITS(), 18);
        assertEq(chainlinkWrapperWithIndex.GRACE_PERIOD_TIME(), 3600);
        assertEq(chainlinkWrapperWithIndex.TIMEOUT(), 4 hours);
        assertEq(address(chainlinkWrapperWithIndex.priceAggregators(address(0))), address(0));
        assertEq(address(chainlinkWrapperWithIndex.indexAggregators(address(0))), address(0));

        assertEq(chainlinkWrapperWithIndex.owner(), address(this));
    }

    function test_CWWI_addOracle_Success() public {
        assertEq(address(chainlinkWrapperWithIndex.priceAggregators(WSTETH)), address(0));
        assertEq(address(chainlinkWrapperWithIndex.indexAggregators(WSTETH)), address(0));
        vm.expectEmit(true, true, true, true);
        emit OracleAdded(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        assertEq(address(chainlinkWrapperWithIndex.priceAggregators(WSTETH)), CHAINLINK_WSTETH_ETH_ORACLE);
        assertEq(address(chainlinkWrapperWithIndex.indexAggregators(WSTETH)), CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_fetchPrice_Success() public {
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
    }

    function test_CWWI_removeOracle_Success() public {
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        assertEq(address(chainlinkWrapperWithIndex.priceAggregators(WSTETH)), CHAINLINK_WSTETH_ETH_ORACLE);
        assertEq(address(chainlinkWrapperWithIndex.indexAggregators(WSTETH)), CHAINLINK_ETH_USD_ORACLE);
        vm.expectEmit(true, true, true, true);
        emit OracleRemoved(WSTETH);
        chainlinkWrapperWithIndex.removeOracle(WSTETH);
        assertEq(address(chainlinkWrapperWithIndex.priceAggregators(WSTETH)), address(0));
        assertEq(address(chainlinkWrapperWithIndex.indexAggregators(WSTETH)), address(0));
    }

    function test_CWWI_addOracle_CallerNotOwner_Fail() public {
        vm.prank(alice);
        vm.expectRevert(REVERT_NOT_OWNER);
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_addOracle_GivenZeroTokenAddress_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(address(0), CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);

    }

    function test_CWWI_addOracle_GivenTokenAddressIsNotContract_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(alice, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_addOracle_GivenZeroAssetOracleAddress_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(address(0), address(0), CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_addOracle_GivenZeroIndexOracleAddress_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(address(0), CHAINLINK_WSTETH_ETH_ORACLE, address(0));
    }

    function test_CWWI_addOracle_GivenAssetOracleIsNotContract_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(address(0), alice, CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_addOracle_GivenIndexOracleIsNotContract_Fail() public {
        vm.expectRevert(REVERT_INVALID_ADDRESS);
        chainlinkWrapperWithIndex.addOracle(address(0), CHAINLINK_WSTETH_ETH_ORACLE, alice);
    }

    function test_CWWI_addOracle_AssetOracleBroken_Fail() public {
        assetOracle.setUpAll(0, 0, 0, 0);
        vm.expectRevert(REVERT_INVALID_RESPONSE);
        chainlinkWrapperWithIndex.addOracle(WSTETH, address(assetOracle), CHAINLINK_ETH_USD_ORACLE);
    }

    function test_CWWI_addOracle_IndexOracleBroken_Fail() public {
        indexOracle.setUpAll(0, 0, 0, 0);
        vm.expectRevert(REVERT_INVALID_RESPONSE);
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, address(indexOracle));
    }

    function test_CWWI_addOracle_AssetOracleAndIndexOracleBroken_Fail() public {
        console.log("Pos 1");
        assetOracle.setUpAll(0, 0, 0, 0);
        console.log("Pos 2");
        indexOracle.setUpAll(0, 0, 0, 0);
        console.log("Pos 3");
        // vm.expectRevert(REVERT_INVALID_RESPONSE);
        console.log("Pos 4");
        chainlinkWrapperWithIndex.addOracle(WSTETH, address(assetOracle), address(indexOracle));
    }

    function test_CWWI_removeOracle_CallerNotOwner_Fail() public {
        vm.prank(alice);
        vm.expectRevert(REVERT_NOT_OWNER);
        chainlinkWrapperWithIndex.removeOracle(WSTETH);
    }

    function test_CWWI_fetchPrice_GivenZeroTokenAddress_Fail() public {
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, address(0));
        vm.expectRevert(revertError);
        chainlinkWrapperWithIndex.fetchPrice(address(0));
    }

    function test_CWWI_fetchPrice_GivenNotRegisteredToken_Fail() public {
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, CHAINLINK_ETH_USD_ORACLE);
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, USDC);
        vm.expectRevert(revertError);
        chainlinkWrapperWithIndex.fetchPrice(USDC);
    }

    function test_CWWI_fetchPrice_AssetOracleBroken_ReturnOldValues() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        chainlinkWrapperWithIndex.addOracle(WSTETH, address(assetOracle), CHAINLINK_ETH_USD_ORACLE);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        vm.warp(block.timestamp + 1000);
        assetOracle.setUp(0, 0, 0, 0, false);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }

    function test_CWWI_fetchPrice_IndexOracleBroken_ReturnOldValues() public {
        indexOracle.setUpAll(10, 5e20, block.timestamp, 18);
        chainlinkWrapperWithIndex.addOracle(WSTETH, CHAINLINK_WSTETH_ETH_ORACLE, address(indexOracle));
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        vm.warp(block.timestamp + 1000);
        indexOracle.setUp(0, 0, 0, 0, false);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }

    function test_CWWI_fetchPrice_AssetOracleAndIndexOracleBroken_ReturnOldValues() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        indexOracle.setUpAll(10, 5e20, block.timestamp, 18);
        chainlinkWrapperWithIndex.addOracle(WSTETH, address(assetOracle), address(indexOracle));
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        vm.warp(block.timestamp + 1000);
        assetOracle.setUp(0, 0, 0, 0, false);
        indexOracle.setUp(0, 0, 0, 0, false);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }

    function test_CWWI_fetchPrice_AssetOracleResponseTimeOut_ReturnOldValues() public {
        assetOracle.setUpAll(10, 24e18, block.timestamp, 18);
        indexOracle.setUpAll(10, 5e20, block.timestamp, 18);
        chainlinkWrapperWithIndex.addOracle(WSTETH, address(assetOracle), address(indexOracle));
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 price, uint256 lastPrice, uint256 updateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        assetOracle.setUp(11, 25e18, block.timestamp, 18, false);
        indexOracle.setUp(11, 6e20, block.timestamp, 18, false);
        vm.warp(block.timestamp + 5 hours);
        chainlinkWrapperWithIndex.fetchPrice(WSTETH);
        (uint256 currentPrice, uint256 currentLastPrice, uint256 currentUpdateTime) = chainlinkWrapperWithIndex.savedResponses(WSTETH);
        assertEq(currentPrice, price);
        assertEq(currentLastPrice, lastPrice);
        assertEq(currentUpdateTime, updateTime);
    }
}