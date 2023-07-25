// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IOracleVerificator.sol";
import "./interfaces/IOracleWrapper.sol";
import "./interfaces/IPriceFeed.sol";

contract PriceFeed is IPriceFeed, Initializable, UUPSUpgradeable {

    IOracleVerificator public verificator;
    address public admin;

    mapping(address => uint256) public lastGoodPrice;
    mapping(address => Wrapper) public wrappers;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _verificator, address _admin) external override initializer {
        verificator = IOracleVerificator(_verificator);
        admin = _admin;
    }

    function fetchPrice(address _token) external override returns (uint256 goodPrice) {
        Wrapper memory wrapper = wrappers[_token];
        require(wrapper.primaryWrapper != address(0), "Oracle not found");

        goodPrice = _getValidPrice(_token, wrapper);
        lastGoodPrice[_token] = goodPrice;

        emit TokenPriceUpdated(_token, goodPrice);
    }

    function setVerificator(address _verificator) external override onlyAdmin {
        require(_verificator != address(0), "Invalid Verificator");
        verificator = IOracleVerificator(_verificator);
        emit OracleVerificatorChanged(_verificator);
    }

    function addOracleWrapper(
        address _token,
        address _primaryWrapper,
        address _secondaryWrapper
    ) external override onlyAdmin {
        require(_primaryWrapper != address(0), "Invalid Primary Oracle");

        Wrapper storage wrapper = wrappers[_token];
        wrapper.primaryWrapper = _primaryWrapper;
        wrapper.secondaryWrapper = _secondaryWrapper;

        uint256 price = _getValidPrice(_token, wrapper);
        if (price == 0) revert("Oracle down");

        lastGoodPrice[_token] = price;

        emit OracleWrapperAdded(_token, _primaryWrapper, _secondaryWrapper);
    }

    function removeOracleWrapper(address _token) external override onlyAdmin {
        delete wrappers[_token];
        emit OracleWrapperRemoved(_token);
    }

    function getExternalPrice(address _token) external override view returns (uint256) {
        Wrapper memory wrapper = wrappers[_token];
        require(wrapper.primaryWrapper != address(0), "Oracle not found");
        return IOracleWrapper(wrapper.primaryWrapper).getOraclePrice(_token);
    }
    
    function _getValidPrice(
        address _token,
        Wrapper memory _wrapper
    ) private returns (uint256) {
        address primary = _wrapper.primaryWrapper;
        address secondary = _wrapper.secondaryWrapper;
        IOracleWrapper.SavedResponse memory primaryResponse = IOracleWrapper(primary).retrieveSavedResponse(_token);
        IOracleWrapper.SavedResponse memory secondaryResponse = secondary == address(0)
            ? IOracleWrapper.SavedResponse(0, 0, 0)
            : IOracleWrapper(secondary).retrieveSavedResponse(_token);

        return
            verificator.verify(
                IOracleVerificator.RequestVerification(
                    lastGoodPrice[_token], 
                    primaryResponse, 
                    secondaryResponse
                )
            );
    }

    function _authorizeUpgrade(address /*newImplementation*/) internal view override {
        require(msg.sender == admin, "Unauthorized");
    }
}
