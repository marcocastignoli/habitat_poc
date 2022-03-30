// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

<<<<<<< Updated upstream
import { ITreasury } from "../interfaces/treasury/ITreasury.sol";
import { ITreasuryVotingPower } from "../interfaces/treasury/ITreasuryVotingPower.sol";

library LibTreasury {
    bytes32 constant TREASURY_STORAGE_POSITION = keccak256("habitat.diamond.standard.treasury.storage");
/*
    struct Treasury {
        VotingType votingType;
        TreasuryVotingPower treasuryVotingPower;
        uint128 maxDeadLine;
        uint128 proposalsCount;
        uint[] activeProposalsIds;
        mapping(uint => Proposal) proposals;
        mapping(uint => ProposalVoting) proposalVotings;
    }
*/
    function treasuryStorage() internal pure returns (ITreasury.Treasury storage ts) {
        bytes32 position = TREASURY_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    function _getTreasuryProposal(uint proposalId) internal view returns(ITreasury.Proposal storage p) {
      ITreasury.Treasury storage ts = treasuryStorage();
      p = ts.proposals[proposalId];
    }

    function _getTreasuryProposalVoting(uint proposalId) internal view returns(ITreasury.ProposalVoting storage pv) {
      ITreasury.Treasury storage ts = treasuryStorage();
      pv = ts.proposalVotings[proposalId];
    }

    function _getTreasuryVotingPower() internal view returns(ITreasuryVotingPower.TreasuryVotingPower storage treasuryVotingPower) {
      ITreasury.Treasury storage ts = treasuryStorage();
      treasuryVotingPower = ts.treasuryVotingPower;
    }

    function _getTreasuryMaxDuration() internal view returns(uint128) {
      ITreasury.Treasury storage ts = treasuryStorage();
=======
import { TreasuryStorage } from '../storage/TreasuryStorage.sol';
import { LibVotingPower } from './LibVotingPower.sol';
import { VotingPowerStorage } from '../storage/VotingPowerStorage.sol';

library LibTreasury {

    function _getTreasuryProposal(uint proposalId) internal view returns(TreasuryStorage.Proposal storage p) {
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
      p = ts.proposals[proposalId];
    }

    function _getTreasuryProposalVoting(uint proposalId) internal view returns(TreasuryStorage.ProposalVoting storage pv) {
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
      pv = ts.proposalVotings[proposalId];
    }

    function _getTreasuryVotingPower() internal view returns(TreasuryStorage.TreasuryVotingPower storage tvp) {
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
      tvp = ts.treasuryVotingPower;
    }

    function _getTreasuryMaxDuration() internal view returns(uint128) {
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
>>>>>>> Stashed changes
      return ts.maxDuration;
    }

    function _getTreasuryActiveProposalsIds() internal view returns(uint[] storage) {
<<<<<<< Updated upstream
      ITreasury.Treasury storage ts = treasuryStorage();
=======
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
>>>>>>> Stashed changes
      return ts.activeProposalsIds;
    }

    function _removeTreasuryPropopal(uint proposalId) internal {
<<<<<<< Updated upstream
      ITreasury.Proposal storage proposal = _getTreasuryProposal(proposalId);
      delete proposal.proposalAccepted;
      delete proposal.destinationAddress;
      delete proposal.value;
      delete proposal.callData;
      delete proposal.proposalExecuted;
    }

    function _removeTreasuryPropopalVoting(uint proposalId) internal {
      ITreasury.ProposalVoting storage proposalVoting = _getTreasuryProposalVoting(proposalId);
      delete proposalVoting.votingStarted;
      delete proposalVoting.deadlineTimestamp;
      delete proposalVoting.votesYes;
      delete proposalVoting.votesNo;
    }

    function _hasVotedInActiveProposals(address voter) internal view returns(bool) {
      ITreasury.Treasury storage treasury = treasuryStorage();

      if (treasury.activeProposalsIds.length == 0) {
        return false;
      }

      for (uint i = 0; i < treasury.activeProposalsIds.length; i++) {
        uint proposalId = treasury.activeProposalsIds[i];
        bool hasVoted = treasury.proposalVotings[proposalId].voted[voter];
=======
      TreasuryStorage.Proposal storage p = _getTreasuryProposal(proposalId);
      delete p.proposalAccepted;
      delete p.destinationAddress;
      delete p.value;
      delete p.callData;
      delete p.proposalExecuted;
    }

    function _removeTreasuryPropopalVoting(uint proposalId) internal {
      TreasuryStorage.ProposalVoting storage pv = _getTreasuryProposalVoting(proposalId);
      delete pv.votingStarted;
      delete pv.deadlineTimestamp;
      delete pv.votesYes;
      delete pv.votesNo;
    }

    function _hasVotedInActiveProposals(address voter) internal view returns(bool) {
      TreasuryStorage.Layout storage ts = TreasuryStorage.layout();

      if (ts.activeProposalsIds.length == 0) {
        return false;
      }

      for (uint i = 0; i < ts.activeProposalsIds.length; i++) {
        uint proposalId = ts.activeProposalsIds[i];
        bool hasVoted = ts.proposalVotings[proposalId].voted[voter];
>>>>>>> Stashed changes
        if (hasVoted) {
          return true;
        }
      }
<<<<<<< Updated upstream

      return false;
    }
=======
      return false;
    }

  /// treasury voting power functions
  function _getMinimumQuorum() internal view returns(uint) {
    TreasuryStorage.TreasuryVotingPower storage tvp = _getTreasuryVotingPower();
    uint maxAmountOfVotingPower = LibVotingPower._getMaxAmountOfVotingPower();
    return uint(tvp.minimumQuorum) * maxAmountOfVotingPower / uint(tvp.precision);
  }

  function _isQuorum() internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint maxAmountOfVotingPower = LibVotingPower._getMaxAmountOfVotingPower();
    uint totalAmountOfVotingPower = LibVotingPower._getTotalAmountOfVotingPower();
    return uint(tvp.minimumQuorum) * maxAmountOfVotingPower / uint(tvp.precision) <= totalAmountOfVotingPower;
  }

  function _isEnoughVotingPower(address holder) internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    uint voterPower = LibVotingPower._getVoterVotingPower(holder);
    uint totalAmountOfVotingPower = LibVotingPower._getTotalAmountOfVotingPower();
    return voterPower >= (uint(tvp.thresholdForInitiator) * totalAmountOfVotingPower / uint(tvp.precision));
  }

  function _isProposalThresholdReached(uint amountOfVotes) internal view returns(bool) {
    TreasuryStorage.TreasuryVotingPower storage tvp = _getTreasuryVotingPower();
    uint totalAmountOfVotingPower = LibVotingPower._getTotalAmountOfVotingPower();
    return amountOfVotes >= (uint(tvp.thresholdForProposal) * totalAmountOfVotingPower / uint(tvp.precision));
  }
>>>>>>> Stashed changes
}
