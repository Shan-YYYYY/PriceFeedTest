// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IChainlinkWrapperWithIndex.sol";

contract ChainlinkWrapperWithIndex is 
    IChainlinkWrapperWithIndex, 
    Ownable, 
    ReentrancyGuard 
{
    using Address for address;
    using SafeCast for int256;

    string public constant NAME = "ChainlinkWrapperWithIndex";
    address public constant SEQUENCER_UPTIME_FEED = 0xFdB631F5EE196F0ed6FAa767959853A9F217697D;
    uint256 public constant GRACE_PERIOD_TIME = 3600;
    uint256 public constant TARGET_DIGITS = 18;
    uint256 public constant TIMEOUT = 4 hours;

    AggregatorV3Interface internal sequencerUptimeFeed;

    // Additional mapping for index aggregators
    mapping(address => AggregatorV3Interface) public priceAggregators;
    // Additional mapping for index aggregators
    mapping(address => AggregatorV3Interface) public indexAggregators;
    // Modify savedResponses mapping to store index information as well
    mapping(address => SavedResponse) public savedResponses;

    modifier notNull(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    modifier isContract(address _addr) {
        require(_addr.isContract(), "Invalid address");
        _;
    }

    constructor () {
        sequencerUptimeFeed = AggregatorV3Interface(SEQUENCER_UPTIME_FEED);
    }

    function retrieveSavedResponse(address _token) 
        external 
        override 
        returns (SavedResponse memory savedResponse) 
    {
        fetchPrice(_token);

        return savedResponses[_token];
    }

    function fetchPrice(address _token) public override nonReentrant {
        (
            OracleResponse memory curResponse, 
            OracleResponse memory prevResponse
        ) = _getResponses(_token, priceAggregators[_token]);

        (
            OracleResponse memory curIndexResponse,
            OracleResponse memory prevIndexResponse
        ) = _getResponses(_token, indexAggregators[_token]);

        SavedResponse storage response = savedResponses[_token];

        if (
            !_isOracleBroken(curResponse, prevResponse) && 
            !_isOracleBroken(curIndexResponse, prevIndexResponse)
        ) {
            if (!_isTimeout(curResponse.timestamp)) {
                response.price = _calFinalPrice(curResponse, curIndexResponse);
                response.lastPrice = _calFinalPrice(prevResponse, prevIndexResponse);
                response.updateTime = curResponse.timestamp;
            }
        }
    }

    function addOracle(
        address _token, 
        address _priceAggregatorAddr, 
        address _indexAggregatorAddr
    ) 
        external 
        override 
        onlyOwner
        isContract(_token) 
        isContract(_priceAggregatorAddr) 
        isContract(_indexAggregatorAddr) 
    {
        priceAggregators[_token] = AggregatorV3Interface(_priceAggregatorAddr);
        indexAggregators[_token] = AggregatorV3Interface(_indexAggregatorAddr);

        (
            OracleResponse memory newResponse,
            OracleResponse memory prevResponse 
        ) = _getResponses(_token, priceAggregators[_token]);

        _requireValidOracleResponse(newResponse);
        _requireValidOracleResponse(prevResponse);

        (
            OracleResponse memory newIndexResponse,
            OracleResponse memory prevIndexResponse
        ) = _getResponses(_token, indexAggregators[_token]);

        _requireValidOracleResponse(newIndexResponse);
        _requireValidOracleResponse(prevIndexResponse);

        SavedResponse storage response = savedResponses[_token];
        response.price = _calFinalPrice(newResponse, newIndexResponse);
        response.lastPrice = _calFinalPrice(prevResponse, prevIndexResponse);
        response.updateTime = newResponse.timestamp;

        emit OracleAdded(_token, _priceAggregatorAddr, _indexAggregatorAddr);
    }

    function removeOracle(address _token) external override onlyOwner {
        delete priceAggregators[_token];
        delete indexAggregators[_token];

        emit OracleRemoved(_token);
    }

    function getCurrentPrice(address _token) external view override returns (uint256) {
        return savedResponses[_token].price;
    }

    function getLastPrice(address _token) external view override returns (uint256) {
        return savedResponses[_token].lastPrice;
    }

    function getExternalPrice(address _token) external view override returns (uint256) {
        (OracleResponse memory curResponse, ) = _getResponses(_token, priceAggregators[_token]);
        (OracleResponse memory curIndexResponse, ) = _getResponses(_token, indexAggregators[_token]);
        return _calFinalPrice(curResponse, curIndexResponse);
    }

    function _calFinalPrice(OracleResponse memory _priceResponse, OracleResponse memory _indexResponse) private pure returns (uint256) {
        uint256 price = _scalePriceByDigits(_priceResponse.answer.toUint256(), _priceResponse.decimals);
        uint256 index = _scalePriceByDigits(_indexResponse.answer.toUint256(), _indexResponse.decimals);
        return price * index / 1e18;
    }

    function _getResponses(address _token, AggregatorV3Interface _aggregator) 
        internal 
        view 
        returns (
            OracleResponse memory curResponse, 
            OracleResponse memory prevResponse
    ) {
        if (address(_aggregator) == address(0)) {
            revert TokenIsNotRegistered(_token);
        }
        curResponse = _getCurrentChainlinkResponse(_aggregator);
        if (curResponse.roundId == 0) return (curResponse, prevResponse);
        prevResponse = _getChainlinkResponse(_aggregator, curResponse.roundId - 1);
    }

    function _getCurrentChainlinkResponse(AggregatorV3Interface _aggregator) 
        private 
        view 
        returns (OracleResponse memory response) 
    {
        try _aggregator.decimals() returns (uint8 decimals) {
            response.decimals = decimals;
        } catch {
            return response;
        }

        try _aggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256, /* startedAt */
            uint256 timestamp,
            uint80 /* answeredInRound */
        ) {
            response.roundId = roundId;
            response.answer = answer;
            response.timestamp = timestamp;
            response.success = true;
            return response;
        } catch {
            return response;
        }
    }

    function _getChainlinkResponse(AggregatorV3Interface _aggregator, uint80 _roundId) 
        private 
        view 
        returns (OracleResponse memory response) 
    {
        if (_roundId == 0) return response;

        try _aggregator.decimals() returns (uint8 decimals) {
            response.decimals = decimals;
        } catch {
            return response;
        }

        try _aggregator.getRoundData(_roundId) returns (
            uint80 roundId,
            int256 answer,
            uint256, /* startedAt */
            uint256 timestamp,
            uint80 /* answeredInRound */
        ) {
            response.roundId = roundId;
            response.answer = answer;
            response.timestamp = timestamp;
            response.success = true;
            return response;
        } catch {
            return response;
        }
    }

    function _isOracleBroken(
        OracleResponse memory _response, 
        OracleResponse memory _prevResponse
    ) internal view returns (bool) {
        return _isBadOracleResponse(_response) || _isBadOracleResponse(_prevResponse);
    }

    function _isBadOracleResponse(OracleResponse memory _response) 
        internal 
        view 
        returns (bool)
    {
        if (!_response.success) return true;

        if (_response.roundId == 0) return true;

        if (_response.answer <= 0) return true;

        // if (_response.timestamp == 0 || _response.timestamp > block.timestamp) {
        //     return true;
        // }

        if (_response.timestamp == 0) {
            return true;
        }

        return false;
    }

    function _requireSequencerIsUp() private view {
        (
            /*uint80 roundID*/,
            int256 answer,
            uint256 startedAt,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = sequencerUptimeFeed.latestRoundData();

        // Answer == 0: Sequencer is up
        // Answer == 1: Sequencer is down
        bool isSequencerUp = answer == 0;
        if (!isSequencerUp) {
            revert SequencerDown();
        }

        // Make sure the grace period has passed after the
        // sequencer is back up.
        uint256 timeSinceUp = block.timestamp - startedAt;
        if (timeSinceUp <= GRACE_PERIOD_TIME) {
            revert GracePeriodNotOver();
        }
    }

    function _requireValidOracleResponse(
        OracleResponse memory _response
    ) private view {
        require(!_isBadOracleResponse(_response), "Invalid Oracle Response");
    }

    function _scalePriceByDigits(uint256 _price, uint256 _digits) 
        private 
        pure 
        returns (uint256) 
    {
        return 
            _digits < TARGET_DIGITS ? 
            _price * (10 ** (TARGET_DIGITS - _digits)) : 
            _price / (10 ** (_digits - TARGET_DIGITS));
    }

    function _isTimeout(uint256 timestamp) private view returns (bool) {
        if (block.timestamp < timestamp) return true;
        return block.timestamp - timestamp > TIMEOUT;
    }
}
