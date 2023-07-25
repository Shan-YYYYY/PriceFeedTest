// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {Utils} from "./Utils.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

import "../../../contracts/libs/LiquidityAmounts.sol";

import "../../../contracts/interfaces/IXloopOracle.sol";
import "../../../contracts/interfaces/ICurveFactory.sol";
import "../../../contracts/interfaces/ICurvePool.sol";
import "../../../contracts/interfaces/IOracleVerificator.sol";
import "../../../contracts/interfaces/IChainlinkWrapper.sol";
import "../../../contracts/interfaces/IPriceFeed.sol";
import "../../../contracts/interfaces/IOracleVerificator.sol";

import "../../../contracts/oracles/GLPOracle.sol";
import "../../../contracts/oracles/XloopOracle.sol";
import "../../../contracts/oracles/XDCOracle.sol";

import "../../../contracts/wrappers/ChainlinkWrapper.sol";
import "../../../contracts/wrappers/ChainlinkWrapperWithIndex.sol";
import "../../../contracts/wrappers/GLPOracleWrapper.sol";
import "../../../contracts/wrappers/XloopOracleWrapper.sol";
import "../../../contracts/wrappers/XDCOracleWrapper.sol";

import "../../../contracts/OracleVerificator.sol";
import "../../../contracts/PriceFeed.sol";

import "../../../contracts/mocks/MockXloopToken.sol";
import "../../../contracts/mocks/MockXDCToken.sol";
import "../../../contracts/mocks/MockWrappedGLP.sol";
import "../../../contracts/mocks/MockChainlinkOracle.sol";

contract Imports {

}
