import EVMRevert from './helpers/EVMRevert';
import latestTime from './helpers/latestTime';
import { increaseTimeTo, duration } from './helpers/increaseTime';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const W12Token = artifacts.require('W12Token');
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const W12TokenSender = artifacts.require('W12TokenSender');

var balance = 0;

contract('W12TokenSender', (accounts) => {
    let token;

    let sut;


    const testData = {
        receivers: accounts.slice(1, 4),
        amounts: [1000, 2000, 3000],
        ids: [1, 2, 3],
				data: [1, 1745658789, 2, 1745658789, 3, 1745658789]

    };

    describe('when called not by an owner', () => {
        beforeEach(async () => {
            sut = await W12TokenSender.new({from: accounts[1]});
            token = W12Token.at(await sut.token());
        });

        it('should fail to transfer', async () => {
            await sut.bulkTransfer(testData.ids, testData.receivers, testData.amounts).should.be.rejected;

            for (let index = 0; index < testData.receivers.length; index++) {
                (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
            }
        });

        it('should fail to transfer - vesting', async () => {


            await sut.bulkVestingTransferFrom(sut.address, testData.receivers, testData.amounts, testData.data).should.be.rejected;

            for (let index = 0; index < testData.receivers.length; index++) {
                (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
            }
        });

        it('should fail to return tokens to owner', async () => {
            const ownerTokensBefore = await token.balanceOf(accounts[1]);

            await sut.transferTokensToOwner().should.be.rejected;

            (await token.balanceOf(accounts[1])).should.bignumber.equal(ownerTokensBefore);
        });
    });

    describe('when called by an owner', () => {
        beforeEach(async () => {
            sut = await W12TokenSender.new();
            token = W12Token.at(await sut.token());

            await sut.transferTokenOwnership();
            await token.mint(sut.address, 6000);
            await token.mint(accounts[0], 6000);
            await token.approve(sut.address, 6000);

        });

        describe('transfer', async () => {
            it('should transfer corresponding amount of tokens', async () => {
							await sut.bulkTransfer(testData.ids, testData.receivers, testData.amounts).should.be.fulfilled;

                for (let index = 0; index < testData.receivers.length; index++) {
                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal((testData.amounts[index]).toString());
                }
            });

            it('should transfer corresponding amount of tokens - vesting', async () => {


                await sut.bulkVestingTransferFrom(accounts[0], testData.receivers, testData.amounts, testData.data).should.be.fulfilled;

                for (let index = 0; index < testData.receivers.length; index++) {
                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal('0');
                }
            });

            it('should check if all arrays contains the same number of items', async () => {
                let totalTransferExpected = 0;

                await sut.bulkTransfer(testData.ids.slice(1)
                    , testData.receivers
                    , testData.amounts
                ).should.be.rejected;

                await sut.bulkTransfer(testData.ids
                    , testData.receivers.slice(1)
                    , testData.amounts
                ).should.be.rejected;

                await sut.bulkTransfer(testData.ids
                    , testData.receivers
                    , testData.amounts.slice(1)
                ).should.be.rejected;

                for (let index = 0; index < testData.receivers.length; index++) {
                    totalTransferExpected += testData.amounts[index];

                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
                }
            });

            it('should check if all arrays contains the same number of items - vesting', async () => {
                let totalTransferExpected = 0;

                await sut.bulkVestingTransferFrom(sut.address
                		, testData.receivers.slice(1)
                    , testData.amounts
										, testData.data
                ).should.be.rejected;

                await sut.bulkVestingTransferFrom(sut.address
                    , testData.receivers
                    , testData.amounts.slice(1)
										, testData.data
                ).should.be.rejected;

                await sut.bulkVestingTransferFrom(sut.address
                    , testData.receivers
                    , testData.amounts
										, testData.data.slice(1)
                ).should.be.rejected;

                for (let index = 0; index < testData.receivers.length; index++) {
                    totalTransferExpected += testData.amounts[index];

                    (await token.balanceOf(testData.receivers[index])).should.bignumber.equal(0);
                }
            });


            it('should check if receivers are zero addresses', async () => {
                await sut.bulkTransfer([4]
                    , [ZERO_ADDRESS]
                    , [444]
                ).should.be.rejected;
            });

            it('should check if receivers are zero addresses - vesting', async () => {
                await sut.bulkVestingTransferFrom(sut.address
                    , [ZERO_ADDRESS]
                    , [444]
										, [4, 5]
                ).should.be.rejected;
            });

            it('should fail when called to transfer more than it holds', async () => {
                const testData = {
                    receivers: accounts.slice(1, 5),
                    amounts: [1000, 2000, new BigNumber(10).pow(38), 1000],
                    ids: [10, 10, 11, 11]
                };                

                await sut.bulkTransfer(testData.ids, testData.receivers, testData.amounts).should.be.rejected;
            });

            it('should fail when called to transfer more than it holds - vesting', async () => {
                const testData = {
                    receivers: accounts.slice(1, 5),
                    amounts: [1000, 2000, new BigNumber(10).pow(38), 1000],
										data: [101, 101, 102, 102, 103, 103, 104, 104]
                };

                await sut.bulkVestingTransferFrom(testData.ids, sut.address, testData.receivers, testData.amounts, testData.vesting_times).should.be.rejected;
            });
        });
    });

});

