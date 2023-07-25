// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract PriceFeedTest is PriceFeedTestBase {

    event OracleWrapperAdded(
        address indexed _token, 
        address _primaryWrappedOracle, 
        address _secondaryWrappedOracle
    );
    event OracleWrapperRemoved(address indexed _token);
    event AccessChanged(address indexed _token, bool _hasAccess);
    event OracleVerificatorChanged(address indexed _newVerificator);
    event TokenPriceUpdated(address indexed _token, uint256 _price);

    address L_primaryWrapper;
    address L_secondaryWrapper;
    
    function setUp() public {
        _setUp();
    }
    
   function test_PF_Deployment() public {
        address verificator = getVerificator();
        address admin = getAdmin();
        assertEq(verificator, address(0));
        assertEq(admin, address(0));
        (L_primaryWrapper, L_secondaryWrapper) = priceFeed.wrappers(address(0));
        assertEq(L_primaryWrapper, address(0));
        assertEq(L_secondaryWrapper, address(0));
        assertEq(priceFeed.lastGoodPrice(address(0)), 0);
    }

    function test_PF_initialize_Success() public {
        address verificator = getVerificator();
        address admin = getAdmin();
        assertEq(verificator, address(0));
        assertEq(admin, address(0));
        assertEq(address(priceFeed.verificator()), address(0));
        assertEq(priceFeed.admin(), address(0));
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        verificator = getVerificator();
        admin = getAdmin();
        assertEq(verificator, address(oracleVerificatorProxy));
        assertEq(admin, address(this));
        assertEq(address(priceFeed.verificator()), address(0));
        assertEq(priceFeed.admin(), address(0));
    }

    function test_PF_fetchPrice_Success() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        proxyAddOracleWrapper(GMX);
        uint256 goodPrice = proxyFetchPrice(GMX);
        assertGt(goodPrice, 0);
    }

    function test_PF_setVerificator_Success() public {
        address verificator = getVerificator();
        assertEq(verificator, address(0));
        assertEq(address(priceFeed.verificator()), address(0));
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        verificator = getVerificator();
        assertEq(verificator, address(oracleVerificatorProxy));
        assertEq(address(priceFeed.verificator()), address(0));
        proxySetVerificator(alice);
        verificator = getVerificator();
        assertEq(verificator, alice);
        assertEq(address(priceFeed.verificator()), address(0));

    }

    function test_PF_addOracleWrapper_Success() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        (address P_primaryWrapper, address P_secondaryWrapper) = getWrappers(GMX);
        (L_primaryWrapper, L_secondaryWrapper) = priceFeed.wrappers(GMX);
        assertEq(P_primaryWrapper, address(0));
        assertEq(P_secondaryWrapper, address(0));
        assertEq(L_primaryWrapper, address(0));
        assertEq(L_secondaryWrapper, address(0));
        proxyAddOracleWrapper(GMX);
        (P_primaryWrapper, P_secondaryWrapper) = getWrappers(GMX);
        (L_primaryWrapper, L_secondaryWrapper) = priceFeed.wrappers(GMX);
        assertEq(P_primaryWrapper, address(primaryWrapper));
        assertEq(P_secondaryWrapper, address(secondaryWrapper));
        assertEq(L_primaryWrapper, address(0));
        assertEq(L_secondaryWrapper, address(0));
    }

    function test_PF_removeOracleWrapper_Success() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        proxyAddOracleWrapper(GMX);
        (address P_primaryWrapper, address P_secondaryWrapper) = getWrappers(GMX);
        (L_primaryWrapper, L_secondaryWrapper) = priceFeed.wrappers(GMX);
        assertEq(P_primaryWrapper, address(primaryWrapper));
        assertEq(P_secondaryWrapper, address(secondaryWrapper));
        assertEq(L_primaryWrapper, address(0));
        assertEq(L_secondaryWrapper, address(0));
        proxyRemoveOracleWrapper(GMX);
        (P_primaryWrapper, P_secondaryWrapper) = getWrappers(GMX);
        (L_primaryWrapper, L_secondaryWrapper) = priceFeed.wrappers(GMX);
        assertEq(P_primaryWrapper, address(0));
        assertEq(P_secondaryWrapper, address(0));
        assertEq(L_primaryWrapper, address(0));
        assertEq(L_secondaryWrapper, address(0));
    }

    function test_PF_getExternalPrice_Success() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        proxyAddOracleWrapper(GMX);
        uint256 externalPrice = proxyGetExternalPrice(GMX);
        assertGt(externalPrice, 0);
    }

    function test_PF_addOracle_AdminNotSetUnauthorized_Fail() public {
        vm.expectRevert("Unauthorized");
        priceFeed.addOracleWrapper(GMX, address(primaryWrapper), address(secondaryWrapper));
    }

    function test_PF_addOracle_AdminSetUnauthorized_Fail() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        vm.prank(alice);
        vm.expectRevert("Unauthorized");
        bytes memory addOracleWrapperData = abi.encodeWithSignature("addOracleWrapper(address,address,address)", GMX, address(primaryWrapper), address(secondaryWrapper));
        address(priceFeedProxy).functionCall(addOracleWrapperData);
    }

    function test_PF_addOracle_GivenTokenNotRegistered_Fail() public {
        proxyInitialize(address(oracleVerificatorProxy), address(this));
        bytes memory addOracleWrapperData = abi.encodeWithSignature("addOracleWrapper(address,address,address)", GMX, address(primaryWrapper), address(secondaryWrapper));
        bytes memory revertError = abi.encodeWithSignature(REVERT_TOKEN_NOT_REGISTERED, GMX);
        vm.expectRevert(revertError);
        address(priceFeedProxy).functionCall(addOracleWrapperData);
    }
    
    function getVerificator() private returns (address){
        bytes memory callVerificatorData = abi.encodeWithSignature("verificator()");
        bytes memory callVerificatorResult = address(priceFeedProxy).functionCall(callVerificatorData);
        address verificator = abi.decode(callVerificatorResult, (address));
        return verificator;
    }

    function getAdmin() private returns (address) {
        bytes memory callAdminData = abi.encodeWithSignature("admin()");
        bytes memory callAdminResult = address(priceFeedProxy).functionCall(callAdminData);
        address admin = abi.decode(callAdminResult, (address));
        return admin;
    }

    function getLastGoodPrice(address _token) private returns (uint256) {
        bytes memory callLastGoodPriceData = abi.encodeWithSignature("lastGoodPrice(address)", _token);
        bytes memory callLastGoodPriceResult = address(priceFeedProxy).functionCall(callLastGoodPriceData);
        uint256 lastGoodPrice = abi.decode(callLastGoodPriceResult, (uint256));
        return lastGoodPrice;
    }

    function getWrappers(address _token) private returns (address, address) {
        bytes memory callWrappersData = abi.encodeWithSignature("wrappers(address)", _token);
        bytes memory callWrappersResult = address(priceFeedProxy).functionCall(callWrappersData);
        (address P_primaryWrapper, address P_secondaryWrapper) = abi.decode(callWrappersResult, (address, address));
        return (P_primaryWrapper, P_secondaryWrapper);
    }

    function proxyInitialize(address _verificator, address _admin) private {
        bytes memory initPriceFeedData = abi.encodeWithSignature(
            "initialize(address,address)",
            address(_verificator),
            address(_admin)
        );
        address(priceFeedProxy).functionCall(initPriceFeedData);
    }

    function proxyFetchPrice(address _token) private returns (uint256) {
        bytes memory callFetchPriceData = abi.encodeWithSignature("fetchPrice(address)", GMX);
        //vm.expectEmit(true, true, true, true);
        //emit TokenPriceUpdated(_token, goodPrice);
        bytes memory callFetchPriceResult = address(priceFeedProxy).functionCall(callFetchPriceData);
        uint256 goodPrice = abi.decode(callFetchPriceResult, (uint256));
        return goodPrice;
    }

    function proxySetVerificator(address _verificator) private {
        bytes memory callSetVerificatorData = abi.encodeWithSignature("setVerificator(address)", _verificator);
        vm.expectEmit(true, true, true, true);
        emit OracleVerificatorChanged(_verificator);
        address(priceFeedProxy).functionCall(callSetVerificatorData);
    }

    function proxyAddOracleWrapper(address _token) private {
        primaryWrapper.addOracle(_token, CHAINLINK_GMX_USD_ORACLE);
        secondaryWrapper.addOracle(_token, CHAINLINK_GMX_USD_ORACLE);
        bytes memory addOracleWrapperData = abi.encodeWithSignature("addOracleWrapper(address,address,address)", _token, address(primaryWrapper), address(secondaryWrapper));
        vm.expectEmit(true, true, true, true);
        emit OracleWrapperAdded(_token, address(primaryWrapper), address(secondaryWrapper));
        address(priceFeedProxy).functionCall(addOracleWrapperData);
    }

    function proxyRemoveOracleWrapper(address _token) private {
        bytes memory callRemoveOracleWrapperData = abi.encodeWithSignature("removeOracleWrapper(address)", _token);
        vm.expectEmit(true, true, true, true);
        emit OracleWrapperRemoved(_token);
        address(priceFeedProxy).functionCall(callRemoveOracleWrapperData);
    }

    function proxyGetExternalPrice(address _token) private returns (uint256) {
        bytes memory callGetExternalPriceData = abi.encodeWithSignature("getExternalPrice(address)", _token);
        bytes memory callGetExternalPriceResult = address(priceFeedProxy).functionCall(callGetExternalPriceData);
        uint256 externalPrice = abi.decode(callGetExternalPriceResult, (uint256));
        return externalPrice;
    }
}