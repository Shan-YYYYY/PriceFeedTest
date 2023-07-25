// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./IOracleWrapper.sol";

interface IOracleVerificator {

    struct RequestVerification {
        uint256 lastGoodPrice; // Last good price from the oracle
        IOracleWrapper.SavedResponse primaryResponse; // Primary response from the oracle
        IOracleWrapper.SavedResponse secondaryResponse; // Secondary response from the oracle
    }

    /**
     * @dev Verifies the validity of the oracle response
     * @param request The request to verify
     * @return The price from the oracle
     */
    function verify(RequestVerification memory request) 
        external 
        view 
        returns (uint256);
}