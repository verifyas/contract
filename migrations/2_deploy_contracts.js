var Purchase = artifacts.require("./Purchase.sol");

module.exports = function(deployer) {
  var addressSeller = "0xf17f52151ebef6c7334fad080c5704d77216b732"
  var addressVerify = "0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef"
  var addressVerifyEscrow = "0x821aea9a577a9b44299b9c15c88cf3087f3b5544"

  deployer.deploy(Purchase, addressSeller, addressVerify, addressVerifyEscrow);
};