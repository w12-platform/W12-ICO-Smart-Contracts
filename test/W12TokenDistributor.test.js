import EVMRevert from './helpers/EVMRevert';
import latestTime from './helpers/latestTime';
import { increaseTimeTo, duration } from './helpers/increaseTime';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const W12Token = artifacts.require('W12Token');
const W12TokenDistributor = artifacts.require('W12TokenDistributor');

contract('W12TokenDistributor', async (accounts) => {
    let token;
    let sut;

    beforeEach(async () => {
        sut = await W12TokenDistributor.new();
        token = W12Token.at(await sut.token());
    });

    describe('transfer token ownership', async () => {
        it('should return ownership', async () => {
            await sut.transferTokenOwnership().should.be.fulfilled;
            (await token.owner()).should.be.equal(accounts[0]);
        });

        it('should fail to return ownership when called by not an owner', async () => {
            await sut.transferTokenOwnership({from: accounts[1]}).should.be.rejected;
            (await token.owner()).should.be.not.equal(accounts[0]);
        });
    });
});
