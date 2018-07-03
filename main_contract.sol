pragma solidity ^0.4.24;

import "https://github.com/verifyas/contract/blob/master/contracts/CREDToken.sol";
import { SafeMath } from "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol";

contract firstbuy {
    
    
    address verify_address;//will be set to constant address of account owned be verify
    uint ether_from_fallback = 0;
    //fallback function needed to be implemented to recive ether
    //it collects ether that is sent without any data
    //we have a variable storing the amount of ether collected here
    //then a function will be called by verify to collect the amount
    function () external payable{
      ether_from_fallback = SafeMath.add(ether_from_fallback, msg.value); 
    }
    //collect function for verify to collect extra sent ether 
    function collect () external{
        if (ether_from_fallback>0){
            uint amount =  ether_from_fallback;
            ether_from_fallback = 0;
            verify_address.transfer(amount);
        }
    } 
    //function to handle the first part of the transaction: converts 1% to creds, sends
    //advanced payment to vendor, keeps remaining amount in escrow (currently in contract)
    //@param _recepient: the address of the seller
    //@_credit_ceiling: credit of seller
    function first_payment (address _recepient, uint _credit_ceiling) public payable{
      convert_to_creds(SafeMath.div(msg.value,100));
      uint amount = SafeMath.div(SafeMath.mul(msg.value, 99), 100);
        if (amount<=_credit_ceiling)
        _recepient.transfer(amount);
        else if (_credit_ceiling<amount){
            if (_credit_ceiling > 0){
                _recepient.transfer(_credit_ceiling);
            }
            convert_to_stablecoin(amount-_credit_ceiling);
        }
        
    }
    
    //place holders for functions to do the exchanges
    //right now if they do nothing the contract can still work fine with ether
    function convert_to_stablecoin (uint amount) private{
        
    }
    function convert_to_creds (uint amount) private{
        
    }
}
