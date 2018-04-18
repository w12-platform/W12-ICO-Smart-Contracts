pragma solidity ^0.4.0;

import "./base/CappedToken.sol";
import "./base/DetailedERC20.sol";
import "./base/StandardBurnableToken.sol";


contract W12Token is StandardBurnableToken, CappedToken, DetailedERC20  {

    function W12Token() CappedToken(10**10) DetailedERC20("W12 Token", "W12", 18) public { }

}
