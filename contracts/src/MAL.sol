// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MAL is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18;
    address public minter;
    event MinterUpdated(address indexed newMinter);

    constructor(uint256 initialSupply) ERC20("Malo Labs Token", "MAL") {
        require(initialSupply > 0, "Initial supply cannot be 0");
        require(initialSupply <= MAX_SUPPLY, "Exceeds max supply");
        _mint(msg.sender, initialSupply);
        minter = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == minter, "Not minter");
        uint256 currentSupply = totalSupply();
        require(currentSupply + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "Invalid address");
        minter = newMinter;
        emit MinterUpdated(newMinter);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}