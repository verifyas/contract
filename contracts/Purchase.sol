pragma solidity ^0.4.22;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {

    address public buyer;
    address public seller;
    address public verify = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
    address public verifyEscrow = 0x821aea9a577a9b44299b9c15c88cf3087f3b5544;
    uint public creditCeiling = 0;
    uint public moneyInEscrow = 0;

    modifier onlyVerifyEscrow {
        require(
            msg.sender == verifyEscrow,
            "Only the Verify escrow account can call this function."
        );
        _;
    }

    constructor (address addressSeller) public payable {
        buyer = msg.sender;
        seller = addressSeller;
    }

    // Fallback function to accept ETH into contract.
    function() public payable {
    }

    function setCreditCeiling (uint ceiling) external onlyVerifyEscrow {
        creditCeiling = ceiling;
    }

    function sendFundsToVerify () public payable {
        uint transactionFee = SafeMath.div(msg.value, 100);
        uint payment = msg.value - transactionFee;

        transactionFee = toCredToken(transactionFee);
        verify.transfer(transactionFee);

        if (payment <= creditCeiling) {
            seller.transfer(payment);
        } else {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
            }
            moneyInEscrow = SafeMath.add(moneyInEscrow, toDaiToken(payment - creditCeiling));

            verifyEscrow.transfer(moneyInEscrow);
        }
    }

    function sendFundsToSeller () public payable onlyVerifyEscrow {
        uint moneyTransfer = moneyInEscrow;
        moneyInEscrow = 0;

        seller.transfer(moneyTransfer);
    }

    function refundFromVerify () public payable onlyVerifyEscrow {
        uint moneyTransfer = moneyInEscrow;
        moneyInEscrow = 0;

        buyer.transfer(moneyTransfer);
    }

    function toDaiToken (uint amountInEther)
        private
        returns (uint amountInDai)
    {
        /* Bancor doesn't support conversion to DAI on Ropsten 
           See: https://goo.gl/cQkrvL */
        return amountInEther;
    }

    function toCredToken (uint amountInEther)
        private
        returns (uint amountInCred)
    {
        /* ETH to CRED conversion takes place external to this 
           smart contract through a batch-conversion script
           that runs regularly */
        return amountInEther;
    }
}