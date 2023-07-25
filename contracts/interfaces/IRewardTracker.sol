// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @title IRewardTracker Interface
 * @dev This interface outlines the functions for tracking and handling rewards in the protocol.
 */
interface IRewardTracker {
    /**
     * @dev Returns the deposit balance of `_account` for `_depositToken`.
     * @param _account The account whose deposit balance is returned.
     * @param _depositToken The token for which the deposit balance is returned.
     * @return The deposit balance.
     */
    function depositBalances(address _account, address _depositToken) 
        external 
        view 
        returns (uint256);

    /**
     * @dev Returns the staked amount for `_account`.
     * @param _account The account whose staked amount is returned.
     * @return The staked amount.
     */
    function stakedAmounts(address _account) external view returns (uint256);

    /**
     * @dev Updates the rewards.
     */
    function updateRewards() external;

    /**
     * @dev Stakes `_amount` of `_depositToken`.
     * @param _depositToken The token to be staked.
     * @param _amount The amount to stake.
     */
    function stake(address _depositToken, uint256 _amount) external;

    /**
     * @dev Stakes `_amount` of `_depositToken` for `_account` from `_fundingAccount`.
     * @param _fundingAccount The account providing the tokens.
     * @param _account The account for which the tokens are staked.
     * @param _depositToken The token to be staked.
     * @param _amount The amount to stake.
     */
    function stakeForAccount(
        address _fundingAccount, 
        address _account, 
        address _depositToken, 
        uint256 _amount
    ) external;

    /**
     * @dev Unstakes `_amount` of `_depositToken`.
     * @param _depositToken The token to be unstaked.
     * @param _amount The amount to unstake.
     */
    function unstake(address _depositToken, uint256 _amount) external;

    /**
     * @dev Unstakes `_amount` of `_depositToken` for `_account` to `_receiver`.
     * @param _account The account for which the tokens are unstaked.
     * @param _depositToken The token to be unstaked.
     * @param _amount The amount to unstake.
     * @param _receiver The account receiving the unstaked tokens.
     */
    function unstakeForAccount(
        address _account, 
        address _depositToken, 
        uint256 _amount, 
        address _receiver
    ) external;

    /**
     * @dev Returns the number of tokens distributed per interval.
     * @return The number of tokens per interval.
     */
    function tokensPerInterval() external view returns (uint256);

    /**
     * @dev Claims the rewards to `_receiver`.
     * @param _receiver The account receiving the claimed rewards.
     * @return The claimed reward amount.
     */
    function claim(address _receiver) external returns (uint256);

    /**
     * @dev Claims the rewards for `_account` to `_receiver`.
     * @param _account The account for which rewards are claimed.
     * @param _receiver The account receiving the claimed rewards.
     * @return The claimed reward amount.
     */
    function claimForAccount(address _account, address _receiver) 
        external 
        returns (uint256);

    /**
     * @dev Returns the claimable amount for `_account`.
     * @param _account The account for which the claimable amount is returned.
     * @return The claimable amount.
     */
    function claimable(address _account) external view returns (uint256);

    /**
     * @dev Returns the claimable reward for `_account`.
     * @param _account The account for which the claimable reward is returned.
     * @return The claimable reward.
     */
    function claimableReward(address _account) external view returns (uint256);

    /**
     * @dev Returns the average staked amount for `_account`.
     * @param _account The account for which the average staked amount is returned.
     * @return The average staked amount.
     */
    function averageStakedAmounts(address _account) 
        external 
        view 
        returns (uint256);

    /**
     * @dev Returns the cumulative rewards for `_account`.
     * @param _account The account for which the cumulative rewards are returned.
     * @return The cumulative rewards.
     */
    function cumulativeRewards(address _account) 
        external 
        view 
        returns (uint256);

    /**
     * @dev Returns the balance of `_account`.
     * @param _account The account for which the balance is returned.
     * @return The balance of the account.
     */
    function balanceOf(address _account) external view returns (uint256);
}
