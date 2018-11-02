var Web3 = require('web3');
if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
} else {
    // set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
}
web3.eth.defaultAccount = web3.eth.accounts[0];
var Contract = web3.eth.contract(
	[{"constant": false,"inputs": [{"name": "_spender","type": "address"},{"name": "_value","type": "uint256"}],"name": "approve","outputs": [{"name": "success","type": "bool"}],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_clientWallet","type": "address"},{"name": "_sum","type": "uint256"},{"name": "_idCredit","type": "uint256"}],"name": "CreditPay","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_clientWallet","type": "address"},{"name": "_sum","type": "uint256"},{"name": "_duration","type": "uint256"}],"name": "GetCredit","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_clientWallet","type": "address"},{"name": "_sum","type": "uint256"},{"name": "_duration","type": "uint256"}],"name": "GetDeposit","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_to","type": "address"},{"name": "_value","type": "uint256"}],"name": "mint","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_clientWallet","type": "address"}],"name": "Refund","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_to","type": "address"},{"name": "_value","type": "uint256"}],"name": "transfer","outputs": [{"name": "success","type": "bool"}],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_from","type": "address"},{"name": "_to","type": "address"},{"name": "_value","type": "uint256"}],"name": "transferFrom","outputs": [{"name": "success","type": "bool"}],"payable": false,"stateMutability": "nonpayable","type": "function"},{"anonymous": false,"inputs": [{"indexed": true,"name": "_from","type": "address"},{"indexed": true,"name": "_to","type": "address"},{"indexed": false,"name": "_value","type": "uint256"}],"name": "Transfer","type": "event"},{"anonymous": false,"inputs": [{"indexed": true,"name": "_ownerm","type": "address"},{"indexed": true,"name": "_spender","type": "address"},{"indexed": false,"name": "_value","type": "uint256"}],"name": "Approval","type": "event"},{"constant": true,"inputs": [{"name": "_owner","type": "address"},{"name": "_spender","type": "address"}],"name": "allowance","outputs": [{"name": "remainig","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_owner","type": "address"}],"name": "balanceOf","outputs": [{"name": "balance","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "bankAcc","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "decimals","outputs": [{"name": "","type": "uint32"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_clientWallet","type": "address"}],"name": "GetClientCredits","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "name","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "symbol","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"}],
	{
		from: '0x583031d1113ad414f02576bd6afabfb302140225',
		gasPrice: '10000000000000',
    	gas: 1000000
	}
);
var mainContract = Contract.at('0xffa7496eb361fe35f4dbd1ec57dadc06d3bd8d02');
var version = web3.version.api;
console.log(version);
console.log(mainContract);

$("#setDeposit .btn-block").click(function() {
	var ID = $("#setDeposit .depositID").val();
	var amount = $("#doDeposit-amount").val();
	var duration = $("#doDeposit-duration").val();
	console.log("GetDeposit "+ID+","+amount+","+duration)
	mainContract.GetDeposit(ID,amount,duration);
});

$("#getCredit .btn-block").click(function() {
	var ID = $("#getCredit .depositID").val();
	var amount = $("#doCredit-amount").val();
	var duration = $("#doCredit-duration").val();
	console.log("GetCredit "+ID+","+amount+","+duration)
	mainContract.GetCredit(ID,amount,duration);
});