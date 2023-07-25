// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libs/TransferHelper.sol";
import "../interfaces/IRewardRouter.sol";
import "../interfaces/IRewardTracker.sol";

contract MockWrappedGLP is 
    ERC20("Xloop Wrapped GLP", "wGLP"), 
    Ownable, 
    ReentrancyGuard 
{
    using Address for address;

    string public constant NAME = "WrappedGLP";
    address public constant SGLP = 0x2F546AD4eDD93B956C8999Be404cdCAFde3E89AE; // staked GLP
    address public constant FGLP = 0x4e971a87900b931fF39d1Aad67697F49835400b6; // fee GLP
    address public constant FSGLP = 0x1aDDD80E6039594eE970E5872D247bf0414C8903; // fee + staked GLP
    address public constant GMX_REWARD_ROUTER = 0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1; // GMX reward router V2
 
    receive() external payable {}

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "WG: invalid amount");

        address caller = _msgSender();
        TransferHelper.safeTransferFrom(
            SGLP, 
            caller, 
            address(this), 
            amount
        );
        _mint(caller, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "WG: invalid amount");

        address caller = _msgSender();
        require(balanceOf(caller) >= amount, "WG: insufficient amount");
        _burn(caller, amount);
        TransferHelper.safeTransfer(SGLP, caller, amount);
    }

    function harvest() external nonReentrant {
        IRewardRouter(GMX_REWARD_ROUTER).handleRewards(
            true, 
            true, 
            true, 
            true, 
            true, 
            true, 
            true
        );
    }

    function claimRewards(address _treasury) external onlyOwner {
        require(_treasury != address(0), "WG: invalid address");

        uint256 amount = getETHBalance();
        TransferHelper.safeTransferETH(_treasury, amount);
    }

    function retrieveLostTokens(address token) external onlyOwner nonReentrant {
        require(
            token != address(SGLP) && 
            token != address(0) &&
            token.isContract(), 
            "WG: invalid token"
        );

        uint256 balance = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, _msgSender(), balance);
    }

    function getBalance() public view returns (uint256) {
        return IERC20(FSGLP).balanceOf(address(this));
    }

    function getETHBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getClaimableReward() external view returns (uint256) {
        return IRewardTracker(FGLP).claimable(address(this));
    }
}
