pragma solidity ^0.4.23;

import "./W12TokenMinter.sol";
import "./math/SafeMath.sol";
import "./lifecycle/ReentrancyGuard.sol";
import "./base/MintableToken.sol";


contract W12TokenSale is W12TokenMinter, ReentrancyGuard {
    using SafeMath for uint;

    uint public tokenSaleStartDate = 1541030400;
    uint public dailyLimit = 140000 * (10 ** 18);

    address public tokensaleFundsWallet;
    Lot[] private lots;
    mapping(address => mapping(uint8 => uint)) private bidderParticipatedLots;
    mapping(address => uint8[]) private bidderLots;

    MintableToken private token;

    struct Lot {
        uint expiresAt;
        uint totalBid;
    }

    constructor (uint firstAuctionExpiryDate, MintableToken _token, address _tokensaleFundsWallet) public {
        require(firstAuctionExpiryDate > now);
        require(_token != address(0x0));
        require(_tokensaleFundsWallet != address(0x0));

        tokensaleFundsWallet = _tokensaleFundsWallet;
        token = _token;

        createNewLot(firstAuctionExpiryDate);
    }

    function createNewLot(uint expiryDate) internal {
        require(lastLotEndsBefore(expiryDate));
        require(lots.length < 1000);

        uint lotNumber = lots.length++;
        lots[lotNumber].expiresAt = expiryDate;
        token.mint(address(this), dailyLimit);
    }

    function isBidder() internal view returns (bool) {
        return bidderLots[msg.sender].length > 0;
    }

    function listBidder(uint8 lotIndex) internal {
        if(bidderParticipatedLots[msg.sender][lotIndex] == 0) {
            bidderLots[msg.sender].push(lotIndex);
        }

        bidderParticipatedLots[msg.sender][lotIndex] = bidderParticipatedLots[msg.sender][lotIndex].add(msg.value);
    }

    function createTodaysLot() internal {
        require(!lastLotEndsBefore(now));

        uint numberOfDaysSinceLastLot = (now - lastLotExpiryDate()) / 1 days + 1;
        createNewLot(lastLotExpiryDate() + 1 days * numberOfDaysSinceLastLot);
    }

    function lastLotEndsBefore(uint date) public view returns (bool) {
        return lastLotExpiryDate() < date;
    }

    function lastLotExpiryDate() public view returns (uint) {
        return lots[lots.length].expiresAt;
    }

    function calculateTokenReward() public returns (uint reward) {
        uint8[] storage lotIds = bidderLots[msg.sender];
        uint8[] storage newLots;

        for (uint8 i = 0; i < lotIds.length; i++) {
            uint amountSent = bidderParticipatedLots[msg.sender][i];
            Lot storage lot = lots[i];

            if(amountSent == 0)
                continue;

            if(lot.expiresAt > now) {
                newLots.push(i);

                continue;
            }

            bidderParticipatedLots[msg.sender][i] = 0;
            reward += dailyLimit.mul(amountSent).div(lot.totalBid);
        }

        bidderLots[msg.sender].length = 0;
        bidderLots[msg.sender] = newLots;
    }

    function () external payable {
        require(msg.value > 0);

        if(lastLotEndsBefore(now))
            createTodaysLot();

        uint8 lotIndex = uint8(lots.length) - 1;
        Lot storage lot = lots[lotIndex];

        lot.totalBid = lot.totalBid.add(msg.value);

        listBidder(lotIndex);
    }

    function collectReward() external {
        require(isBidder());

        uint tokens = calculateTokenReward();

        token.transfer(msg.sender, tokens);
    }

    function withdrawFunds() external nonReentrant {
        require(tokensaleFundsWallet == msg.sender);

        tokensaleFundsWallet.transfer(address(this).balance);
    }
}
