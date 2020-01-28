pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract Token is ERC20, ERC20Detailed {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) public ERC20Detailed(_name, _symbol, _decimals) {
        _mint(msg.sender, initialSupply);
    }
}
