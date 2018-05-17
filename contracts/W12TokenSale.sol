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
    MintableToken private token;

    struct Lot {
        uint expiresAt;
        uint totalBid;
        mapping (address=>uint) bids;
        address[] bidders;
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

    function () external payable {
        if(lastLotEndsBefore(now))
            createTodaysLot();

        Lot storage lot = lots[lots.length];

        if(lot.bids[msg.sender] == 0)
            lot.bidders.push(msg.sender);

        lot.bids[msg.sender] = lot.bids[msg.sender].add(msg.value);
        lot.totalBid = lot.totalBid.add(msg.value);
    }

    function withdrawFunds() external nonReentrant {
        require(tokensaleFundsWallet == msg.sender);

        tokensaleFundsWallet.transfer(address(this).balance);
    }
}
