pragma solidity ^0.4.22;

//import 'https://github.com/verifyas/contract/contracts/CREDToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address public buyer;
    address public seller;
    address public verify; // TODO: Set to Verify Ethereum address
    address public verifyEscrow; // TODO: Set to Verify Escrow Account Ethereum Address
    uint public creditCeiling = 0;
    uint public moneyInEscrow = 0;

    modifier onlyVerifyEscrow {
        require(
            msg.sender == verifyEscrow,
            "Only the escrow account of Verify can call this function."
        );
        _;
    }

    // IMPORTANT: Remove the input of addressVerify and addressVerifyEscrow before releasing.
    // These are included for testing purposes ONLY!
    constructor (address addressSeller, address addressVerify, address addressVerifyEscrow) public payable {
        buyer = msg.sender;
        seller = addressSeller;
        verify = addressVerify; // IMPORTANT: Remove this line and the line below it before releasing - these are included for testing purposes ONLY!
        verifyEscrow = addressVerifyEscrow;
    }

    // Fallback function to accept ETH into contract.
    function() public payable {
    }

    function collect () public onlyVerifyEscrow {
        verify.transfer(address(this).balance);
    }

    function setCreditCeiling (uint ceiling) external onlyVerifyEscrow {
        creditCeiling = ceiling;
    }

    function sendFundsToVerify ()
        public
        payable
        returns (bool completed)
    {
        uint transactionFee = getTransactionFee();
        uint payment = SafeMath.sub(msg.value, transactionFee);

        transactionFee = toCredToken(transactionFee);
        verify.transfer(transactionFee);

        if (payment <= creditCeiling) {
            seller.transfer(payment);
        } else {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
            }
            moneyInEscrow = moneyInEscrow + toDaiToken(payment - creditCeiling);
            verifyEscrow.transfer(moneyInEscrow);
        }
        return true;
    }

    function sendFundsToSeller ()
        public
        payable
        onlyVerifyEscrow
        returns (bool completed)
    {
        seller.transfer(moneyInEscrow);
        moneyInEscrow = 0;
        return true;
    }

    function refundFromVerify ()
        public
        payable
        onlyVerifyEscrow
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
        return amountInEther;
    }

    function toCredToken (uint amountInEther)
        private
        returns (uint amountInCred)
    {
        return amountInEther;
    }
}