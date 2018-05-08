pragma solidity ^0.4.23;

import "./W12TokenSender.sol";
import "./W12TokenMinter.sol";


contract W12Crowdsale is W12TokenDistributor {
    uint public presaleStartBlock = 5646675;
    uint public presaleEndBlock = 5838497;
    uint public crowdsaleStartBlock = 6054299;
    uint public crowdsaleEndBlock = 6431950;

    uint public presaleTokenBalance = 20 * (10 ** 24);
    uint public crowdsaleTokenBalance = 80 * (10 ** 24);

    enum Stage { Inactive, Presale, Crowdsale }


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
        // Airdrop
        token.mint(address(0x7),  4 * (10 ** 6) * tokenDecimalsMultiplicator);
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
            
            return 262500000000000 + 35000000000000 * presaleCoef / 100;
        }
        
        if(currentStage == Stage.Crowdsale) {
            currentBlock = blockNumber - crowdsaleStartBlock;
            uint crowdsaleCoef = currentBlock * 100 / (crowdsaleEndBlock - crowdsaleStartBlock);
            
            return 315000000000000 + 35000000000000 * crowdsaleCoef / 100;
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

    function advanceStage(uint tokensBought, Stage currentStage) internal {
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

    function withdrawFunds() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function setPresaleStartBlock(uint32 _presaleStartBlock) external onlyOwner {
        presaleStartBlock = _presaleStartBlock;
    }

    function setPresaleEndBlock(uint32 _presaleEndBlock) external onlyOwner {
        presaleEndBlock = _presaleEndBlock;
    }

    function setCrowdsaleStartBlock(uint32 _crowdsaleStartBlock) external onlyOwner {
        crowdsaleStartBlock = _crowdsaleStartBlock;
    }

    function setCrowdsaleEndBlock(uint32 _crowdsaleEndBlock) external onlyOwner {
        crowdsaleEndBlock = _crowdsaleEndBlock;
    }
}