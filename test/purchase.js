var Web3Beta = require('web3')
var web3beta = new Web3Beta()

var Purchase = artifacts.require('Purchase')

contract('Purchase', function ([buyer, seller, verify, verifyEscrow, donor]) {

  var purchase

  beforeEach('setup contract for each test', async function () {
    purchase = await Purchase.new(seller, verify, verifyEscrow)
  })

  /*it('has a buyer', async () => {
    assert.equal(await purchase.buyer(), buyer)
  })

  it('is able to accept ether', async () => {
    await purchase.sendTransaction({ value: 1e+18, from: donor })

    assert.equal(web3.eth.getBalance(await purchase.address).toNumber(), 1e+18)
  })

  it('permit verify to receive fallback ether', async () => {
    var verifyInitialBalance = web3.eth.getBalance(verify).toNumber()

    await purchase.sendTransaction({ value: 1e+18, from: donor })
    await purchase.collect({ from: verify })

    assert.equal(web3.eth.getBalance(await purchase.address).toNumber(), 0)
    assert.isAbove(web3.eth.getBalance(verify).toNumber(), verifyInitialBalance)
  })

  it('buyer should send funds to Verify', async () => {
    var buyerInitialBalance = web3.eth.getBalance(buyer).toNumber()
    var verifyInitialBalance = web3.eth.getBalance(verify).toNumber()

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verify).toNumber(), verifyInitialBalance)
    assert.isBelow(web3.eth.getBalance(buyer).toNumber(), buyerInitialBalance)
  })

  it('buyer should send funds to Verify escrow', async () => {
    var buyerInitialBalance = web3.eth.getBalance(buyer).toNumber()
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow).toNumber()

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether') })

    assert.isAbove(web3.eth.getBalance(verifyEscrow).toNumber(), verifyEscrowInitialBalance)
    assert.isBelow(web3.eth.getBalance(buyer).toNumber(), buyerInitialBalance)
  })

  it('Verify should send funds to seller', async () => {
    var sellerInitialBalance = web3.eth.getBalance(seller).toNumber()
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow).toNumber()

    await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether'), gas: "220000" })
    var result = await purchase.sendFundsToSeller({ value: await purchase.moneyInEscrow(), from: verifyEscrow, gas: "220000" })

    var transaction = await web3.eth.getTransaction(result.tx)
    var gasCost = transaction.gasPrice.mul(result.receipt.gasUsed)

    assert.isAbove(web3.eth.getBalance(seller).toNumber(), sellerInitialBalance)
    assert.equal(web3.eth.getBalance(verifyEscrow).toNumber() + gasCost.toNumber(), verifyEscrowInitialBalance)
  })*/

  it('seller should refund funds to buyer', async () => {
    var sellerInitialBalance = await web3.eth.getBalance(seller).toNumber()
    var buyerInitialBalance = await web3.eth.getBalance(buyer).toNumber()
    var transactionFee = web3beta.utils.toWei('3', 'ether') / 100

    var resultBuyer = await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether'), gas: "2200000" })
    await purchase.sendFundsToSeller({ value: await purchase.moneyInEscrow(), from: verifyEscrow, gas: "2200000" })
    var resultSeller = await purchase.refundFromSeller({ value: await purchase.paid(), from: seller, gas: "2200000" })

    var transactionBuyer = await web3.eth.getTransaction(resultBuyer.tx)
    var gasCostBuyer = transactionBuyer.gasPrice.mul(resultBuyer.receipt.gasUsed)
    var transactionSeller = await web3.eth.getTransaction(resultSeller.tx)
    var gasCostSeller = transactionSeller.gasPrice.mul(resultSeller.receipt.gasUsed)

    assert.equal(web3.eth.getBalance(seller).toNumber() + gasCostSeller.toNumber(), sellerInitialBalance)
    assert.equal(web3.eth.getBalance(buyer).toNumber() + transactionFee + gasCostBuyer.toNumber(), buyerInitialBalance)
  })
  
  it('Verify escrow should refund funds to buyer', async () => {
    var verifyEscrowInitialBalance = web3.eth.getBalance(verifyEscrow).toNumber()
    var buyerInitialBalance = await web3.eth.getBalance(buyer).toNumber()
    var transactionFee = web3beta.utils.toWei('3', 'ether') / 100

    var resultBuyer = await purchase.sendFundsToVerify({ value: web3beta.utils.toWei('3', 'ether'), gas: "2200000" })
    var resultVerifyEscrow = await purchase.refundFromVerify({ value: await purchase.moneyInEscrow(), from: verifyEscrow, gas: "2200000" })

    var transactionBuyer = await web3.eth.getTransaction(resultBuyer.tx)
    var gasCostBuyer = transactionBuyer.gasPrice.mul(resultBuyer.receipt.gasUsed)
    var transactionVerifyEscrow = await web3.eth.getTransaction(resultVerifyEscrow.tx)
    var gasCostVerifyEscrow = transactionVerifyEscrow.gasPrice.mul(resultVerifyEscrow.receipt.gasUsed)

    assert.equal(web3.eth.getBalance(verifyEscrow).toNumber() + gasCostVerifyEscrow.toNumber(), verifyEscrowInitialBalance)
    assert.equal(web3.eth.getBalance(buyer).toNumber() + transactionFee + gasCostBuyer.toNumber(), buyerInitialBalance)
  })
})