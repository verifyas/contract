var Web3Beta = require('web3')
var web3beta = new Web3Beta()

var bigInt = require('big-integer')

var Purchase = artifacts.require('Purchase')

contract('Purchase', function ([owner, buyer, seller, donor]) {

  var purchase

  beforeEach('setup contract for each test', async function () {
    purchase = await Purchase.new()
  })

  it('has an owner', async () => {
    assert.equal(await purchase.owner(), owner)
  })

  it('is able to accept ether', async () => {
    await purchase.sendTransaction({ value: 1e+18, from: donor })

    assert.equal(web3.eth.getBalance(await purchase.address) * 1, 1e+18)
  })

  it('buyer should send funds to Verify', async () => {
    var buyerInitialBalance = web3.eth.getBalance(buyer) * 1
    var contractInitialBalance = web3.eth.getBalance(await purchase.address) * 1

    await purchase.receiveFunds(seller, { value: web3beta.utils.toWei('3', 'ether'), from: buyer })

    assert.isAbove(web3.eth.getBalance(await purchase.address) * 1, contractInitialBalance)
    assert.isBelow(web3.eth.getBalance(buyer) * 1, buyerInitialBalance)
  })

  it('Verify can release funds to seller', async () => {
    var sellerInitialBalance = web3.eth.getBalance(seller) * 1
    var contractInitialBalance = web3.eth.getBalance(await purchase.address) * 1

    await purchase.receiveFunds(seller, { value: web3beta.utils.toWei('3', 'ether'), gas: "220000", from: buyer })
    var result = await purchase.completeTransaction(0, { from: owner, gas: "220000" }) // index = 0

    var transaction = await web3.eth.getTransaction(result.tx)
    var gasCost = transaction.gasPrice.mul(result.receipt.gasUsed)

    assert.ok(bigInt(web3.eth.getBalance(seller) * 1).greater(sellerInitialBalance))
  })
  
  it('Verify can refund funds to buyer', async () => {
    var contractInitialBalance = web3.eth.getBalance(await purchase.address) * 1
    var buyerInitialBalance = await web3.eth.getBalance(buyer) * 1
    var transactionFee = web3beta.utils.toWei('3', 'ether') / 100

    var resultPurchase = await purchase.receiveFunds(seller, { from: buyer, value: web3beta.utils.toWei('3', 'ether'), gas: "2200000" })
    var resultRefund = await purchase.refundTransaction(0, { from: owner, gas: "2200000" })

    var txPurchase = await web3.eth.getTransaction(resultPurchase.tx)
    var gasCostBuyer = txPurchase.gasPrice.mul(resultPurchase.receipt.gasUsed)
    var txRefund = await web3.eth.getTransaction(resultRefund.tx)
    var gasCostRefundTx = txRefund.gasPrice.mul(resultRefund.receipt.gasUsed)

    assert.ok(bigInt(web3.eth.getBalance(buyer)).add(transactionFee).add(gasCostBuyer).equals(buyerInitialBalance))
  })
})