var Web3 = require('web3');
var web3 = new Web3()

// Replace localhost with remote IP
web3.setProvider(new Web3.providers.HttpProvider('http://localhost/rpc'));
web3.setProvider(new Web3.providers.WebsocketProvider('http://localhost/ws'));
