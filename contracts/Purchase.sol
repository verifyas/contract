pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address public buyer;
    address public seller;
    address public verify; // TODO: Set to Verify Ethereum address
    address public verifyEscrow; // TODO: Set to Verify Escrow Account Ethereum Address
    uint private payment = 0;
    uint private moneyInEscrow = 0;
    uint private collectedEther = 0;

    modifier onlyVerify {
        require(
            msg.sender == verify,
            "Only Verify can call this function."
        );
        _;
    }

    modifier onlyBuyer {
        require(
            msg.sender == buyer,
            "Only the buyer can call this function."
        );
        _;
    }

    modifier onlySeller {
        require(
            msg.sender == seller,
            "Only the seller can call this function."
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
            verify.transfer(collectedEther);
            collectedEther = 0;
        }
    }

    // TODO: Get creditCeiling from Verify server instead of from buyer
    function sendFundsToVerify (uint creditCeiling) public payable onlyBuyer {
        uint transactionFee = getTransactionFee();
        payment = SafeMath.sub(msg.value, transactionFee);

        transactionFee = toCredToken(transactionFee);
        verify.transfer(transactionFee);

        if (payment <= creditCeiling) {
            seller.transfer(payment);
        } else if (creditCeiling < payment) {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
            }
            moneyInEscrow = moneyInEscrow + toDaiToken(SafeMath.sub(payment, creditCeiling));
            verifyEscrow.transfer(moneyInEscrow);
        }
    }

    function sendFundsToSeller () public payable onlyVerify {
        seller.transfer(moneyInEscrow);
        moneyInEscrow = 0;
    }

    // Note: Transaction fee is non-refundable.
    function refund () public payable onlySeller {
        buyer.transfer(payment);
    }

    // Note: For v1, we will only take 1% of the transaction as 'insurance' fee.
    // In the future, we will use an algorithm to calculate the 'insurance' fee,
    // taking into account the reputation of both parties involved.
    function getTransactionFee ()
        private
        returns (uint transactionFee)
    {
        return SafeMath.div(msg.value, 100);
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