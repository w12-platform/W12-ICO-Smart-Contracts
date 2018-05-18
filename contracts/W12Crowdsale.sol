pragma solidity ^0.4.23;

import "./W12TokenDistributor.sol";
import "./lifecycle/ReentrancyGuard.sol";


contract W12Crowdsale is W12TokenDistributor, ReentrancyGuard {
    uint public presaleStartDate = 1526774400;
    uint public presaleEndDate = 1532131200;
    uint public crowdsaleStartDate = 1532649600;
    uint public crowdsaleEndDate = 1538092800;

    uint public presaleTokenBalance = 20 * (10 ** 24);
    uint public crowdsaleTokenBalance = 80 * (10 ** 24);

    address public crowdsaleFundsWallet;

    enum Stage { Inactive, FlashSale, Presale, Crowdsale }

    constructor() public {
        uint tokenDecimalsMultiplicator = 10 ** 18;

        // Tokens to sell during the first two phases of ICO
        token.mint(address(this), presaleTokenBalance + crowdsaleTokenBalance);
        // Team, advisors, and founders
        token.mint(address(0x2), 60 * (10 ** 6) * tokenDecimalsMultiplicator);
        // Reserve fund
        token.mint(address(0x3), 60 * (10 ** 6) * tokenDecimalsMultiplicator);
        // Seed investors
        token.mint(address(0x4), 20 * (10 ** 6) * tokenDecimalsMultiplicator);
        // Partners
        token.mint(address(0x5),  8 * (10 ** 6) * tokenDecimalsMultiplicator);
        // Bounty and support of ecosystem
        token.mint(address(0x6),  8 * (10 ** 6) * tokenDecimalsMultiplicator);
        // AirdropgetStage
        token.mint(address(0x7),  4 * (10 ** 6) * tokenDecimalsMultiplicator);

        // Wallet to hold collected Ether
        crowdsaleFundsWallet = address(0x8);
    }

    function () payable external {
        Stage currentStage = getStage();

        require(currentStage != Stage.Inactive);

        uint currentRate = getCurrentRate();
        uint tokensBought = msg.value * (10 ** 18) / currentRate;

        token.transfer(msg.sender, tokensBought);
        advanceStage(tokensBought, currentStage);
    }

    function getCurrentRate() public view returns (uint) {
        uint currentSaleTime;
        Stage currentStage = getStage();

        if(currentStage == Stage.Presale) {
            currentSaleTime = now - presaleStartDate;
            uint presaleCoef = currentSaleTime * 100 / (presaleEndDate - presaleStartDate);
            
            return 262500000000000 + 35000000000000 * presaleCoef / 100;
        }
        
        if(currentStage == Stage.Crowdsale) {
            currentSaleTime = now - crowdsaleStartDate;
            uint crowdsaleCoef = currentSaleTime * 100 / (crowdsaleEndDate - crowdsaleStartDate);
            
            return 315000000000000 + 35000000000000 * crowdsaleCoef / 100;
        }

        if(currentStage == Stage.FlashSale) {
            return 245000000000000;
        }

        revert();
    }

    function getStage() public view returns (Stage) {
        if(now >= crowdsaleStartDate && now < crowdsaleEndDate) {
            return Stage.Crowdsale;
        }

        if(now >= presaleStartDate) {
            if(now < presaleStartDate + 1 days)
                return Stage.FlashSale;

            if(now < presaleEndDate)
                return Stage.Presale;
        }

        return Stage.Inactive;
    }

    function bulkTransfer(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts)
        external onlyOwner validateInput(_payment_ids, _receivers, _amounts) {

        bool success = false;

        for (uint i = 0; i < _receivers.length; i++) {
            if (!processedTransactions[_payment_ids[i]]) {
                success = token.transfer(_receivers[i], _amounts[i]);
                processedTransactions[_payment_ids[i]] = success;

                if (!success)
                    break;

                advanceStage(_amounts[i], getStage());
            }
        }
    }

    function transferTokensToOwner() external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function advanceStage(uint tokensBought, Stage currentStage) internal {
        if(currentStage == Stage.Presale) {
            if(tokensBought <= presaleTokenBalance)
            {
                presaleTokenBalance -= tokensBought;
                return;
            }
        }
        
        if(currentStage == Stage.Crowdsale) {
            if(tokensBought <= crowdsaleTokenBalance)
            {
                crowdsaleTokenBalance -= tokensBought;
                return;
            }
        }

        revert();
    }

    function withdrawFunds() external nonReentrant {
        require(crowdsaleFundsWallet == msg.sender);

        crowdsaleFundsWallet.transfer(address(this).balance);
    }

    function setPresaleStartDate(uint32 _presaleStartDate) external onlyOwner {
        presaleStartDate = _presaleStartDate;
    }

    function setPresaleEndDate(uint32 _presaleEndDate) external onlyOwner {
        presaleEndDate = _presaleEndDate;
    }

    function setCrowdsaleStartDate(uint32 _crowdsaleStartDate) external onlyOwner {
        crowdsaleStartDate = _crowdsaleStartDate;
    }

    function setCrowdsaleEndDate(uint32 _crowdsaleEndDate) external onlyOwner {
        crowdsaleEndDate = _crowdsaleEndDate;
    }
}
