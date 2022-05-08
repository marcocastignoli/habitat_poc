const { dirname } = require('path');

const util = require('util');
const exec = util.promisify(require('child_process').exec);

async function runGanache() {
    exec("ganache --miner.blockGasLimit \"999999999999999\" --miner.defaultTransactionGasLimit \"999999999999999\" --miner.callGasLimit \"999999999999999\" --chain.networkId 1337")
    console.log(`Ganache is running!`)
}

runGanache()