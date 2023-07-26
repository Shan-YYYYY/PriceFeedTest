// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "../contracts/interfaces/IOracleWrapper.sol";
import "../contracts/oracles/GLPOracle.sol";
import "../contracts/wrappers/GLPOracleWrapper.sol";

contract GLPOracleWrapperTest is Test {
    GLPOracle glpOracle;
    GLPOracleWrapper glpOracleWrapper;

    function setUp() public {
        glpOracle = new GLPOracle();
        glpOracleWrapper = new GLPOracleWrapper(address(glpOracle));
    }

    function test_GLPW__DEPLOYMENT() public {
        IOracleWrapper.SavedResponse memory savedResponse;
        savedResponse = glpOracleWrapper.savedResponse;
        assertEq(savedResponse.lastPrice, 0);
    }
}
