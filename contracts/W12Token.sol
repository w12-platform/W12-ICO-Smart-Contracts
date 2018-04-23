pragma solidity ^0.4.0;

import "./base/CappedToken.sol";
import "./base/DetailedERC20.sol";
import "./base/StandardBurnableToken.sol";


contract W12Token is StandardBurnableToken, CappedToken, DetailedERC20  {
    constructor() CappedToken(10**28) DetailedERC20("W12 Token", "W12", 18) public { }
}
