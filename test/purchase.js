var Web3Beta = require('web3')
var web3beta = new Web3Beta()

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

  it('permit verify to receive fallback ether', async function () {
    await purchase.sendTransaction({ value: 1e+18, from: donor, gas: "220000" })
    var verifyInitialBalance = web3.eth.getBalance(verify).toNumber()

    var purchaseAddress = await purchase.address
    assert.equal(web3.eth.getBalance(purchaseAddress).toNumber(), 1e+18)
    
    await purchase.collect()
    
    assert.equal(web3.eth.getBalance(purchaseAddress).toNumber(), 0)
    assert.isAbove(web3.eth.getBalance(verify).toNumber(), verifyInitialBalance)
  })
  
  it('buyer should send funds to Verify', async function () {
    var verifyInitialBalance = web3.eth.getBalance(verify).toNumber()

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verify).toNumber(), verifyInitialBalance)
  })

  it('buyer should send funds to Verify escrow', async function () {
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow).toNumber()

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verifyEscrow).toNumber(), verifyEscrowInitialBalance)
  })
})