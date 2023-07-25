// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IGLPOracle.sol";
import "../interfaces/IOracleWrapper.sol";

contract GLPOracleWrapper is IOracleWrapper, ReentrancyGuard {

    struct OracleResponse {
        uint256 price;  // Latest price returned by the oracle
        uint256 lastUpdate; // Timestamp of the last update
        bool success; // Indicator of whether the last call to the oracle was successful
    }

    address public immutable oracle;

    SavedResponse public savedResponse; // Stored price response

    constructor(address _oracle) {
        require(_oracle != address(0), "Invalid oracle address");
        oracle = _oracle;
    }

    function retrieveSavedResponse(address _token) 
        external 
        override  
        returns (SavedResponse memory) 
    {
        fetchPrice(_token);

        return savedResponse;
    }

    function fetchPrice(address /*_token*/) public override nonReentrant {
        OracleResponse memory response = _getOracleResponse();
        if (response.success) {
            savedResponse.lastPrice = savedResponse.price;
            savedResponse.price = response.price;
            savedResponse.updateTime = response.lastUpdate;
        }
    }

    function getCurrentPrice(address /*_token*/) external view returns (uint256) {
        return savedResponse.price;
    }

    function getLastPrice(address /*_token*/) external view returns (uint256) {
        return savedResponse.lastPrice;
    }

    function getUpdateTime(address /*_token*/) external view override returns(uint256) {
        return savedResponse.updateTime;
    }

    function getOraclePrice(address /*_token*/) external view returns (uint256) {
        return _getOracleResponse().price;
    }

    function _getOracleResponse() private view returns (OracleResponse memory response) {
        try IGLPOracle(oracle).getPrice() returns (uint256 price) {
            response.price = price;
            response.lastUpdate = block.timestamp;
            response.success = true;
        } catch {
            response.success = false;
        }
    }
}
