const util = require('util');
const fs = require('fs');
const exec = util.promisify(require('child_process').exec);

async function runCommands(commands, file) {
    for (let i = 0; i<commands.length; i++) {
        let command = `${commands[i]} --o ${file}`
        try {
            console.log(command)
            const {stdout} = await exec(command)
            console.log(stdout)
        } catch(e) {
            if (e.toString().includes('HH108')) {
                console.error('You need to run the development environment first, try running: yarn dev:start in another terminal before running this command.')
                process.exit(1)
            } else {
                console.log(e.toString())
            }
        }
    }
}

const diamondFile = fs.readFileSync('DIAMONDFILE')
const commands = diamondFile.toString().split('\n')
const args = process.argv.slice(2);
const file = args[0] || 'diamond.json'

runCommands(commands, file)