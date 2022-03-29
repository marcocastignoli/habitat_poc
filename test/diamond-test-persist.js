const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction, getSelector } = require('./libraries/diamond.js')

const SourcifyJS = require('sourcify-js');

const {
  getDiamondJson,
} = require('../tasks/lib/utils.js')

const { promises: { rm } } = require('fs');
const TEST_FILE = 'test.diamond.json'
const CHAIN_ID = 31337

async function updateDiamond() {
  const diamondJson = await getDiamondJson(TEST_FILE)
  const sourcify = new SourcifyJS.default('http://localhost:8990', 'http://localhost:5500')
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]


  let abis = []
  for (let FacetName in diamondJson.contracts) {
    const facet = diamondJson.contracts[FacetName]
    const { abi } = await sourcify.getABI(facet.address, CHAIN_ID)

    abis = abis.concat(abi.filter((abiElement, index, abi) => {
      if (abiElement.type === "constructor") {
        return false;
      }

      return true;
    }))
  }

  return new ethers.Contract(diamondJson.address, abis, contractOwner)
}

describe("Diamond test", async function () {
  
  let diamond
  let stakeContract
  it("sould deploy new diamond", async function () {
    const address = await hre.run('diamond:deploy', {
      o: TEST_FILE
    })
    diamond = await updateDiamond()
  });

  it("should deploy stake contract", async function() {
    const diamond = await updateDiamond()

    await diamond.initMyToken();
    
    const StakeContract = await ethers.getContractFactory("StakeContract");
    stakeContract = await StakeContract.deploy(diamond.address, 1000, [
      diamond.address
    ], [
      1000
    ]);

    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]
    const destination = accounts[1]

    await diamond.approve(stakeContract.address, 10)

    await diamond.initVotingPower(stakeContract.address)

    await diamond.initTreasuryVoting()

    await stakeContract.stake(diamond.address, 10)

    expect(await diamond.getVoterVotingPower(contractOwner.address)).to.be.eq(10)

    // TODO: I had to disable callData because it gives errors
    await diamond.createTreasuryProposal(
      destination.address,
      1,
      "0x",
      99999999999999
    )

    let createdProposal = await diamond.getTreasuryProposal(1)
    expect(destination.address).to.be.eq(createdProposal[1])
  })


  it("should increment facets Diamond", async function () {

    

    /* let counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(0)

    const CounterLens = await ethers.getContractFactory("CounterLens");

    const counter = await CounterLens.deploy(diamond.address, diamond.address);
    
    await counter.increment(2) 
    
    counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(2)*/

  })
});
