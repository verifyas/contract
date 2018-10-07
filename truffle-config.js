// Allows us to use ES6 in our migrations and tests.
require('babel-register')
require('babel-polyfill')

// Allows us to use latest version of web3.
require('web3')

// Allows us to use BigInteger
require('big-integer')

// For Metamask support
const HDWalletProvider = require("truffle-hdwallet-provider");

// Read .env file
require('dotenv').config()  // Store environment-specific variable from '.env' to process.env

module.exports = {
  networks: {
    "development": {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" //Match any network id
    },
    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNENOMIC, "https://ropsten.infura.io/v3/" + process.env.INFURA_API_KEY),
      network_id: 3,
      gas: 3000000,
      gasPrice: 21
    },
  }
}