// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IGLPManager.sol";
import "../interfaces/IGLPOracle.sol";

contract GLPOracle is IGLPOracle {

    uint256 public constant DECIMAL_PRECISION = 1 ether;

    IGLPManager public constant GLP_MANAGER = IGLPManager(
        0x3963FfC9dff443c2A94f21b129D429891E32ec18
    );

    IERC20 public constant GLP = IERC20(
        0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258
    );

    function getPrice() external override view returns (uint256) {
        uint256 aum = GLP_MANAGER.getAumInUsdg(false) * DECIMAL_PRECISION;
        uint256 totalSupply = GLP.totalSupply();
        uint256 rawPrice = aum / totalSupply;
        return rawPrice;
    }
}
