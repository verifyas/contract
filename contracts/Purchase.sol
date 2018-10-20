pragma solidity ^0.4.22;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Purchase {
    address public owner;
    // This wallet receives the transaction fees:
    address public verifyWallet;
    
    // Tracks combination of (txId, amount, buyer, seller)
    uint256 public curIndex = 0;
    mapping(uint256 => uint256) public amounts;
    mapping(uint256 => address) public buyers;
    mapping(uint256 => address) public sellers;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only Verify can call this function."
        );
        _;
    }

    constructor () public payable {
        owner = msg.sender;
        verifyWallet = msg.sender;
    }

    // Sets the destination wallet for transaction fees
    function setVerifyWallet(address newWallet) public onlyOwner {
        verifyWallet = newWallet;
    }

    // Fallback function to accept ETH into contract.
    function() public payable {
    }

    function receiveFunds(address seller) public payable {
        require(msg.value > 0, "You must send some ETH to this method");
        
        // Deduct transaction fee in CRED
        uint transactionFee = SafeMath.div(msg.value, 100);
        uint payment = msg.value - transactionFee;
        transactionFee = toCredToken(transactionFee);
        verifyWallet.transfer(transactionFee);

        // Store transaction
        amounts[curIndex] = SafeMath.add(amounts[curIndex], payment);    
        buyers[curIndex] = msg.sender;
        sellers[curIndex] = seller;
        curIndex = curIndex + 1;
    }

    function completeTransaction (uint256 txIndex) public onlyOwner {
        uint256 amount = amounts[txIndex];
        amounts[txIndex] = 0;
        
        sellers[txIndex].transfer(amount);
    }

    function refundTransaction (uint256 txIndex) public onlyOwner {
        uint256 amount = amounts[txIndex];
        amounts[txIndex] = 0;
        
        buyers[txIndex].transfer(amount);
    }

    function toDaiToken (uint amountInEther) pure
        private
        returns (uint amountInDai)
    {
        /**
         * Bancor does not support conversion to DAI on Ropsten
         * See: https://goo.gl/cQkrvL 
         **/
        return amountInEther;
    }

    function toCredToken (uint amountInEther) pure
        private
        returns (uint amountInCred)
    {
        /** 
         * ETH to CRED conversion takes place external to this 
         * smart contract through a batch-conversion script
         * that runs regularly 
         **/
        return amountInEther;
    }
}