pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address addressVerify; // TODO: Set to Verify Ethereum address
    uint collectedEther = 0;

    modifier onlyVerify {
        require(
            msg.sender == addressVerify,
            "Only Verify can call this function."
        );
        _;
    }

    constructor () public payable {
    }

    function() external payable {
        collectedEther = SafeMath.add(collectedEther, msg.value); 
    }

    function collect () external onlyVerify {
        if (collectedEther > 0) {
            uint amount = collectedEther;
            collectedEther = 0;
            addressVerify.transfer(amount);
        }
    }

    function sendFundsToVerify (address addressSeller, uint creditCeiling) public payable {
        uint transactionFee = SafeMath.div(msg.value, 100);
        uint payment = SafeMath.sub(msg.value, transactionFee);

        transactionFee = toCredToken(transactionFee);
        // TODO: Transfer transaction fee to Verify

        if (payment <= creditCeiling) {
            addressSeller.transfer(payment);
        } else if (creditCeiling < payment) {
            if (creditCeiling > 0) {
                addressSeller.transfer(creditCeiling);
            }
            uint moneyInEscrow = toDaiToken(SafeMath.sub(payment, creditCeiling));
        }
    }

    function toDaiToken (uint amountInEther)
        private
        returns (uint amountInDai)
    {
    }

    function toCredToken (uint amountInEther)
        private
        returns (uint amountInCred)
    {
    }
}