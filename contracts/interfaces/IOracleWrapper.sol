// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IOracleWrapper {

    struct SavedResponse {
        uint256 price; // Price from the current round
        uint256 lastPrice; // Price from the previous round
        uint256 updateTime; // Timestamp for the current price
    }

    /**
     * @notice Fetch the price from external oracles and update the storage value.
     * @dev This is for the front-end and has no security.
     * @param _token The token for which you want to fetch the price.
     */
    function fetchPrice(address _token) external;

    /**
     * @notice Retrieve the saved responses containing the current price, last price, and last update time.
     * @param _token The token for which you want to retrieve the saved responses. Needs to be supported by the wrapper.
     * @return response The current price, last price, and last update time.
     */
    function retrieveSavedResponse(address _token) external returns (SavedResponse memory response);

    /**
     * @notice Get the last price saved in the contract's storage.
     * @param _token The token for which you want to get the last price. Needs to be supported by the wrapper.
     * @return The last price in 1e18 format.
     */
    function getLastPrice(address _token) external view returns (uint256);

    /**
     * @notice Get the current price saved in the contract's storage.
     * @param _token The token for which you want to get the current price. Needs to be supported by the wrapper.
     * @return The current price in 1e18 format.
     */
    function getCurrentPrice(address _token) external view returns (uint256);

    /**
     * @notice Fetches the timestamp of the last price update for the specific token.
     * @param _token The address of the token for which to get the last update time.
     * @return The timestamp of the last update time for the given token.
     */
    function getUpdateTime(address _token) external view returns (uint256);

    /**
     * @notice Get the price from the external oracle directly.
     * @dev This is for the front-end and has no security. Do not use it as an information source in a smart contract.
     * @param _token The token for which you want to get the price. Needs to be supported by the wrapper.
     * @return The price from the external oracle in 1e18 format.
     */
    function getOraclePrice(address _token) external view returns (uint256);
}
