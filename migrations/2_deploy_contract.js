var W12TokenSender = artifacts.require("W12TokenSender");

var keys = require('../keys');

module.exports = function(deployer)
{
	deployer.deploy(W12TokenSender, {gas: 5200000, from: keys.owner});
}


