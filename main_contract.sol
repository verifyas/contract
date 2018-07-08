pragma solidity ^0.4.24;

import 'OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'dapphub/ds-token/blob/master/src/token.sol';

contract firstbuy {
    
    using SafeMath for unit;
    DaiContract dai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

    /*empty constructor marked as payable*/
    constructor () public payable {
    
    }
    
    address verify_address;//will be set to constant address of account owned be verify
    uint ether_from_fallback = 0;
    
    /* Fallbck function needs to be implemented to receive Ether. It collets Ether that is sent 
     * without any other data. Variable stores amount of Ether collected. Function is called to 
     * verify that amount.*/
    function () external payable{
      ether_from_fallback = ether_from_fallback.add(msg.value);
    }
    
    /*Collects any additionally sent Ether*/
    function collect () external {
        if (ether_from_fallback > 0){
            uint amount = ether_from_fallback;
            ether_from_fallback = 0;
            verify_address.transfer(amount); //QUESTION: will this address be storing Ether or DAI?
        }
    }
    
    /* Handles first part of transaction by converting 1% of Ether to CRED, sending advanced payment
     * to vendor and keeps remaining amount in escrow
     * @param _recepient: the address of the seller
     * @param _credit_ceiling: credit of the seller */
    function first_payment (address _recepient, uint _credit_ceiling) public payable {
      convert_to_creds((msg.value).div(100));
      uint amount = ((msg.value).mul(99)).div(100);
      if (amount <= _credit_ceiling) {
        _recepient.transfer(amount);
      } else {
          if (_credit_ceiling > 0) {
              _recepient.transfer(_credit_ceiling);
          }
          convert_to_stablecoin(amount.sub(_credit_ceiling));
        }
    }

    /* This function is called to transfer the remaining funds owned to the seller once successful
     * delivery of goods/services is confirmed by the buyer.
     * @param _recepient: address of the seller
     * @param _amount: amount left to be transferred to the seller */
    function complete_payment (address _recepient, uint _amount) public payable {
        dai.transferFrom(verify_address, _recepient, amount);
    }
    
    //place holders for functions to do the exchanges
    //right now if they do nothing the contract can still work fine with ether
    function convert_to_stablecoin (uint amount) private{
        
    }
    function convert_to_creds (uint amount) private{
        
    }
}
