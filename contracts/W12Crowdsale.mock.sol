pragma solidity ^0.4.23;

import "./W12Crowdsale.sol";


contract W12CrowdsaleMock is W12Crowdsale {
    function setPresaleStartBlock(uint32 _presaleStartBlock) external {
        presaleStartBlock = _presaleStartBlock;
    }

    function setPresaleEndBlock(uint32 _presaleEndBlock) external {
        presaleEndBlock = _presaleEndBlock;
    }

    function setCrowdsaleStartBlock(uint32 _crowdsaleStartBlock) external {
        crowdsaleStartBlock = _crowdsaleStartBlock;
    }

    function setCrowdsaleEndBlock(uint32 _crowdsaleEndBlock) external {
        crowdsaleEndBlock = _crowdsaleEndBlock;
    }
}
