pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address public seller;
    address public buyer;
    address public verify; // TODO: Set to Verify Ethereum address
    address public verifyEscrow; // TODO: Set to Verify Escrow Account Ethereum Address
    uint collectedEther = 0;

    modifier onlyVerify {
        require(
            msg.sender == verify,
            "Only Verify can call this function."
        );
        _;
    }

    constructor (address addressSeller) public payable {
        buyer = msg.sender;
        seller = addressSeller;
    }

    function() external payable {
        collectedEther = SafeMath.add(collectedEther, msg.value); 
    }

    function collect () external onlyVerify {
        if (collectedEther > 0) {
            uint amount = collectedEther;
            collectedEther = 0;
            verify.transfer(amount);
        }
    }

    // TODO: Get creditCeiling from Verify server instead of from buyer
    function sendFundsToVerify (uint creditCeiling) public payable {
        uint transactionFee = SafeMath.div(msg.value, 100);
        uint payment = SafeMath.sub(msg.value, transactionFee);

        transactionFee = toCredToken(transactionFee);
        // TODO: Transfer transaction fee to Verify account

        if (payment <= creditCeiling) {
            seller.transfer(payment);
        } else if (creditCeiling < payment) {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
            }
            uint moneyInEscrow = toDaiToken(SafeMath.sub(payment, creditCeiling));
            // TODO: Transfer escrow money to Verify escrow account
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