var Purchase = artifacts.require('Purchase')

contract('Purchase', function ([buyer, seller, verify, verifyEscrow, donor]) {

  var purchase

  beforeEach('setup contract for each test', async function () {
    var price = 2

    purchase = await Purchase.new(seller, price, verify, verifyEscrow)
  })

  it('has a buyer', async function () {
    assert.equal(await purchase.buyer(), buyer)
  })

  it('is able to accept ether', async function () {
    await purchase.sendTransaction({ value: 1e+18, from: donor })
    
    var purchaseAddress = await purchase.address
    assert.equal(web3.eth.getBalance(purchaseAddress).toNumber(), 1e+18)
  })

  /*it("should send funds to Verify and Verify escrow", function () {
    /*return Purchase.deployed().then(function (instance) {
      return instance.sendFundsToVerify()
    }).then(function (success) {
      assert.equal(success, true, "Call to sendFundsToVerify() failed with response: " + success)
    })
  })*/
})