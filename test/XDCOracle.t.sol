// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "../contract/oracles/XDCOracle.sol";

contract XDCOracleTest is Test{
    XDCOracle xdcOracle;

    function setUp() public {
        xdcOracle = new XDCOracle();
    }
}