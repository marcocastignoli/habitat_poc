// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library TreasuryStorage {

    enum ProposalStatus { 
      NoProposal,
      PassedAndReadyForExecution, 
      RejectedAndReadyForExecution,
      PassedAndExecutionStuck,
      VotePending,
      Passed,  
      Rejected        
    }

    struct TreasuryVotingPower {
      uint64 minimumQuorum;
      uint64 thresholdForProposal;
      uint64 thresholdForInitiator;
      uint64 precision;
    }

    struct Proposal {
      bool proposalAccepted;
      address destinationAddress;
      uint value;
      bytes callData;
      bool proposalExecuted;
    }

    struct ProposalVoting {
      mapping(address => bool) voted;
      bool votingStarted;
      uint deadlineTimestamp;
      uint votesYes;
      uint votesNo;
    }

    struct Layout {        
      TreasuryVotingPower treasuryVotingPower;
      uint128 maxDuration;
      uint128 proposalsCount;
      uint[] activeProposalsIds;
      mapping(uint => Proposal) proposals;
      mapping(uint => ProposalVoting) proposalVotings;
    }

    bytes32 internal constant STORAGE_SLOT =
      keccak256('treasury.storage');

    function layout() internal pure returns (Layout storage l) {
      bytes32 slot = STORAGE_SLOT;
      assembly {
          l.slot := slot
      }
    }
}
