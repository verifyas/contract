# About this project

The goal of this project is to provide the smart contract(s) that will be used by the buyer, the seller, and Verify in order to conduct the transactions for the Ethereum whitepaper project. This includes sending the funds to Verify, converting 1% of the funds to the Verify CRED token and storing it in the Verify account, converting 99% of the funds to the Dai stablecoin and storing it in the Verify escrow account, sending the funds stored in escrow to the seller, and allowing for refunds (in some fashion), in which case Verify refunds any money in the escrow account that hasn't been given to the seller yet.

# Code Structure

The contracts are stored in the folder marked 'contracts'. In the folder, there are currently two files - one named Migration.sol and one named Purchase.sol. Migration.sol is generated and internally used by Truffle. Purchase.sol is the smart contract currently under development.

The migrations are stored in the folder marked 'migrations'. In the folder, there are currently two files, both of which are numbered. The one marked with the number one is generated and internally used by Truffle. The one marked with the number two is used to deploy the smart contract to the ganache-cli test server.

The unit tests are stored in the folder marked 'test'. In the folder, there is currently one file - purchase.js. It contains several unit tests to run against the smart contract. The unit tests follow the Truffle testing specification (which is based off of the Mocha testing specification).

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

# Getting Started

To get started with the project, follow the below instructions:
 1. Download or clone the repository.
 2. Navigate into the root directory of the project.
 3. Run the command 'npm install'
 
## Testing

To test the smart contracts, follow the below instructions:
 1. Open a command prompt/terminal and navigate into the root directory of the project.
 2. Run the command 'truffle develop'. This sets up a local ganache-cli test server equipped with a copy of the Ethereum blockchain for you to run on. It also creates ten test Ethereum accounts, each with 100 test Ether. Their addresses and private keys will be listed after you run the command. You can plug those into the 'deploy_contract' migration file in the 'migrations' folder. Do not end the test server - keep it running.
 3. Open a DIFFERENT command prompt/terminal and navigate into the root directory of the project. It is important that you keep the other command prompt/terminal running.
 4. Run the command 'truffle test'. This does three things:
   * Compiles the smart contracts.
   * Runs the migrations to deploy the contracts to the network. For testing purposes, we'll use a test network, in this case testrpc. Running on the main Ethereum network would be very slow and expensive.
   * Runs the tests against the smart contracts deployed on the network.

## Contact

If you need any help getting the smart contracts running on your computer, feel free to send a message to Richard Grannis-Vu on Basecamp or an email to rickygv@stanford.edu.
