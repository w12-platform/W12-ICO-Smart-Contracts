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
const W12TokenDistributor = artifacts.require('W12TokenDistributor');

contract('W12TokenDistributor', async (accounts) => {
    let token;

    let sut;
    const receivers = accounts.slice(1);
    let owner = accounts[0];

    before(async () => {
        token = await W12Token.new();
    });

    describe('when correct token supplied', async () => {
        beforeEach(async () => {
            sut = await W12TokenDistributor.new(token.address);
        });

        it('should set token address', async () => {
            (await sut.token()).should.be.equal(token.address);
        });

        it('should set owner', async () => {
            (await sut.owner()).should.be.equal(owner);
        });
    });

    describe('when incorrect token supplied', async () => {
        it('should check if token address presented', async () => {
            await W12TokenDistributor.new().should.be.rejected;
        });

        it('should reject zero token address', async () => {
            await W12TokenDistributor.new(ZERO_ADDRESS).should.be.rejectedWith(EVMRevert);
        });
    });
});
