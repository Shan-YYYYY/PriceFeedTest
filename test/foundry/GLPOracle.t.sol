// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./utils/PriceFeedTestBase.sol";

contract GLPOracleTest is PriceFeedTestBase {
    
    function setUp() public {
        _setUp();
    }

    function test_GLPO_Deployment() public {
        assertEq(glpOracle.DECIMAL_PRECISION(), 1 ether);
        assertEq(address(glpOracle.GLP_MANAGER()), 0x3963FfC9dff443c2A94f21b129D429891E32ec18);
        assertEq(address(glpOracle.GLP()), 0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258);
    }

    function test_GLPO_getPrice_Success() public {
        uint256 val = glpOracle.getPrice();
        assertGt(val, 0);
    }
}