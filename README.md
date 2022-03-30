# Habitat Proof of Concept

## Work in Progress
Everything you see is under development and it's just a prototype

## Docs
Read the docs here https://docs.0xhabitat.org/Developers/Gemcutter
(Just a part of the docs is actually implemented here)

## Sourcify
In order to work on this, we suggest you to read how Sourcify works, more info will be added here.

---
# Gemcutter: Quick Setup

## Install via terminal:

### Install global dependencies
```npm i -g ganache && npm i -g http-server && npm i -g hardhat-shorthand```

### Setup gemcutter directory
```mkdir -p gemcutter && cd gemcutter```

### Setup sourcify
```git clone https://github.com/0xHabitat/sourcify.git && cd sourcify && npx lerna bootstrap && npx lerna run build && mkdir -p data/{repository,database} && cd environments && envsubst < .env.gemcutter > .env && cd .. && npx lerna run build && cd ..```

## Start gemcutter:

*Run these processes in 3 different terminal tabs (at base directory `gemcutter`):*

### Run sourcify
```cd sourcify && npm run server:start```

### Run HTTP server
```cd sourcify/data/repository && http-server -p 5500```

### Run ganache with params:
```ganache --miner.blockGasLimit "999999999999999" --miner.defaultTransactionGasLimit "99999999999999" --miner.callGasLimit "999999999999999" --chain.networkId 1337```

*Now you are ready to execute the tasks*

---
# Diamond Tasks

## Gemcutter

1. ```npx hardhat diamond:deploy --new --o test.diamond.json```
2. ```npx hardhat diamond:add --local --name MyToken --o test.diamond.json```
3. ```npx hardhat diamond:add --local --name LocalFacetTest --o test.diamond.json --links LibVotingPower```
4. ```npx hardhat diamond:add --local --name Treasury --o test.diamond.json```
5. ```hh test```
