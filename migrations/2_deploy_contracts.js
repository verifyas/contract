var Purchase = artifacts.require("./Purchase.sol");

module.exports = function(deployer) {
  var addressSeller = '0xf17f52151ebef6c7334fad080c5704d77216b732'
  var price = 2;
  deployer.deploy(Purchase, addressSeller, price);
};
