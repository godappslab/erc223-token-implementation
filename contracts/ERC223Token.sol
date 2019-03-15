pragma solidity ^0.5.0;

import "./ERC223Implementation.sol";

contract ERC223Token is ERC223Implementation {
    address public owner;

    // ---------------------------------------------
    // Modification : Only an owner can carry out.
    // ---------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owners can use");
        _;
    }

    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply) public {
        // Initial information of token
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply * (10 ** uint256(decimals));

        // The owner address is maintained.
        owner = msg.sender;

        // All tokens are allocated to an owner.
        balances[owner] = _totalSupply;
    }

}
