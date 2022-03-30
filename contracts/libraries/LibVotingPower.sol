// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

<<<<<<< Updated upstream
import { IVotingPower } from "../interfaces/IVotingPower.sol";
import { LibTreasury } from "./LibTreasury.sol";

library LibVotingPower {
    bytes32 constant VOTING_POWER_STORAGE_POSITION = keccak256("habitat.diamond.standard.votingPower.storage");
/*
  struct VotingPower {
    address votingPowerManager;
    mapping(address => uint) votingPower;
    uint totalAmountOfVotingPower;
    uint maxAmountOfVotingPower;
  }
*/
    function votingPowerStorage() internal pure returns (IVotingPower.VotingPower storage vp) {
        bytes32 position = VOTING_POWER_STORAGE_POSITION;
        assembly {
            vp.slot := position
        }
    }

    function _increaseVotingPower(address voter, uint amount) internal {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      require(msg.sender == vp.votingPowerManager);
      // increase totalVotingPower
      vp.totalAmountOfVotingPower += amount;
      // increase voter voting power
      vp.votingPower[voter] += amount;
    }

    function _decreaseVotingPower(address voter, uint amount) internal {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      require(msg.sender == vp.votingPowerManager);
      require(!LibTreasury._hasVotedInActiveProposals(voter), "Cannot unstake until proposal is active");
      // decrease totalVotingPower
      vp.totalAmountOfVotingPower -= amount;
      // decrease voter voting power
      vp.votingPower[voter] -= amount;
    }

    // View functions
    function _getVotingPowerManager() internal view returns(address) {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      return vp.votingPowerManager;
    }

    function _getVoterVotingPower(address voter) internal view returns(uint) {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      return vp.votingPower[voter];
    }

    function _getTotalAmountOfVotingPower() internal view returns(uint) {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      return vp.totalAmountOfVotingPower;
    }

    function _getMaxAmountOfVotingPower() external view returns(uint) {
      IVotingPower.VotingPower storage vp = votingPowerStorage();
      return vp.maxAmountOfVotingPower;
    }
=======
// import { LibTreasury } from "./LibTreasury.sol";
import { VotingPowerStorage } from '../storage/VotingPowerStorage.sol';
import { TreasuryStorage } from '../storage/TreasuryStorage.sol';
import { LibTreasury } from './LibTreasury.sol';

import "hardhat/console.sol";

library LibVotingPower {

  function _increaseVotingPower(address voter, uint amount) internal {
    VotingPowerStorage.Layout storage l = VotingPowerStorage.layout();
    VotingPowerStorage.Domain storage d = l.domains[VotingPowerStorage.Type.Treasury];
    // TODO: require msg.sender == operator
    d.votingPower[voter] += amount;
  }

  function _decreaseVotingPower(address voter, uint amount) internal {
    VotingPowerStorage.Layout storage l = VotingPowerStorage.layout();
    VotingPowerStorage.Domain storage d = l.domains[VotingPowerStorage.Type.Treasury];

    // TODO: require msg.sender == operator
    // require(!LibTreasury._hasVotedInActiveProposals(voter), "Cannot unstake until proposal is active");
    d.votingPower[voter] -= amount;
  }

  function _getVoterVotingPower(address voter) internal view returns(uint) {
    VotingPowerStorage.Layout storage l = VotingPowerStorage.layout();
    VotingPowerStorage.Domain storage d = l.domains[VotingPowerStorage.Type.Treasury];
    return d.votingPower[voter];
  }

  function _getTotalAmountOfVotingPower() internal view returns(uint) {
    VotingPowerStorage.Layout storage l = VotingPowerStorage.layout();
    VotingPowerStorage.Domain storage d = l.domains[VotingPowerStorage.Type.Treasury];
    return d.totalAmountOfVotingPower;
  }

  function _getMaxAmountOfVotingPower() internal view returns(uint) {
    VotingPowerStorage.Layout storage l = VotingPowerStorage.layout();
    VotingPowerStorage.Domain storage d = l.domains[VotingPowerStorage.Type.Treasury];
    return d.maxAmountOfVotingPower;
  }


  function _getMinimumQuorum() internal view returns(uint) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint maxAmountOfVotingPower = _getMaxAmountOfVotingPower();
    return uint(tvp.minimumQuorum) * maxAmountOfVotingPower / uint(tvp.precision);
  }

  function _isQuorum() internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint maxAmountOfVotingPower = _getMaxAmountOfVotingPower();
    uint totalAmountOfVotingPower = _getTotalAmountOfVotingPower();
    return uint(tvp.minimumQuorum) * maxAmountOfVotingPower / uint(tvp.precision) <= totalAmountOfVotingPower;
  }

  function _isEnoughVotingPower(address holder) internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint voterPower = _getVoterVotingPower(holder);
    uint totalAmountOfVotingPower = _getTotalAmountOfVotingPower();
    return voterPower >= (uint(tvp.thresholdForInitiator) * totalAmountOfVotingPower / uint(tvp.precision));
  }

  function _isProposalThresholdReached(uint amountOfVotes) internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint totalAmountOfVotingPower = _getTotalAmountOfVotingPower();
    return amountOfVotes >= (uint(tvp.thresholdForProposal) * totalAmountOfVotingPower / uint(tvp.precision));
  }
>>>>>>> Stashed changes

}
