// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface ICurveFactory {
    
    /**
     * @notice Deploy a new Curve plain pool.
     * @param _name The name of the pool.
     * @param _symbol The symbol of the pool.
     * @param _coins An array of 4 addresses representing the tokens in the pool.
     * @param _A The amplification coefficient of the pool.
     * @param _fee The fee applied to the pool.
     * @param _asset_type The type of assets in the pool.
     * @param _implementation_idx The index of the implementation for the pool.
     * @return pool The address of the deployed pool.
     */
    function deploy_plain_pool(
        string calldata _name,
        string calldata _symbol,
        address[4] calldata _coins,
        uint256 _A,
        uint256 _fee,
        uint256 _asset_type,
        uint256 _implementation_idx
    ) external returns (address pool);
}
