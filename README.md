# Diamond Task

## Work in Progress
Everything you see is under development and it's just a prototype

## Docs
Read the docs here https://docs.0xhabitat.org/Developers/Gemcutter
(Just a part of the docs is actually implemented here)

## Getting started

0. Install the dependencies
    ```bash
    yarn
    ```
1. When you work locally using gemcutter you always need to have the development environment online. You can start it using
    ```bash
    yarn dev:start
    ```
2. Then you have to initialize the .diamond.json file you can do it by running 

    ```
    yarn diamond:init
    ```
    This command will read your DIAMONDFILE and generate a diamond.json file. If you want to run the test call instead
    ```
    yarn diamond:init:test
    ```
3. Now that you have a test.diamond.json you can run the test, by launching
    ```
    yarn test
    ```


## DIAMONDFILE

When you are satisfied with the .diamond.json file you need to save your progress into the DIAMONDFILE. You can do it manually creating a file like this

```
npx hardhat diamond:deploy --new
npx hardhat diamond:add --local --name MyToken
npx hardhat diamond:add --local --name VotingPowerFacet --links LibVotingPower
npx hardhat diamond:add --local --name TreasuryDefaultCallbackHandlerFacet
npx hardhat diamond:add --local --name TreasuryVotingFacet --links LibVotingPower
npx hardhat diamond:add --local --name TreasuryViewerFacet
```