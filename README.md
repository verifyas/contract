# About this project

The goal of this project is to provide the smart contract(s) that will be used by the buyer, the seller, and Verify in order to conduct the transactions for the Ethereum whitepaper project. This includes sending the funds to Verify, converting 1% of the funds to the Verify CRED token and storing it in the Verify account, converting 99% of the funds to the Dai stablecoin and storing it in the Verify escrow account, sending the funds stored in escrow to the seller, and allowing for refunds, in which case the seller refunds any money they were paid so far and Verify refunds any money in the escrow account that hasn't been given to the seller yet.

# Code Structure

The contracts are stored in the folder marked 'contracts'. In the folder, there are currently two files - one named Migration.sol and one named Purchase.sol. Migration.sol is generated and used by Truffle. Purchase.sol is the smart contract currently under development.

Unit tests are stored in the folder marked 'tests'. They follow the Truffle testing specification and are run by Truffle.

# Style Guidelines

This project uses the official Solidity style guidelines, which can be found here: http://solidity.readthedocs.io/en/v0.4.24/style-guide.html

A couple important things to note from the guidelines:

 * We use four spaces per indentation level - use spaces, mixing tabs and spaces should be avoided.
 
 * Strings are double-quoted instead of single-quoted.
 
 * Functions should be grouped according to their visibility and ordered in the following way:
   * constructor
   * fallback function (if exists)
   * external
   * public
   * internal
   * private
