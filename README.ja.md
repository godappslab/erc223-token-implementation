# ERC223トークンの実装

*Read this in other languages: [English](README.en.md), [日本語](README.ja.md).*

## 概要

これはERC223トークンについての実装したソースコード及び、ドキュメントです。

## トークンの設定

トークンの名称・シンボル・総供給量・小数点以下の桁数は `migrations/2_deploy_erc223_token.js` ファイル内の変数により指定を変えることができるような実装にしています。

```es6
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
```

**トークンの名称**

```
const name = 'GToken'; // Specify the name of your token
```

**トークンの単位**

```
const symbol = 'GT'; // Specify the symbol of your token
```


**小数点以下の桁数**

```
const decimals = 18; // Number of decimal places
```

**総供給量(整数表現)**

```
const totalSupply = 1000000000; // Total supply of tokens (integer representation)
```

## 仕様

基本的な仕様については、以下のURLで議論されている機能・仕様を実装する。

[Dexaran/ERC223\-token\-standard at Recommended](https://github.com/Dexaran/ERC223-token-standard/tree/Recommended)

例外として、以下の関数については、意図しない動作を引き起こす可能性があると判断し、実装していません。

```solidity
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
```

追加の仕様として以下の URL にて議論されている `tokenFallback()` を実行した際の戻り値を確認するように実装している。これにより、フォールバック関数が実行されてしまうことによるトークンの消失に対応する。

https://github.com/ethereum/EIPs/issues/223#issuecomment-423952050


## Test Cases

[Truffle Suite ](https://truffleframework.com/) を利用したテストスクリプトで動作確認を行う。

テストの実行結果を以下に貼り付ける。

```bash
$ truffle test
Using network 'test'.


Compiling your contracts...
===========================
> Compiling ./test/ImplementedERC223Fallback.sol
> Compiling ./test/NotImplementedERC223Fallback.sol
> Compiling ./test/NotImplementedERC223FallbackButHasFallback.sol
> Artifacts written to /var/folders/9y/6q4417_x24b107s0jc7g5gmw0000gp/T/test-119215-62107-oljwve.nornb
> Compiled successfully using:
   - solc: 0.5.0+commit.1d4f565a.Emscripten.clang



  Contract: [TEST] ERC223Token Transfer to EOA
       [LOG] Owner      : 1,000,000,000.000000000000000000
       [LOG] User1      : 0.000000000000000000
       [LOG] User2      : 0.000000000000000000
    ✓ Initial state is the owner address token holding number: 1,000,000,000.000000000000000000 (80ms)
       [LOG] Owner      : 999,999,900.000000000000000000
       [LOG] User1      : 100.000000000000000000
       [LOG] User2      : 0.000000000000000000
    ✓ Transfer to Owner->User1 100.000000000000000000 (133ms)
       [LOG] Owner      : 999,999,700.000000000000000000
       [LOG] User1      : 100.000000000000000000
       [LOG] User2      : 200.000000000000000000
    ✓ Transfer to Owner->User2 200.000000000000000000 (125ms)
       [LOG] Owner      : 999,999,700.000000000000000000
       [LOG] User1      : 100.000000000000000000
       [LOG] User2      : 200.000000000000000000
    ✓ Transfer to User1->User2 200.000000000000000000 (123ms)

  Contract: [TEST] ERC223Token Transfer to contract
       [LOG] implemented: 0.000000000000000000
       [LOG] ImplementedERC223Fallback : 0x8f0483125FCb9aaAEFA9209D8E9d7b9C8B9Fb90F
       [LOG] implemented: 100.000000000000000000
    ✓ Allow token transfer to implemented contract (160ms)
       [LOG] notImplemented: 0.000000000000000000
       [LOG] NotImplementedERC223Fallback : 0x2C2B9C9a4a25e24B174f26114e8926a9f2128FE4
       [LOG] Returned error: VM Exception while processing transaction: revert
       [LOG] notImplemented: 0.000000000000000000
    ✓ Not allow token transfer to no implemented contract (163ms)
       [LOG] hasFallback: 0.000000000000000000
       [LOG] NotImplementedERC223FallbackButHasFallback : 0xFB88dE099e13c3ED21F80a7a1E49f8CAEcF10df6
       [LOG] Returned error: VM Exception while processing transaction: revert
       [LOG] hasFallback: 0.000000000000000000
    ✓ Not allow transfer to has fallback contract (144ms)


  7 passing (1s)
```

## 実装

実装はGitHubにて公開する。

https://github.com/godappslab/erc223-token-implementation

## 参考文献

- [Dexaran/ERC223\-token\-standard at Recommended](https://github.com/Dexaran/ERC223-token-standard/tree/Recommended)

- [ERC223 token standard · Issue \#223 · ethereum/EIPs](https://github.com/ethereum/EIPs/issues/223)
