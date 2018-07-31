pragma solidity ^0.4.22;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';
//import 'https://github.com/bancorprotocol/contracts/blob/master/solidity/contracts/converter/BancorConverter.sol';

contract Purchase {

    address public buyer;
    address public seller;
    address public verify = 0x848a4a97B22CD1c447C322Bfc94d2910677367ec;
    address public verifyEscrow = 0xE41F2AF5603b376E9dF9f3e0763A0E568530Ee7b;
    uint public creditCeiling = 0;
    uint public moneyInEscrow = 0;
    ERC20Token public dai;

    modifier onlyVerifyEscrow {
        require(
            msg.sender == verifyEscrow,
            "Only the escrow account of Verify can call this function."
        );
        _;
    }

    constructor (address addressSeller) public payable {
        buyer = msg.sender;
        seller = addressSeller;
        dai = ERC20Token(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
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

        verify.transfer(transactionFee);

        if (payment <= creditCeiling) {
            seller.transfer(payment);
        } else {
            if (creditCeiling > 0) {
                seller.transfer(creditCeiling);
            }
            moneyInEscrow = SafeMath.add(moneyInEscrow, payment - creditCeiling);

            //moneyInEscrow = toDaiStablecoin(moneyInEscrow);

            dai.transfer(verifyEscrow, moneyInEscrow);
        }
    }

    function sendFundsToSeller () public payable onlyVerifyEscrow {
        uint moneyTransfer = moneyInEscrow;
        moneyInEscrow = 0;

        dai.transfer(seller, moneyTransfer);
    }

    function refundFromVerify () public payable onlyVerifyEscrow {
        uint moneyTransfer = moneyInEscrow;
        moneyInEscrow = 0;

        dai.transfer(buyer, moneyTransfer);
    }

    /*function toDaiStablecoin (uint amountInEth)
      private
      returns (uint amountInDai)
    {
        return convert(0xc0829421c1d260bd3cb3e0f06cfe2d52db2ce315, 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359, amountInEth, 0);
    }*/
}