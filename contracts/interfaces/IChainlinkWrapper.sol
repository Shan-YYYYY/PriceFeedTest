// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IChainlinkWrapper {

    struct SavedResponse {
        uint256 price; // price from the current round
        uint256 lastPrice; // price from the previous round
        uint256 updateTime; // timestamp for the current price
    }

    struct OracleResponse {
        uint80 roundId; // round ID of the current round
        uint256 timestamp; // timestamp of the current round
        int256 answer; // price from the current round
        uint8 decimals; // decimals of the answer
        bool success; // true if the response is valid
    }

    /**
     * @notice Emited when an oracle is added to the wrapper for `_token` and 
     * `_priceAggregator`.
     */
    event OracleAdded(address indexed _token, address _priceAggregator);

    /**
     * @notice Emited when an oracle is removed from the wrapper for `_token`.
     */
    event OracleRemoved(address indexed _token);

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
     * @notice Fetches the latest price from the oracle for `_token`.
     * @param _token The token to fetch the price for.
     */    
    function retrieveSavedResponse(address _token) 
        external 
        returns (SavedResponse memory);
    
    /**
     * @notice Fetches the latest price from the oracle for `_token`.
     */
    function fetchPrice(address _token) external;

    /**
     * @notice Adds an oracle for `_token` with `_aggregatorAddr` as the price 
     * aggregator.
     * @param _token The token to add the oracle for.
     * @param _aggregatorAddr The address of the price aggregator.
     */
    function addOracle(address _token, address _aggregatorAddr) external;

    /**
     * @notice Removes the oracle for `_token`.
     * @param _token The token to remove the oracle for.
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
}
