// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../contracts/oracles/GLPOracle.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract GLPOracleTest is Test {
    GLPOracle glpOracle;

    function setUp() public {
        glpOracle = new GLPOracle();
    }

    function testConsole() public view {
        // console.log(glpOracle.DECIMAL_PRECISION);
        console.log("1212");
    }

    function test_GLP_DEPLOYMENT() public {
        assertEq(glpOracle.DECIMAL_PRECISION(), 1 ether);
        assertEq(
            address(glpOracle.GLP_MANAGER()),
            0x3963FfC9dff443c2A94f21b129D429891E32ec18
        );
        assertEq(
            address(glpOracle.GLP()),
            0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258
        );
    }

    function testFail_GLP_getPrice() public {
        uint256 price = glpOracle.getPrice();
        assertGt(price, 0);
    }
}
