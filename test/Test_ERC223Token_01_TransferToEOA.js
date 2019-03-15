const ERC223Token = artifacts.require('ERC223Token');
const BigNumber = require('bignumber.js');

const toHumanReadableNumber = function(number, decimals) {
    return new BigNumber(number).div(BigNumber(10).pow(decimals)).toFormat(decimals);
};

contract('[TEST] ERC223Token Transfer to EOA', async (accounts) => {
    const decimals = 18;
    const totalSupply = 1000000000 * 10 ** decimals;
    const transferToUser1 = 100 * 10 ** decimals;
    const transferToUser2 = 200 * 10 ** decimals;

    const ownerAddress = accounts[0];
    const user1 = accounts[1];
    const user2 = accounts[2];

    const log = function() {
        console.log('       [LOG]', ...arguments);
    };

    const balanceLog = (ownderValue = 0, distValue = 0, userValue = 0) => {
        log('Owner      :', toHumanReadableNumber(ownderValue, decimals));
        log('User1      :', toHumanReadableNumber(distValue, decimals));
        log('User2      :', toHumanReadableNumber(userValue, decimals));
    };

    const assertAmountEqual = function(a_value, b_value) {
        assert.equal(toHumanReadableNumber(a_value, decimals), toHumanReadableNumber(b_value, decimals));
    };

    it(`Initial state is the owner address token holding number: ${toHumanReadableNumber(totalSupply, decimals)}`, async () => {
        const token = await ERC223Token.deployed();

        const ownerBalance = await token.balanceOf.call(ownerAddress);
        const user1Balance = await token.balanceOf.call(user1);
        const user2Balance = await token.balanceOf.call(user2);

        balanceLog(ownerBalance, user1Balance, user2Balance);

        assertAmountEqual(ownerBalance, totalSupply);
        assertAmountEqual(user1Balance, 0);
        assertAmountEqual(user2Balance, 0);
    });

    it(`Transfer to Owner->User1 ${toHumanReadableNumber(transferToUser1, decimals)}`, async () => {
        const token = await ERC223Token.deployed();

        await token.transfer.sendTransaction(user1, transferToUser1.toString());

        const ownerBalance = await token.balanceOf.call(ownerAddress);
        const user1Balance = await token.balanceOf.call(user1);
        const user2Balance = await token.balanceOf.call(user2);

        balanceLog(ownerBalance, user1Balance, user2Balance);

        assertAmountEqual(ownerBalance, BigNumber(totalSupply).minus(transferToUser1));
        assertAmountEqual(user1Balance, transferToUser1);
        assertAmountEqual(user2Balance, 0);
    });

    it(`Transfer to Owner->User2 ${toHumanReadableNumber(transferToUser2, decimals)}`, async () => {
        const token = await ERC223Token.deployed();

        await token.transfer.sendTransaction(user2, transferToUser2.toString());

        const ownerBalance = await token.balanceOf.call(ownerAddress);
        const user1Balance = await token.balanceOf.call(user1);
        const user2Balance = await token.balanceOf.call(user2);

        balanceLog(ownerBalance, user1Balance, user2Balance);

        assertAmountEqual(
            ownerBalance,
            BigNumber(totalSupply)
                .minus(transferToUser1)
                .minus(transferToUser2)
        );
        assertAmountEqual(ownerBalance, totalSupply - transferToUser1 - transferToUser2);
        assertAmountEqual(user1Balance, transferToUser1);
        assertAmountEqual(user2Balance, transferToUser2);
    });

    it(`Transfer to User1->User2 ${toHumanReadableNumber(transferToUser2, decimals)}`, async () => {
        const token = await ERC223Token.deployed();

        try {
            await token.transfer.sendTransaction(user1, transferToUser2.toString(), { from: user1 });
        } catch (e) {
            const reverted = e.message.search('revert') >= 0;
            assert.equal(reverted, true);

            const ownerBalance = await token.balanceOf.call(ownerAddress);
            const user1Balance = await token.balanceOf.call(user1);
            const user2Balance = await token.balanceOf.call(user2);

            balanceLog(ownerBalance, user1Balance, user2Balance);

            assertAmountEqual(
                ownerBalance,
                BigNumber(totalSupply)
                    .minus(transferToUser1)
                    .minus(transferToUser2)
            );
            assertAmountEqual(ownerBalance, totalSupply - transferToUser1 - transferToUser2);
            assertAmountEqual(user1Balance, transferToUser1);
            assertAmountEqual(user2Balance, transferToUser2);

            return;
        }

        assert.fail('Expected throw not received');
        return;
    });
});
