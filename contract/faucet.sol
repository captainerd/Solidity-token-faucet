
 /*for BSC use pancake */
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';

/* for eth use openzeppelin
import @openzeppelin/contracts/token/ERC20/IERC20.sol
*/

import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol';
 

pragma solidity 0.6.12;


/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter = 1;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}
pragma solidity 0.6.12;

contract Faucet is Ownable {
    uint256  public tokenAmount = 3000000000;
    uint256  public waitTime =  2380 minutes;
    using SafeBEP20 for IBEP20;
    IBEP20 public tokenInstance;
    
    mapping(address => uint256) lastAccessTime;

    constructor(address _tokenInstance) public {
        require(_tokenInstance != address(0));
        tokenInstance = IBEP20(_tokenInstance);
    }
    function withdraw(uint256 _tokenAmount) public onlyOwner {
         tokenInstance.safeTransfer(address(msg.sender), _tokenAmount);
    }
    function updateFaucet(uint256 _tokenAmount, uint256 _waitTime) public onlyOwner {
    
    tokenAmount =  _tokenAmount;
       waitTime = _waitTime;
    }

    function  requestTokens() external {
        require(allowedToWithdraw(msg.sender),'You already ate!');
         tokenInstance.safeTransfer(address(msg.sender), tokenAmount);
       lastAccessTime[msg.sender] = block.timestamp + waitTime;
    }

    function allowedToWithdraw(address _address) public view returns (bool) {
        if(lastAccessTime[_address] == 0) {
            return true;
        } else if(block.timestamp >= lastAccessTime[_address]) {
            return true;
        }
        return false;
    }
}