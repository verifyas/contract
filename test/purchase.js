var Purchase = artifacts.require('Purchase')

contract('Purchase', function ([buyer]) {
  
  var purchase

  beforeEach('setup contract for each test', async function () {
    var addressSeller = '0xf17f52151ebef6c7334fad080c5704d77216b732'
    var price = 2;
    var addressVerify = '0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef'
    var addressVerifyEscrow = '0x821aea9a577a9b44299b9c15c88cf3087f3b5544'
  
    purchase = await Purchase.new(addressSeller, price, addressVerify, addressVerifyEscrow)
  })

  it('has a buyer', async function () {
    assert.equal(await purchase.buyer(), buyer)
  })

  /*it("should send funds to Verify and Verify escrow", function () {
    /*return Purchase.deployed().then(function (instance) {
      return instance.sendFundsToVerify()
    }).then(function (success) {
      assert.equal(success, true, "Call to sendFundsToVerify() failed with response: " + success)
    })
  })*/
})