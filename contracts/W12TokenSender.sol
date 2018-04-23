pragma solidity ^0.4.23;

import "./W12TokenDistributor.sol";


contract W12TokenSender is W12TokenDistributor {
    constructor() W12TokenDistributor() public { }

    function bulkTransfer(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts)
        external onlyOwner validateInput(_payment_ids, _receivers, _amounts) {

        bool success = false;

        for (uint i = 0; i < _receivers.length; i++) {
            if (!processedTransactions[_payment_ids[i]]) {
                success = token.transfer(_receivers[i], _amounts[i]);
                processedTransactions[_payment_ids[i]] = success;

                if (!success)
                    break;
            }
        }
    }

    function bulkTransferFrom(uint32[] _payment_ids, address _from, address[] _receivers, uint256[] _amounts)
        external onlyOwner validateInput(_payment_ids, _receivers, _amounts) {
        bool success = false;

        for (uint i = 0; i < _receivers.length; i++) {
            if (!processedTransactions[_payment_ids[i]]) {
                success = token.transferFrom(_from, _receivers[i], _amounts[i]);
                processedTransactions[_payment_ids[i]] = success;

                if (!success)
                    break;
            }
        }
    }

    function transferTokensToOwner() external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }
}
