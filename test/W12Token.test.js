import EVMRevert from './helpers/EVMRevert';
import latestTime from './helpers/latestTime';
import { increaseTimeTo, duration } from './helpers/increaseTime';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const million = new BigNumber(10).pow(6);
const tokenDecimals = new BigNumber(10).pow(18);
const W12Token = artifacts.require('W12Token');

contract('W12Token', async (accounts) => {
    let sut;

    beforeEach(async () => {
        sut = await W12Token.new();
    });

    it('should have predefined name, symbol, maximup cap and decimails', async () => {
        (await sut.cap()).should.bignumber.equal(million.mul(400).mul(tokenDecimals));
        (await sut.name()).should.be.equal("W12 Token");
        (await sut.symbol()).should.be.equal("W12");
        (await sut.decimals()).should.bignumber.equal(18);
    });

    describe('when paused', async () => {
        beforeEach(async () => {
            await sut.addToWhiteList([accounts[0]]).should.be.fulfilled;
            await sut.mint(accounts[0], 1).should.be.fulfilled;
            await sut.mint(accounts[1], 1).should.be.fulfilled;
            await sut.pause();
        });

        it('should be callable by whitelisted address', async () => {
            await sut.transfer(accounts[2], 1).should.be.fulfilled;
            const actualAccount2Balance = await sut.balanceOf(accounts[2]).should.be.fulfilled;

            actualAccount2Balance.should.bignumber.equal(1);
        });

        it('should not be callable by address which is not whitelisted', async () => {
            await sut.transfer(accounts[0], 1, {from: accounts[1]}).should.be.rejected;

            await sut.unpause();
            await sut.transfer(accounts[0], 1, {from: accounts[1]}).should.be.fulfilled;
        });
    });
});
