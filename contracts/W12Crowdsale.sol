pragma solidity ^0.4.23;

import "./W12TokenSender.sol";
import "./W12TokenMinter.sol";


contract W12Crowdsale is W12TokenDistributor {
    uint public presaleStartBlock = 5555596;
    uint public presaleEndBlock = 5816235;
    uint public crowdsaleStartBlock = 5907156;
    uint public crowdsaleEndBlock = 6095058;

    uint public presaleTokenBalance = 500 * (10 ** 24);
    uint public crowdsaleTokenBalance = 2 * (10 ** 27);

    enum Stage { Inactive, Presale, Crowdsale }


    constructor() public {
        uint tokenDecimalsMultiplicator = 10 ** 18;

        // Tokens to sell during the first two phases of ICO
        token.mint(address(this), presaleTokenBalance + crowdsaleTokenBalance);
        // Team, advisors, and founders
        token.mint(address(0x2), 1.5 * (10 ** 9) * tokenDecimalsMultiplicator);
        // Reserve fund
        token.mint(address(0x3), 1.5 * (10 ** 9) * tokenDecimalsMultiplicator);
        // Seed investors
        token.mint(address(0x4), 0.5 * (10 ** 9) * tokenDecimalsMultiplicator);
        // Partners
        token.mint(address(0x5), 0.2 * (10 ** 9) * tokenDecimalsMultiplicator);
        // Bounty and support of ecosystem
        token.mint(address(0x6), 0.2 * (10 ** 9) * tokenDecimalsMultiplicator);
        // Airdrop
        token.mint(address(0x7), 0.1 * (10 ** 9) * tokenDecimalsMultiplicator);
    }

    function () payable external {
        Stage currentStage = getStage();

        require(currentStage != Stage.Inactive);

        uint currentRate = getCurrentRate(block.number, currentStage);
        uint tokensBought = msg.value * (10 ** 18) / currentRate;

        token.transfer(msg.sender, tokensBought);
        advanceStage(tokensBought, currentStage);
    }

    function getCurrentRate(uint blockNumber, Stage currentStage) public view returns (uint) {
        uint currentBlock;

        if(currentStage == Stage.Presale) {
            currentBlock = blockNumber - presaleStartBlock;
            uint presaleCoef = currentBlock * 100 / (presaleEndBlock - presaleStartBlock);
            
            return 10000000000000 + 2000000000000 * presaleCoef / 100;
        }
        
        if(currentStage == Stage.Crowdsale) {
            currentBlock = blockNumber - crowdsaleStartBlock;
            uint crowdsaleCoef = currentBlock * 100 / (crowdsaleEndBlock - crowdsaleStartBlock);
            
            return 12750000000000 + 2250000000000 * crowdsaleCoef / 100;
        }
        

        revert();
    }

    function getStage() public view returns (Stage) {
        if(block.number >= crowdsaleStartBlock && block.number <= crowdsaleEndBlock) {
            return Stage.Crowdsale;
        }
        
        if(block.number >= presaleStartBlock && block.number <= presaleEndBlock) {
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

    function advanceStage(uint tokensBought, Stage currentStage) {
        if(currentStage == Stage.Presale) {
            if(tokensBought < presaleTokenBalance)
            {

                presaleTokenBalance -= tokensBought;
                return;
            }

            crowdsaleTokenBalance -= tokensBought - presaleTokenBalance;
            presaleTokenBalance = 0;
            crowdsaleStartBlock = block.number;

            return;
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
}