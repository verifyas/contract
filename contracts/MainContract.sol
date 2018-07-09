pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract MainContract {

    constructor () public payable {
    }

    address addressVerify; // TODO: Set to Verify Ethereum address

    uint collectedEther = 0;

    function() external payable {
        collectedEther = SafeMath.add(collectedEther, msg.value); 
    }

    function collect () external {
        if (collectedEther > 0) {
            uint amount = collectedEther;
            collectedEther = 0;
            addressVerify.transfer(amount);
        }
    }

    function sendFundsToVerify (address addressSeller, uint creditCeiling) public payable {
        uint transactionFee = SafeMath.div(msg.value, 100);
        toCredToken(transactionFee);
        uint payment = SafeMath.sub(msg.value, transactionFee);
        if (payment <= creditCeiling) {
            addressSeller.transfer(payment);
        } else if (creditCeiling < payment) {
            if (creditCeiling > 0) {
                addressSeller.transfer(creditCeiling);
            }
            toDaiToken(SafeMath.sub(payment, creditCeiling));
        }
    }

    function toDaiToken (uint amountInEther) private {
    }

    function toCredToken (uint amountInEther) private {
    }
}