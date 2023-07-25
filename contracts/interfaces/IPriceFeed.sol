// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IPriceFeed {

    struct Wrapper {
        address primaryWrapper; // The main oracle from which you want to fetch the price.
        address secondaryWrapper; // The fallback oracle if the main oracle encounters any issues. Can be null.
    }

    /**
     * @dev Emitted when a new oracle is added for a token.
     * @param _token The token for which the oracle is added.
     * @param _primaryWrappedOracle The address of the primary wrapped oracle.
     * @param _secondaryWrappedOracle The address of the secondary wrapped oracle.
     */
    event OracleWrapperAdded(
		address indexed _token, 
		address _primaryWrappedOracle, 
		address _secondaryWrappedOracle
	);

    /**
     * @dev Emitted when an oracle is removed for a token.
     * @param _token The token for which the oracle is removed.
     */
    event OracleWrapperRemoved(address indexed _token);

    /**
     * @dev Emitted when access is changed for a token.
     * @param _token The token for which the access is changed.
     * @param _hasAccess A boolean indicating whether access is granted or revoked.
     */
    event AccessChanged(address indexed _token, bool _hasAccess);

    /**
     * @dev Emitted when the verificator contract is changed.
     * @param _newVerificator The address of the new verificator contract.
     */
    event OracleVerificatorChanged(address indexed _newVerificator);

    /**
     * @dev Emitted when the token price is updated.
     * @param _token The token for which the price is updated.
     * @param _price The updated price in 1e18 format.
     */
    event TokenPriceUpdated(address indexed _token, uint256 _price);

    /**
     * @notice Initialize the contract with the verificator and admin address.
     * @param _verificator The address of the verificator contract.
     * @param _admin The address of the admin.
     */
    function initialize(address _verificator, address _admin) external;

    /**
     * @notice Fetch the price from external oracles and update the storage value.
     * @param _token The token for which you want to fetch the price. Must be supported by the wrapper.
     * @return The correct price in 1e18 format based on the verification contract.
     */
    function fetchPrice(address _token) external returns (uint256);

    /**
     * @notice Set the verificator contract address.
     * @param _verificator The address of the verificator contract.
     */
    function setVerificator(address _verificator) external;

    /**
     * @notice Register wrappers for a new token.
     * @param _token The token for which you want to register the wrappers.
     * @param _primaryWrapper The main oracle from which you want to fetch the price.
     * @param _secondaryWrapper The fallback oracle if the main oracle encounters any issues. Can be null.
     */
    function addOracleWrapper(
        address _token,
        address _primaryWrapper,
        address _secondaryWrapper
    ) external;

    /**
     * @notice Remove the oracle wrapper for a token.
     * @param _token The token for which you want to remove the oracle wrapper.
     */
    function removeOracleWrapper(address _token) external;

    /**
     * @notice Get the price from external oracles.
     * @param _token The token for which you want to fetch the price. Must be supported by the wrapper.
     * @return The current price reflected on the external oracle in 1e18 format.
     */
    function getExternalPrice(address _token) external view returns (uint256);
}
