pragma solidity ^0.4.23;


import "../ownership/Ownable.sol";


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;
    
    mapping (address=>bool) private whiteList;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused || whiteList[msg.sender]);

        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused || whiteList[msg.sender]);

        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;

        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;

        emit Unpause();
    }

    function addToWhiteList(address[] _whiteList) external onlyOwner {
        require(_whiteList.length > 0);

        for(uint8 i = 0; i < _whiteList.length; i++) {
            assert(_whiteList[i] != address(0));

            whiteList[_whiteList[i]] = true;
        }
    }

    function removeFromWhiteList(address[] _blackList) external onlyOwner {
        require(_blackList.length > 0);

        for(uint8 i = 0; i < _blackList.length; i++) {
            assert(_blackList[i] != address(0));

            whiteList[_blackList[i]] = false;
        }
    }
}
