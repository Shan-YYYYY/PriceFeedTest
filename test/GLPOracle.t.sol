// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../contracts/oracles/GLPOracle.sol";
import "forge-std/Test.sol";


contract GLPOracleTest is GLPOracle{

    GLPOracle glpOralce;

    function setUp() public {
        glpOralce = new GLPOracle();
    }
}