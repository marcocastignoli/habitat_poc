# Diamond Task

## Work in Progress
Everything you see is under development and it's just a prototype

## Docs
Read the docs here https://docs.0xhabitat.org/Developers/Gemcutter
(Just a part of the docs is actually implemented here)


## Development environment

In order to use gemcutter, the development environment must be up and running. You can start it with: ```yarn dev:start```

## Gemcutter

1. ```npx hardhat diamond:deploy --new --o test.diamond.json```
2. ```npx hardhat diamond:add --local --name MyToken --o test.diamond.json```
3. ```npx hardhat diamond:add --local --name VotingPowerFacet --o test.diamond.json --links LibVotingPower```
4. ```npx hardhat diamond:add --local --name TreasuryDefaultCallbackHandlerFacet --o test.diamond.json```
5. ```npx hardhat diamond:add --local --name TreasuryVotingFacet --o test.diamond.json --links LibVotingPower```
6. ```npx hardhat diamond:add --local --name TreasuryViewerFacet --o test.diamond.json```

