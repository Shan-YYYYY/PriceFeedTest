// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockXloopToken is ERC20 {

    uint256 internal constant _1_BILLION = 1e27;
    address public immutable protocolTreasury;

    constructor(address _protocolTreasury) 
        ERC20("Xloop Governance Token", "Xloop") 
    {
        require(_protocolTreasury != address(0), "XT: invalid treasury");
        protocolTreasury = _protocolTreasury;

        _mint(_protocolTreasury, _1_BILLION);
    }

    function burn(address _account, uint256 _amount) external {
        _burn(_account, _amount);
    }

    function mint(address _account, uint256 _amount) external {
        _mint(_account, _amount);
    }
}
