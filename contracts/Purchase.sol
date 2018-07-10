pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address public buyer;
    address public seller;
    address public verify; // TODO: Set to Verify Ethereum address
    address public verifyEscrow; // TODO: Set to Verify Escrow Account Ethereum Address
    uint private creditCeiling = 0;
    uint private price = 0;
    uint private paid = 0;
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

    // IMPORTANT: Remove the input of addressVerify and addressVerifyEscrow before releasing.
    // These are included for testing purposes ONLY!
    constructor (address addressSeller, uint p, address addressVerify, address addressVerifyEscrow) public payable {
        buyer = msg.sender;
        seller = addressSeller;
        price = p;
        verify = addressVerify; // IMPORTANT: Remove this line and the line below it before releasing - these are included for testing purposes ONLY!
        verifyEscrow = addressVerifyEscrow;
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

    function setCreditCeiling (uint ceiling) external onlyVerify {
        creditCeiling = ceiling;
    }

    function sendFundsToVerify ()
        public
        payable
        returns (bool completed)
    {
        uint transactionFee = getTransactionFee();
        uint payment = SafeMath.sub(msg.value, transactionFee);

        if (payment < price) {
            return false;
        }

        transactionFee = toCredToken(transactionFee);
        verify.transfer(transactionFee);

        if (payment <= creditCeiling) {
            seller.transfer(payment);
            paid = paid + payment;
        } else if (creditCeiling < payment) {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
                paid = paid + creditCeiling;
            }
            moneyInEscrow = moneyInEscrow + toDaiToken(SafeMath.sub(payment, creditCeiling));
            verifyEscrow.transfer(moneyInEscrow);
        }
        return true;
    }

    function sendFundsToSeller ()
        public
        payable
        onlyVerify
        returns (bool completed)
    {
        seller.transfer(moneyInEscrow);
        paid = paid + moneyInEscrow;
        moneyInEscrow = 0;
        return true;
    }

    // Note: Transaction fee is non-refundable.
    function refundFromSeller ()
        public
        payable
        onlySeller
        returns (bool completed)
    {
        buyer.transfer(paid);
        paid = 0;
        return true;
    }

    function refundFromVerify ()
        public
        payable
        onlyVerify
        returns (bool completed)
    {
        buyer.transfer(moneyInEscrow);
        moneyInEscrow = 0;
        return true;
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