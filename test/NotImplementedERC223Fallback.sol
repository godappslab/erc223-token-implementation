pragma solidity ^0.5.0;

/**
* @title Contract that will work with ERC223 tokens.
*/

// Smart Contract with ERC 223 token fallback function not implemented
contract NotImplementedERC223Fallback {
    address sender;
    uint256 anyValue;
    bytes anyData;

    function otherFunction(address _from, uint256 _value, bytes memory _data) public {
        sender = _from;
        anyValue = _value;
        anyData = _data;
    }

}
