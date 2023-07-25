// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @title IRewardRouter Interface
 * @dev This interface outlines the functions for minting, staking, unstaking 
 * and handling rewards in the protocol.
 */
interface IRewardRouter {
    /**
     * @dev Mint and stake GLP-ETH.
     * @param _minUsdg The minimum USDG expected from the mint.
     * @param _minGlp The minimum GLP expected from the mint.
     * @return The actual minted GLP amount.
     */
    function mintAndStakeGlpETH(
        uint256 _minUsdg,
        uint256 _minGlp
    ) external payable returns (uint256);

    /**
     * @dev Mint and stake GLP for a specific token.
     * @param _token The token address.
     * @param _amount The amount of the token to be used.
     * @param _minUsdg The minimum USDG expected from the mint.
     * @param _minGlp The minimum GLP expected from the mint.
     * @return The actual minted GLP amount.
     */
    function mintAndStakeGlp(
        address _token, 
        uint256 _amount, 
        uint256 _minUsdg, 
        uint256 _minGlp
    ) external returns (uint256);

    /**
     * @dev Stake GMX tokens.
     * @param _amount The amount of GMX tokens to stake.
     */
    function stakeGmx(uint256 _amount) external;

    /**
     * @dev Stake esGMX tokens.
     * @param _amount The amount of esGMX tokens to stake.
     */
    function stakeEsGmx(uint256 _amount) external;

    /**
     * @dev Unstake GMX tokens.
     * @param _amount The amount of GMX tokens to unstake.
     */
    function unstakeGmx(uint256 _amount) external;

    /**
     * @dev Unstake esGMX tokens.
     * @param _amount The amount of esGMX tokens to unstake.
     */
    function unstakeEsGmx(uint256 _amount) external;

    /**
     * @dev Handles various types of rewards.
     * @param _shouldClaimGmx Should the function claim GMX rewards.
     * @param _shouldStakeGmx Should the function stake claimed GMX.
     * @param _shouldClaimEsGmx Should the function claim esGMX rewards.
     * @param _shouldStakeEsGmx Should the function stake claimed esGMX.
     * @param _shouldStakeMultiplierPoints Should the function stake multiplier points.
     * @param _shouldClaimWeth Should the function claim WETH rewards.
     * @param _shouldConvertWethToEth Should the function convert claimed WETH to ETH.
     */
    function handleRewards(
        bool _shouldClaimGmx,
        bool _shouldStakeGmx,
        bool _shouldClaimEsGmx,
        bool _shouldStakeEsGmx,
        bool _shouldStakeMultiplierPoints,
        bool _shouldClaimWeth,
        bool _shouldConvertWethToEth
    ) external;
}
