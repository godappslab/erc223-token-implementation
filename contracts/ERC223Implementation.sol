pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

import "./ERC223Interface.sol";
import "./ERC223ContractReceiverIF.sol";

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
contract ERC223Implementation is ERC223Interface {
    // Load library
    using SafeMath for uint256;
    using Address for address;

    // Token properties
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;

    mapping(address => uint256) balances;

    // Function to access name of token .
    function name() external view returns (string memory) {
        return _name;
    }

    // Function to access symbol of token .
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    // Function to access decimals of token .
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    // Function to access total supply of tokens .
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint256 _value, bytes calldata _data) external returns (bool success) {
        if (_to.isContract()) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint256 _value) external returns (bool success) {
        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if (_to.isContract()) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint256 _value, bytes memory _data) private returns (bool success) {
        require(_value <= balances[msg.sender], "Insufficient funds");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    //function that is called when transaction target is a contract
    function transferToContract(address _to, uint256 _value, bytes memory _data) private returns (bool success) {
        require(_value <= balances[msg.sender], "Insufficient funds");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        ERC223ContractReceiverIF receiver = ERC223ContractReceiverIF(_to);

        // https://github.com/ethereum/EIPs/issues/223#issuecomment-433458948
        bool fallbackExecutionResult = receiver.tokenFallback(msg.sender, _value, _data);
        if (fallbackExecutionResult == false) {
            revert("Transfer to contract requires tokenFallback() function");
            return false;
        }

        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);

        return true;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }
}
