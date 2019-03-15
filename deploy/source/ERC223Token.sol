pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface ERC223Interface {
    function balanceOf(address who) external view returns (uint256);
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function decimals() external view returns (uint8 _decimals);
    function totalSupply() external view returns (uint256 _supply);

    function transfer(address to, uint256 value) external returns (bool ok);
    function transfer(address to, uint256 value, bytes calldata data) external returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

/* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol */
interface ERC223ContractReceiverIF {
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external returns (bool);
}

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