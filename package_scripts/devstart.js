const { dirname } = require('path');
const appDir = dirname(require.main.filename);

process.env.REPOSITORY_URL = 'http://127.0.0.1:5500/';
process.env.SERVER_PORT=8990
process.env.REPOSITORY_PATH=`${appDir}/../data/repository`
process.env.DATABASE_PATH=`${appDir}/../data/database`

process.chdir("node_modules/ethereum-sourcify/")

const util = require('util');
const exec = util.promisify(require('child_process').exec);

async function runSourcify() {
    exec('node ./dist/server/server.js');
    exec(`npx http-server -s -p 5500 ${process.env.REPOSITORY_PATH}`);
    console.log(`Sourcify is running!`)
}

async function runGanache() {
    exec("ganache --fork.network \"ropsten\" --miner.blockGasLimit \"999999999999999\" --miner.defaultTransactionGasLimit \"99999999999999\" --miner.callGasLimit \"999999999999999\" --chain.networkId 1337")
    console.log(`Ganache is running!`)
}

runSourcify()
runGanache()