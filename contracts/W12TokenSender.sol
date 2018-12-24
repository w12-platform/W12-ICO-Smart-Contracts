pragma solidity ^0.4.23;

import "./W12TokenDistributor.sol";
import "./base/TokenTimelock.sol";


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


//  _data - _payment_ids, vesting_dates
    function bulkVestingTransferFrom(address _from, address[] _receivers, uint256[] _amounts, uint32[] _data)
        external onlyOwner validateInputVesting(_data, _receivers, _amounts) {
        bool success = false;

        for (uint i = 0; i < _receivers.length; i++) {
            if (!processedTransactions[_data[i * 2]]) {

								TokenTimelock vault = new TokenTimelock(token, _receivers[i], _data[i * 2 + 1]);

								success = token.transferFrom(_from, address(vault), _amounts[i]);
								processedTransactions[_data[i * 2]] = success;
                if (!success)
                    break;
            }
        }
    }
}
