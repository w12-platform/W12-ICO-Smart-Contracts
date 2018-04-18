import EVMRevert from './helpers/EVMRevert';
import latestTime from './helpers/latestTime';
import { increaseTimeTo, duration } from './helpers/increaseTime';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const W12Token = artifacts.require('W12Token');

contract('W12Token', async (accounts) => {
    let sut;

    beforeEach(async () => {
        sut = await W12Token.new();
    });

    it('should have predefined name, symbol, maximup cap and decimails', async () => {
        (await sut.cap()).should.bignumber.equal(10000000000);
        (await sut.name()).should.be.equal("W12 Token");
        (await sut.symbol()).should.be.equal("W12");
        (await sut.decimals()).should.bignumber.equal(18);
    });
});
