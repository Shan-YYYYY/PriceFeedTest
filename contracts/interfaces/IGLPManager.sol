// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IGLPManager {
    /**
     * @notice Returns the total value of the assets under management (AUM) in USDG.
     * @param maximise Boolean flag to indicate whether the calculation should be made to maximise the AUM.
     * @return The total value of the assets under management in terms of USDG.
     */
    function getAumInUsdg(bool maximise) external view returns (uint256);
}
