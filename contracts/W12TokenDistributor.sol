pragma solidity ^0.4.23;

import "./W12Token.sol";

contract W12TokenDistributor is Ownable {
    W12Token public token;

    mapping(uint32 => bool) public processedTransactions;

    constructor() public {
        token = new W12Token();
    }

    function isTransactionSuccessful(uint32 id) external view returns (bool) {
        return processedTransactions[id];
    }

    modifier validateInput(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts) {
        require(_receivers.length == _amounts.length);
        require(_receivers.length == _payment_ids.length);

        _;
    }

    modifier validateInputVesting(uint32[] _data, address[] _receivers, uint256[] _amounts) {
        require(_receivers.length == _amounts.length);
        require(_receivers.length == _data.length / 2);
        _;
    }

    function transferTokenOwnership() external onlyOwner {
        token.transferOwnership(owner);
    }
}
