// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { IVotingPower } from "../interfaces/IVotingPower.sol";
import { LibVotingPower } from "../libraries/LibVotingPower.sol";

contract VotingPowerFacet is IVotingPower {

  function initVotingPower(address _votingPowerManager) external {
    IVotingPower.VotingPower storage vp = LibVotingPower.votingPowerStorage();
    vp.votingPowerManager = _votingPowerManager;
    vp.maxAmountOfVotingPower = 15;
  }
  
  function increaseVotingPower(address voter, uint amount) external override {
    LibVotingPower._increaseVotingPower(voter, amount);
  }

  function decreaseVotingPower(address voter, uint amount) external override {
    LibVotingPower._decreaseVotingPower(voter, amount);
  }

  // View functions
  function getVotingPowerManager() external view override returns(address) {
    return LibVotingPower._getVotingPowerManager();
  }

  function getVoterVotingPower(address voter) external view override returns(uint) {
    return LibVotingPower._getVoterVotingPower(voter);
  }

  function getTotalAmountOfVotingPower() external view override returns(uint) {
    return LibVotingPower._getTotalAmountOfVotingPower();
  }

  function getMaxAmountOfVotingPower() external view override returns(uint) {
    return LibVotingPower._getMaxAmountOfVotingPower();
  }

}
