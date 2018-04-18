pragma solidity ^0.4.18;

import "../base/StandardBurnableToken.sol";


contract StandardBurnableTokenMock is StandardBurnableToken {

    function StandardBurnableTokenMock(address initialAccount, uint initialBalance) public {
        balances[initialAccount] = initialBalance;
        totalSupply_ = initialBalance;
    }
}
