const fs = require('fs');
const ERC223Token = artifacts.require('ERC223Token');

const name = 'GToken'; // Specify the name of your token
const symbol = 'GT'; // Specify the symbol of your token
const decimals = 18; // Number of decimal places
const totalSupply = 1000000000; // Total supply of tokens (integer representation)

module.exports = (deployer) => {
    deployer.deploy(ERC223Token, name, symbol, decimals, totalSupply).then(() => {
        // Save ABI to file
        fs.mkdirSync('deploy/abi/', { recursive: true });
        fs.writeFileSync('deploy/abi/ERC223Token.json', JSON.stringify(ERC223Token.abi), { flag: 'w' });
    });
};
