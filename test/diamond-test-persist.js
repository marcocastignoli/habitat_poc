const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction, getSelector } = require('./libraries/diamond.js')

const SourcifyJS = require('sourcify-js');

const {
  getDiamondJson,
} = require('../tasks/lib/utils.js')

const { promises: { rm } } = require('fs');
const TEST_FILE = 'test.diamond.json'
const CHAIN_ID = 1337

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
  let liquidityProvider
  it("sould deploy new diamond", async function () {
    const address = await hre.run('diamond:deploy', {
      o: TEST_FILE
    })
    diamond = await updateDiamond()
  });

  it("should deploy stake contract", async function() {
    const diamond = await updateDiamond()

    await diamond.initMyToken();

    console.log(await diamond.totalSupply())
    
    const StakeContract = await ethers.getContractFactory("StakeContract");
    stakeContract = await StakeContract.deploy(diamond.address, 1000, [
      diamond.address
    ], [
      1000
    ]);

    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]

    await diamond.approve(stakeContract.address, 10)

    console.log(await diamond.balanceOf(contractOwner.address))

    await stakeContract.stake(diamond.address, 10)

    console.log(await diamond.balanceOf(contractOwner.address))
  })


  it("should deploy Liquidity Provider", async function () {

    // const LiquidityProvider = await ethers.getContractFactory("LiquidityProvider");
    // liquidityProvider = await LiquidityProvider.deploy('0xBA12222222228d8Ba445958a75a0704d566BF2C8'); //ropsten
    
    // await liquidityProvider.initializePool(/* bytes32 poolId */)
    /* let counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(0)

    const CounterLens = await ethers.getContractFactory("CounterLens");

    const counter = await CounterLens.deploy(diamond.address, diamond.address);
    
    await counter.increment(2) 
    
    counterValue = await diamond.getCounter()
    expect(counterValue).to.be.eq(2)*/

  })
});
