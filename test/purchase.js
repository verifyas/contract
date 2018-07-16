var Web3Beta = require('web3')
var web3beta = new Web3Beta()

var bigInt = require('big-integer')

var Purchase = artifacts.require('Purchase')

contract('Purchase', function ([buyer, seller, verify, verifyEscrow, donor]) {

  var purchase

  beforeEach('setup contract for each test', async function () {
    purchase = await Purchase.new(seller, verify, verifyEscrow)
  })

  it('has a buyer', async () => {
    assert.equal(await purchase.buyer(), buyer)
  })

  it('is able to accept ether', async () => {
    await purchase.sendTransaction({ value: 1e+18, from: donor })

    assert.equal(web3.eth.getBalance(await purchase.address) * 1, 1e+18)
  })

  it('buyer should send funds to Verify', async () => {
    var buyerInitialBalance = web3.eth.getBalance(buyer) * 1
    var verifyInitialBalance = web3.eth.getBalance(verify) * 1

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verify) * 1, verifyInitialBalance)
    assert.isBelow(web3.eth.getBalance(buyer) * 1, buyerInitialBalance)
  })

  it('buyer should send funds to Verify escrow', async () => {
    var buyerInitialBalance = web3.eth.getBalance(buyer) * 1
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow) * 1

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verifyEscrow) * 1, verifyEscrowInitialBalance)
    assert.isBelow(web3.eth.getBalance(buyer) * 1, buyerInitialBalance)
  })

  it('Verify should send funds to seller', async () => {
    var sellerInitialBalance = web3.eth.getBalance(seller) * 1
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow) * 1

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether'), gas: "220000" })
    var result = await purchase.sendFundsToSeller({ value: await purchase.moneyInEscrow(), from: verifyEscrow, gas: "220000" })

    var transaction = await web3.eth.getTransaction(result.tx)
    var gasCost = transaction.gasPrice.mul(result.receipt.gasUsed)

    assert.ok(bigInt(web3.eth.getBalance(seller) * 1).greater(sellerInitialBalance))
    assert.ok(bigInt(web3.eth.getBalance(verifyEscrow)).add(gasCost).equals(verifyEscrowInitialBalance))
  })
  
  it('Verify escrow should refund funds to buyer', async () => {
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow) * 1
    var buyerInitialBalance = await web3.eth.getBalance(buyer) * 1
    var transactionFee = web3beta.utils.toWei('3', 'ether') / 100

    var resultBuyer = await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether'), gas: "2200000" })
    var resultVerifyEscrow = await purchase.refundFromVerify({ value: await purchase.moneyInEscrow(), from: verifyEscrow, gas: "2200000" })

    var transactionBuyer = await web3.eth.getTransaction(resultBuyer.tx)
    var gasCostBuyer = transactionBuyer.gasPrice.mul(resultBuyer.receipt.gasUsed)
    var transactionVerifyEscrow = await web3.eth.getTransaction(resultVerifyEscrow.tx)
    var gasCostVerifyEscrow = transactionVerifyEscrow.gasPrice.mul(resultVerifyEscrow.receipt.gasUsed)

    assert.ok(bigInt(web3.eth.getBalance(verifyEscrow)).add(gasCostVerifyEscrow).equals(verifyEscrowInitialBalance))
    assert.ok(bigInt(web3.eth.getBalance(buyer)).add(transactionFee).add(gasCostBuyer).equals(buyerInitialBalance))
  })
})