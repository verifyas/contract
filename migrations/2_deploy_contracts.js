var Purchase = artifacts.require("./Purchase.sol");

module.exports = function(deployer) {
  var addressSeller = "0x627306090abab3a6e1400e9345bc60c78a8bef57"

  deployer.deploy(Purchase, addressSeller);
};