// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IChainlinkWrapperWithIndex {

    struct SavedResponse {
        uint256 price; // price from the current round
        uint256 lastPrice; // price from the previous round
        uint256 updateTime; // timestamp for the current price and index
    }

    struct OracleResponse {
        uint80 roundId; // round ID of the current round
        uint256 timestamp; // timestamp of the current round
        int256 answer; // price from the current round
        uint8 decimals; // decimals of the answer
        bool success; // true if the response is valid
    }

    /**
     * @notice Emited when the sequencer is down.
     */
    error SequencerDown();

    /**
     * @notice Emited when the grace period is not over.
     */
    error GracePeriodNotOver();

    /**
     * @notice Emited when the oracle is not registered for `_token`.
     */
    error TokenIsNotRegistered(address _token);

    /**
     * @notice Emitted when the oracle is broken
     * @param _token The address of the token
     */
    event OracleIsBroken(address indexed _token);

    /**
     * @notice Emitted when the oracle is not updated for a long time
     * @param _token The address of the token
     */
    event OracleIsNotUpdated(address indexed _token);

    /**
     * @notice Emitted when the oracle is updated
     * @param _token The address of the token
     * @param _price The price of the token
     * @param _index The index of the token
     */
    event OracleUpdated(address indexed _token, uint256 _price, uint256 _index);
    
    /**
     * @notice Emitted when the oracle is added
     * @param _token The address of the token
     * @param _priceAggregator The address of the price aggregator
     * @param _indexAggregator The address of the index aggregator
     */
    event OracleAdded(address indexed _token, address _priceAggregator, address _indexAggregator);

    /**
     * @notice Emitted when the oracle is removed
     * @param _token The address of the token
     */
    event OracleRemoved(address indexed _token);

    /**
     * @notice Fetches the latest price from the oracle for `_token`.
     * @param _token The token to fetch the price for.
     */    
    function retrieveSavedResponse(address _token) 
        external 
        returns (SavedResponse memory);

    /**
     * @notice Fetches the latest price and index from the oracle
     * @param _token The address of the token
     */
    function fetchPrice(address _token) external;

    /**
     * @notice Adds a new oracle for the token
     * @param _token The address of the token
     * @param _priceAggregatorAddr The address of the price aggregator
     * @param _indexAggregatorAddr The address of the index aggregator
     */
    function addOracle(
        address _token, 
        address _priceAggregatorAddr, 
        address _indexAggregatorAddr
    ) external;

    /**
     * @notice Removes the oracle for the token
     * @param _token The address of the token
     */
    function removeOracle(address _token) external;

    /**
     * @notice Returns the current price for `_token`.
     * @param _token The token to get the price for.
     */
    function getCurrentPrice(address _token) external view returns (uint256);

    /**
     * @notice Returns the previous price for `_token`.
     * @param _token The token to get the price for.
     */
    function getLastPrice(address _token) external view returns (uint256);

    /**
     * @notice getExternalPrice gets the price from the external oracle directly
     * @dev This is for the front-end and have no secruity. So do not use it as information source in a smart contract
     * @param _token the token you want to price. Needs to be supported by the wrapper
     * @return the price in 1e18 format
     */
    function getExternalPrice(address _token) external view returns (uint256);
}
