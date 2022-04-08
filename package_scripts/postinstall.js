process.chdir("node_modules/ethereum-sourcify/")

const util = require('util');
const fs = require('fs');
const exec = util.promisify(require('child_process').exec);

async function installSourcify() {
    console.log(`Installing Sourcify's dependencies... It can take some time...`)
    await exec('npx lerna bootstrap');
    console.log(`Compiling sourcify... It can take some time...`)
    await exec('npx lerna run build');
}

if (!fs.existsSync('./dist')) {
    installSourcify()
}