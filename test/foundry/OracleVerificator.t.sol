// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract OracleVerificatorTest is PriceFeedTestBase {
    using Address for address;

    function setUp() public {
        _setUp();
    }
    
   function test_OV_Deployment() public {
        uint256 maxDeviation = getMAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND();
        uint256 maxDifference = getMAX_PRICE_DIFFERENCE_BETWEEN_ORACLES();
        uint256 timeOut = getTIMEOUT();
        address admin = getAdmin();
        assertEq(maxDeviation, 5e17);
        assertEq(maxDifference, 5e16);
        assertEq(timeOut, 4 hours);
        assertEq(admin, address(0));
        assertEq(oracleVerificator.MAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND(), 5e17);
        assertEq(oracleVerificator.MAX_PRICE_DIFFERENCE_BETWEEN_ORACLES(), 5e16);
        assertEq(oracleVerificator.TIMEOUT(), 4 hours);
        assertEq(oracleVerificator.admin(), address(0));
       
    }

    function test_OV_initialize_Success() public {
        address P_admin = getAdmin();
        assertEq(P_admin, address(0));
        assertEq(oracleVerificator.admin(), address(0));
        proxyInitialize(address(this));
        P_admin = getAdmin();
        assertEq(P_admin, address(this));
        assertEq(oracleVerificator.admin(), address(0));
        
    }

    function test_OV_verify_Success() public {
        bytes memory initPriceFeedData = abi.encodeWithSignature(
            "initialize(address,address)",
            address(oracleVerificatorProxy),
            address(this)
        );
        address(priceFeedProxy).functionCall(initPriceFeedData);
        primaryWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        secondaryWrapper.addOracle(GMX, CHAINLINK_GMX_USD_ORACLE);
        bytes memory addOracleWrapperData = abi.encodeWithSignature("addOracleWrapper(address,address,address)", GMX, address(primaryWrapper), address(secondaryWrapper));
        address(priceFeedProxy).functionCall(addOracleWrapperData);
        bytes memory callFetchPriceData = abi.encodeWithSignature("fetchPrice(address)", GMX);
        bytes memory callFetchPriceResult = address(priceFeedProxy).functionCall(callFetchPriceData);
        bytes memory callLastGoodPriceData = abi.encodeWithSignature("lastGoodPrice(address)", GMX);
        bytes memory callLastGoodPriceResult = address(priceFeedProxy).functionCall(callLastGoodPriceData);
        proxyInitialize(address(this));
        IOracleVerificator.RequestVerification memory request;
        request.lastGoodPrice = abi.decode(callLastGoodPriceResult, (uint256));
        (request.primaryResponse.price, request.primaryResponse.lastPrice, request.primaryResponse.updateTime) = primaryWrapper.savedResponses(GMX);
        (request.secondaryResponse.price, request.secondaryResponse.lastPrice, request.secondaryResponse.updateTime) = secondaryWrapper.savedResponses(GMX);
        proxyverify(request);
        
    }

    function getMAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND() private returns (uint256) {
        bytes memory callData = abi.encodeWithSignature("MAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND()");
        bytes memory callResult = address(oracleVerificatorProxy).functionCall(callData);
        uint256 maxDeviation = abi.decode(callResult, (uint256));
        return maxDeviation;
    }

    function getMAX_PRICE_DIFFERENCE_BETWEEN_ORACLES() private returns (uint256) {
        bytes memory callData = abi.encodeWithSignature("MAX_PRICE_DIFFERENCE_BETWEEN_ORACLES()");
        bytes memory callResult = address(oracleVerificatorProxy).functionCall(callData);
        uint256 maxDifference = abi.decode(callResult, (uint256));
        return maxDifference;
    }

    function getTIMEOUT() private returns (uint256) {
        bytes memory callData = abi.encodeWithSignature("TIMEOUT()");
        bytes memory callResult = address(oracleVerificatorProxy).functionCall(callData);
        uint256 timeOut = abi.decode(callResult, (uint256));
        return timeOut;
    }

    function getAdmin() private returns (address){
        bytes memory adminData = abi.encodeWithSignature("admin()");
        bytes memory adminResult = address(oracleVerificatorProxy).functionCall(adminData);
        address P_admin = abi.decode(adminResult, (address));
        return P_admin;
    }

    function proxyInitialize(address _admin) private {
        bytes memory callInitializeData = abi.encodeWithSignature("initialize(address)", _admin);
        address(oracleVerificatorProxy).functionCall(callInitializeData);
    }

    function proxyverify(IOracleVerificator.RequestVerification memory request) private returns (uint256) {
        bytes memory callVerifyData = abi.encodeWithSignature("verify((uint256,(uint256,uint256,uint256),(uint256,uint256,uint256)))", request);
        bytes memory callVerifyResult = address(oracleVerificatorProxy).functionCall(callVerifyData);
        uint256 value = abi.decode(callVerifyResult, (uint256));
        return value;
    }
}