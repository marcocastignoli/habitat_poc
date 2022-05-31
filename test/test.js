const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { updateDiamond, testEnvironmentIsReady } = require('./libraries/diamond.js')

const TEST_FILE = 'test.diamond.json'
const CHAIN_ID = 1337

describe("Diamond test", async function () {

  before(async () => {
    await testEnvironmentIsReady()
  });

  
  let diamond
  let stakeContract
  it("sould deploy new diamond", async function () {
    await hre.run('diamond:init', {
      o: TEST_FILE,
    })
    diamond = await updateDiamond(TEST_FILE, CHAIN_ID)
  });

  it("should deploy stake contract", async function() {
    /* const diamond = await updateDiamond() */

    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]
    const destination = accounts[1]

    const StakeContract = await ethers.getContractFactory("StakeContract");
    stakeContract = await StakeContract.deploy(diamond.address, 1000, [
      diamond.address
    ], [
      1000
    ]);

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


  /* it("should increment facets Diamond", async function () {

    

    let counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(0)

    const CounterLens = await ethers.getContractFactory("CounterLens");

    const counter = await CounterLens.deploy(diamond.address, diamond.address);
    
    await counter.increment(2) 
    
    counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(2)

  })*/
});
