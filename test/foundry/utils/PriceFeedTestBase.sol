// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./Imports.sol";

contract PriceFeedTestBase is Test {
    using Address for address;

    bytes public constant REVERT_INVALID_ADDRESS = "Invalid address";
    bytes public constant REVERT_NOT_OWNER = "Ownable: caller is not the owner";
    bytes public constant REVERT_INVALID_RESPONSE = "Invalid Oracle Response";
    string public constant REVERT_TOKEN_NOT_REGISTERED = "TokenIsNotRegistered(address)";

    address public constant WSTETH = 0x5979D7b546E38E414F7E9822514be443A4800529; // wrapped stETH
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831; // native USDC on Arbitrum
    address public constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address public constant sGLP = 0x2F546AD4eDD93B956C8999Be404cdCAFde3E89AE;

    MockXloopToken public xloop;
    MockXDCToken public xdc;
    MockWrappedGLP public wGLP;

    GLPOracle public glpOracle;
    XloopOracle public xloopOracle;
    XDCOracle public xdcOracle;

    MockChainlinkOracle public assetOracle;
    MockChainlinkOracle public indexOracle;
    MockChainlinkOracle public primaryOracle;
    MockChainlinkOracle public secondaryOracle;

    ChainlinkWrapper public chainlinkWrapper;
    ChainlinkWrapper public primaryWrapper;
    ChainlinkWrapper public secondaryWrapper;
    ChainlinkWrapperWithIndex public chainlinkWrapperWithIndex;
    GLPOracleWrapper public glpOracleWrapper;
    XloopOracleWrapper public xloopOracleWrapper;
    XDCOracleWrapper public xdcOracleWrapper;

    ERC1967Proxy public oracleVerificatorProxy;
    ERC1967Proxy public priceFeedProxy;

    OracleVerificator public oracleVerificator;
    PriceFeed public priceFeed;

    address public poolAddress;
    address public curvePool;
        
    address public constant uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984; // Arbitrum
    address public constant curvePoolFactory = 0xb17b674D9c5CB2e441F8e196a2f048A81355d031; // Arbitrum
    address public constant CHAINLINK_GMX_USD_ORACLE = 0xDB98056FecFff59D032aB628337A4887110df3dB;

    address public constant CHAINLINK_WSTETH_ETH_ORACLE = 0xb523AE262D20A936BC152e6023996e46FDC2A95D;
    address public constant CHAINLINK_ETH_USD_ORACLE = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    address public constant CHAINLINK_ARB_USD_ORACLE = 0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6;

    address public constant XDC = 0x730D5ab5a375c3a6cDC22A9D3bEc1573FDeA97D6;
    address public constant CURVE_POOL = 0xedCe214e7a52c77914342B072230ac971149Eb00;

    INonfungiblePositionManager public nonfungiblePositionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    Utils internal utils;
    address payable[] internal users;
    address internal treasury;
    address internal alice;
    address internal bob;
    address internal charlie;
    address internal dennis;
    address internal whale;
    address internal admin;
    address internal lpRewardsAddress;
    address internal multisig;

    uint256 public arbitrumFork;
    string public ARBITRUM_RPC_URL = vm.envString("ARBITRUM_RPC_URL");
    uint256 public constant BLOCK_NUM = 107460900;

    function _setUp() internal {
        arbitrumFork = vm.createSelectFork(ARBITRUM_RPC_URL, BLOCK_NUM);

        utils = new Utils();
        users = utils.createUsers(9);
        treasury = users[0];
        alice = users[1];
        bob = users[2];
        charlie = users[3];
        dennis = users[4];
        whale = users[5];
        admin = users[6];

        xloop = new MockXloopToken(treasury);
        wGLP = new MockWrappedGLP();
        xdc = new MockXDCToken();
        glpOracle = new GLPOracle();

        poolAddress = nonfungiblePositionManager.createAndInitializePoolIfNecessary(address(xloop), address(wGLP), 3000, 3361342611237137709020779);
        deal(address(xloop), alice, 1e6 ether);
        deal(address(wGLP), alice, 1e5 ether);
        vm.startPrank(alice);
        IERC20(xloop).approve(address(nonfungiblePositionManager), 1e6 ether);
        IERC20(wGLP).approve(address(nonfungiblePositionManager), 1e5 ether);
        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: address(xloop),
                token1: address(wGLP),
                fee: 3000,
                tickLower: -253080,
                tickUpper: -245040,
                amount0Desired: 1e6 ether,
                amount1Desired: 1e5 ether,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 300 // Set an appropriate deadline
            });

        (
            uint256 tokenId, 
            uint128 liquidity, 
            uint256 amount0, 
            uint256 amount1
        ) = nonfungiblePositionManager.mint(params);
        vm.stopPrank();

        console.log("tokenId: %s", tokenId);
        console.log("liquidity: %s", liquidity);
        console.log("amount0: %s", amount0);
        console.log("amount1: %s", amount1);

        xloopOracle = new XloopOracle(address(wGLP), address(xloop), poolAddress, address(glpOracle));
        xloopOracleWrapper = new XloopOracleWrapper(address(xloopOracle));

        curvePool = _deployCurvePool();
        deal(address(xdc), alice, 2e6 ether);
        deal(USDC, alice, 2e6 * 1e6);
        vm.startPrank(alice);
        assertEq(IERC20(xdc).balanceOf(address(alice)), 2e6 ether);
        assertEq(IERC20(USDC).balanceOf(address(alice)), 2e6 * 1e6);
        IERC20(xdc).approve(address(curvePool), 2e6 ether);
        IERC20(USDC).approve(address(curvePool), 2e6 * 1e6);
        uint256[2] memory amounts = [uint256(2e6) * 1e18, 2e6 * 1e6];
        ICurvePool(curvePool).add_liquidity(amounts, 0);
        vm.stopPrank();

        xdcOracle = new XDCOracle(curvePool);
        xdcOracleWrapper = new XDCOracleWrapper(address(xdcOracle));

        chainlinkWrapper = new ChainlinkWrapper();
        chainlinkWrapperWithIndex = new ChainlinkWrapperWithIndex();

        glpOracleWrapper = new GLPOracleWrapper(address(glpOracle));

        assetOracle = new MockChainlinkOracle();
        indexOracle = new MockChainlinkOracle();
        primaryWrapper = new ChainlinkWrapper();
        secondaryWrapper = new ChainlinkWrapper();
        
        oracleVerificator = new OracleVerificator(); // logic contract
        priceFeed = new PriceFeed(); // logic contract
        oracleVerificatorProxy = new ERC1967Proxy(address(oracleVerificator), ""); // storage contract
        priceFeedProxy = new ERC1967Proxy(address(priceFeed), ""); // storage contract

        bytes memory initOracleVerificatorData = abi.encodeWithSignature(
            "initialize(address)",
            admin
        );
        bytes memory initPriceFeedData = abi.encodeWithSignature(
            "initialize(address,address)",
            address(oracleVerificatorProxy),
            admin
        );
        address(oracleVerificatorProxy).functionCall(initOracleVerificatorData);
        address(priceFeedProxy).functionCall(initPriceFeedData);

        vm.warp(5 hours);
    }

    function isTickValid(int24 tick) internal pure returns (bool) {
        int24 tickSpacing = 60; // Replace with the actual tick spacing of the pool
        int24 maxTick = int24((type(int24).max / tickSpacing) * tickSpacing);
        int24 minTick = int24((type(int24).min / tickSpacing) * tickSpacing);
        return tick >= minTick && tick <= maxTick && tick % tickSpacing == 0;
    }

    function _deployCurvePool() private returns (address poolAddr) {
        poolAddr = ICurveFactory(curvePoolFactory).deploy_plain_pool(
            "XDC/USDC",
            "XDC/USDC",
            [address(xdc), USDC, address(0), address(0)],
            100,
            4000000,
            0,
            0
        );
    }

    function _deployUniswapV3Pool() private returns (address uniswapV3PoolAddr) {
        uniswapV3PoolAddr = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            address(xloop), 
            address(wGLP), 
            3000, 
            3361342611237137709020779
        );

        uint256 amount0 = 1e6 ether; // 1M xloop
        uint256 amount1 = 1e5 ether; // 100K wGLP
        uint256 amount0Min = 0;
        uint256 amount1Min = 0;
        address to = address(this);
        uint256 deadline = block.timestamp + 1000000000000000000000000;

        deal(address(xloop), alice, amount0);
        deal(address(wGLP), alice, amount1);

        vm.startPrank(alice);
        xloop.approve(address(nonfungiblePositionManager), amount0);
        wGLP.approve(address(nonfungiblePositionManager), amount1);

        (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0Out,
            uint256 amount1Out
        ) = nonfungiblePositionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(xloop),
                token1: address(wGLP),
                fee: 3000,
                tickLower: -201720,
                tickUpper: -200220,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                recipient: to,
                deadline: deadline
            })
        );

        console.log("tokenId: %s", tokenId);
        console.log("liquidity: %s", liquidity);
        console.log("amount0: %s", amount0Out);
        console.log("amount1: %s", amount1Out);

        vm.stopPrank();
    }

}
