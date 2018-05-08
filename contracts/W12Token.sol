pragma solidity ^0.4.0;

import "./base/CappedToken.sol";
import "./base/DetailedERC20.sol";
import "./base/StandardBurnableToken.sol";
import "./base/PausableToken.sol";


contract W12Token is StandardBurnableToken, CappedToken, DetailedERC20, PausableToken  {
    constructor() CappedToken(400*(10**24)) DetailedERC20("W12 Token", "W12", 18) public { }
}
