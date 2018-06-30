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
        token.mint(address(this), dailyLimit); // you have a permission for mint, but it's daily amount, what about another days?
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

        if(lastLotEndsBefore(now)) // it means => lots[lots.length].expiresAt < now
            createTodaysLot(); // this function requires: !lastLotEndsBefore(now); it means => !(lots[lots.length].expiresAt < now)
            // so confused

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






// Каждые сутки в течение 1000 дней smart контракт будет выпускать и продавать 140000 токенов (0,035% от всей эмиссии). 
// Стоимость токена на Token Sale будет определяться по формуле Price = K/140000, 
// где K = количество средств переведённых на smart контракт за сутки.


contract GG {

    uint256 public startBlock;
    uint256 public dayTimeInBlocks = 6171; // 14 blocks per second => 60*60*24 = 86400 => 86400 / 14 = 6171 blocks per day;
    uint256 public currentDay;
    uint public dayLimit = 140000 * (10 ** decimals);
    
    mapping (uint256 => uint256) limitLeft;
    mapping (uint256 => uint256) dayPrice;
    mapping (uint256 =< bool) newDay;

    constructor() {
        startBlock = block.number; // for example 6 000 000;
    }
    
    function() external {
    
        currentDay = (block.numebr - startBlock) / dayTimeInBlocks; // get day number, for example => 5
        require(currentDay <= 1000); // 1000 days
        
        if (newDay[currentDay] == false) {
            
            ///////
            // what should to do with non-selling token from yesterday?
            ///////
           
            token.mint(address(this), dayLimit);
            newDay[currentDay] = true;
            
        }
        
        dayPrice[currentDay] = dayPrice[currentDay] + msg.value; // get K for price formula
        uint tokenAmount = dayPrice[currentDay] / dayLimit; // calculate tokens amount
        
        limitLeft[currentDay] = limitLeft[currentDay] - tokenAmount; // reduce dayLimit tokens
        require(limitLeft[currentDay] < dayLimit); // check if today contract sells more than day limit
        
        token.transfer(msg.sender, tokenAmount); // send tokens to buyer
        
    }
    
}
