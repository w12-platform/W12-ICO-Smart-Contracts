pragma solidity 0.4.21;

import "./W12Token.sol";

contract W12TokenDistributor is Ownable {
    W12Token public token;

    // id => wasAlreadyProcessed
    mapping(uint32 => bool) public processedTransactions;

    function W12TokenDistributor(W12Token _token) public {
        require(_token != address(0));

        token = _token;
    }

    function isTransactionSuccessful(uint32 id) external view returns (bool) {
        return processedTransactions[id];
    }
}

contract W12TokenSender is W12TokenDistributor {
    function W12TokenSender(W12Token _token) W12TokenDistributor(_token) public { }

    function bulkTransfer(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts) external onlyOwner {
        require(_receivers.length == _amounts.length);
        require(_receivers.length == _payment_ids.length);

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

    function bulkTransferFrom(uint32[] _payment_ids, address _from, address[] _receivers, uint256[] _amounts) external onlyOwner {
        require(_receivers.length == _amounts.length);
        require(_receivers.length == _payment_ids.length);
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

contract W12TokenMinter is W12TokenDistributor {
    function W12TokenMinter(W12Token _token) W12TokenDistributor(_token) public { }

    function bulkMint(uint32[] _payment_ids, address[] _receivers, uint256[] _amounts) external onlyOwner {
        require(_receivers.length == _amounts.length);
        require(_receivers.length == _payment_ids.length);

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

    function transferTokenOwnership() external onlyOwner {
        token.transferOwnership(owner);
    }
}
