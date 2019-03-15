pragma solidity ^0.5.0;

import "../contracts/ERC223ContractReceiverIF.sol";

// A Smart Contract in which the token fallback function of ERC 223 is implemented
contract ImplementedERC223Fallback is ERC223ContractReceiverIF {
    address sender;
    uint256 anyValue;
    bytes anyData;

    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     *
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external returns (bool) {
        sender = _from;
        anyValue = _value;
        anyData = _data;

        return true;
    }
}
