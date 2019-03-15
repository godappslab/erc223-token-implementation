pragma solidity ^0.5.0;

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol */
interface ERC223ContractReceiverIF {
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external returns (bool);
}
