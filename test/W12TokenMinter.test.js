const { BigNumber } = web3;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const W12Token = artifacts.require('W12Token');
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const W12TokenMinter = artifacts.require('W12TokenMinter');

contract('W12TokenMinter', (accounts) => {
    let token;

    let sut;
    const testData = {
        receivers: accounts.slice(1, 4),
        amounts: [1111, 2222, 3333],
        ids: [1, 2, 3]
    };
    let owner = accounts[0];

    describe('when called not by an owner', () => {
        beforeEach(async () => {
            sut = await W12TokenMinter.new({from: accounts[1]});
            token = W12Token.at(await sut.token());
        });

        it('should fail to mint', async () => {
        await sut.bulkMint(testData.ids, testData.receivers, testData.amounts).should.be.rejected;

            for (let index = 0; index < testData.receivers.length; index++) {
                (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
            }
        });

        it('should fail to return ownership', async () => {
            await sut.transferOwnership().should.be.rejected;
        });
    });

    describe('when owning a token', async () => {
        beforeEach(async () => {
            sut = await W12TokenMinter.new();
            token = W12Token.at(await sut.token());
        });

        describe('mint', async () => {
            it('should mint corresponding amount of tokens', async () => {
                let totalMintExpected = 0;

                await sut.bulkMint(testData.ids, testData.receivers, testData.amounts).should.be.fulfilled;

                for (let index = 0; index < testData.receivers.length; index++) {
                    totalMintExpected += testData.amounts[index];

                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(testData.amounts[index]);
                }

                (await token.totalSupply()).should.bignumber.equal(totalMintExpected);
            });

            it('should fail to mint when called by not an owner', async () => {
                let totalMintExpected = 0;

                await sut.bulkMint(testData.ids, testData.receivers, testData.amounts, {from: accounts[1]}).should.be.rejected;

                for (let index = 0; index < testData.receivers.length; index++) {
                    totalMintExpected += testData.amounts[index];

                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
                }

                (await token.totalSupply()).should.bignumber.equal(0);
            });

            it('should check if all arrays contains the same number of items', async () => {
                let totalMintExpected = 0;

                await sut.bulkMint(testData.ids.slice(1)
                    , testData.receivers
                    , testData.amounts
                ).should.be.rejected;

                await sut.bulkMint(testData.ids
                    , testData.receivers.slice(1)
                    , testData.amounts
                ).should.be.rejected;

                await sut.bulkMint(testData.ids
                    , testData.receivers
                    , testData.amounts.slice(1)
                ).should.be.rejected;

                for (let index = 0; index < testData.receivers.length; index++) {
                    totalMintExpected += testData.amounts[index];

                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
                }
            });

            it('should check if receivers are zero addresses', async () => {
                await sut.bulkMint([4]
                    , [ZERO_ADDRESS]
                    , [444]
                ).should.be.rejected;
            });

            it('should fail, do not mint, nor record transaction as successful when called to mint more than cap', async () => {
                const txId = 4;
                const cap = (await token.cap()).toNumber();

                await sut.bulkMint(testData.ids, testData.receivers, testData.amounts).should.be.fulfilled;
                await sut.bulkMint([txId], [accounts[4]], [cap]).should.be.rejected;

                (await sut.isTransactionSuccessful(txId)).should.be.equal(false);
            });

            it('should be able to mint cap number of tokens in one transaction', async () => {
                const cap = (await token.cap()).toNumber();

                await sut.bulkMint([4], [accounts[4]], [cap]).should.be.fulfilled;
            });

            it('should record processed transactions', async () => {
                await sut.bulkMint(testData.ids, testData.receivers, testData.amounts).should.be.fulfilled;

                for (let index = 0; index < testData.receivers.length; index++) {
                    (await sut.isTransactionSuccessful(testData.ids[index])).should.be.equal(true);
                }
            });

            describe('should not process transaction with known id', async () => {
                it('when it supplied in different batches', async () => {
                    await sut.bulkMint([4], [accounts[4]], [1000]).should.be.fulfilled;
                    await sut.bulkMint([4], [accounts[4]], [1000]).should.be.fulfilled;
    
                    (await token.balanceOf(accounts[4])).should.bignumber.equal(1000);
                });

                it('when it supplied in the batch', async () => {
                    await sut.bulkMint([4, 4], [accounts[2], accounts[4]], [1000, 2222]).should.be.fulfilled;
    
                    (await token.balanceOf(accounts[2])).should.bignumber.equal(1000);
                });
            });
        });
    });
});