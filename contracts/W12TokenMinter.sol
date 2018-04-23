pragma solidity ^0.4.23;

import "./W12TokenDistributor.sol";


contract W12TokenMinter is W12TokenDistributor {
    constructor() W12TokenDistributor() public { }

    function bulkMint(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts)
        external onlyOwner validateInput(_payment_ids, _receivers, _amounts) {
        bool success = false;

        for (uint i = 0; i < _receivers.length; i++) {
            require(_receivers[i] != address(0));

            if (!processedTransactions[_payment_ids[i]]) {
                success = token.mint(_receivers[i], _amounts[i]);
                processedTransactions[_payment_ids[i]] = success;

                if (!success)
                    break;
            }
        }
    }
}