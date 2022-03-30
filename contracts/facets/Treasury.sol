// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { LibTreasury } from "../libraries/LibTreasury.sol";
import { LibVotingPower } from "../libraries/LibVotingPower.sol";
import { TreasuryStorage } from '../storage/TreasuryStorage.sol';
import { VotingPowerStorage } from '../storage/VotingPowerStorage.sol';

import "hardhat/console.sol";

contract Treasury {

  event TreasuryProposalCreated(
    uint indexed proposalId,
    uint indexed deadlineTimestamp
  );

  event TreasuryProposalAccepted(
    uint indexed proposalId,
    address indexed destination,
    uint indexed value,
    bytes callData
  );

  event TreasuryProposalRejected(
    uint indexed proposalId,
    address indexed destination,
    uint indexed value,
    bytes callData
  );

  event ProposalExecuted(
    uint indexed proposalId, 
    address indexed destination, 
    uint indexed value, 
    bytes callData
   );

  event ProposalStuck(
    uint indexed proposalId, 
    address indexed destination, 
    uint indexed value, 
    bytes callData
   );

  function initTreasury(
    uint128 _maxDuration,
    uint64 _minimumQuorum,
    uint64 _thresholdForProposal,
    uint64 _thresholdForInitiator,
    uint64 _precision
  ) external {
    TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
    ts.maxDuration = _maxDuration;
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();

    tvp.minimumQuorum = _minimumQuorum;
    tvp.thresholdForProposal = _thresholdForProposal;
    tvp.thresholdForInitiator = _thresholdForInitiator;
    tvp.precision = _precision;
  }

  /// voting functions
  function createTreasuryProposal(
    address destination,
    uint value,
    bytes calldata callData,
    uint128 deadlineTimestamp
  ) public returns(uint) {
    // check if minimumQuorum
    require(LibTreasury._isQuorum(), "Minimum quorum not met.");
    // threshold for creating proposals
    require(LibTreasury._isEnoughVotingPower(msg.sender), "Not enough voting power to create proposal.");
    bytes4 destSelector = bytes4(callData[0:4]); // @docs- "array slices"
    _checkIfDestinationIsDiamond(destination, destSelector);

    // start creating proposal
    uint proposalId = _getTreasuryFreeProposalId();
    // create proposal
    TreasuryStorage.Proposal storage p = LibTreasury._getTreasuryProposal(proposalId);
    p.destinationAddress = destination;
    p.value = value;
    p.callData = callData;

    // create proposalVoting
    TreasuryStorage.ProposalVoting storage pv = LibTreasury._getTreasuryProposalVoting(proposalId);

    pv.votingStarted = true;

    uint128 maxDuration = LibTreasury._getTreasuryMaxDuration();
    if (deadlineTimestamp == uint128(0) || deadlineTimestamp > uint128(block.timestamp) + maxDuration) {
      pv.deadlineTimestamp = uint(maxDuration) + block.timestamp;
    } else {
      pv.deadlineTimestamp = uint(deadlineTimestamp);
    }

    // initiator votes
    pv.voted[msg.sender] = true;
    pv.votesYes += LibVotingPower._getVoterVotingPower(msg.sender);

    emit TreasuryProposalCreated(proposalId, pv.deadlineTimestamp);

    return proposalId;
  }

  function createSeveralTreasuryProposals(
    address[] calldata destinations,
    uint[] calldata values,
    bytes[] calldata callDatas,
    uint128[] calldata deadlineTimestamps
  ) external returns(uint[] memory) {
    uint numberOfProposals = destinations.length;
    require(values.length == numberOfProposals && callDatas.length == numberOfProposals && deadlineTimestamps.length == numberOfProposals, "Different array length");
    uint[] memory proposalIds = new uint[](numberOfProposals);
    for (uint i = 0; i < proposalIds.length; i++) {
      proposalIds[i] = createTreasuryProposal(destinations[i], values[i], callDatas[i], deadlineTimestamps[i]);
    }
    return proposalIds;
  }

  // try to minimize gas here amap
  function voteForOneTreasuryProposal(
    uint proposalId,
    bool vote
  ) public {
    TreasuryStorage.ProposalVoting storage pv = LibTreasury._getTreasuryProposalVoting(proposalId);
    require(pv.votingStarted, "No voting rn.");
    require(!pv.voted[msg.sender], "Already voted.");
    uint amountOfVotingPower = LibVotingPower._getVoterVotingPower(msg.sender);
    pv.voted[msg.sender] = true;
    if (vote) {
      pv.votesYes += amountOfVotingPower;
    } else {
      pv.votesNo += amountOfVotingPower;
    }
  }

  function voteForSeveralTreasuryProposals(
    uint[] calldata proposalsIds,
    bool[] calldata votes
  ) external {
    require(proposalsIds.length == votes.length, "Different array length");
    for (uint i = 0; i < proposalsIds.length; i++) {
      voteForOneTreasuryProposal(proposalsIds[i], votes[i]);
    }
  }

  function acceptOrRejectTreasuryProposal(
    uint proposalId
  ) public {
    TreasuryStorage.ProposalVoting storage pv = LibTreasury._getTreasuryProposalVoting(proposalId);
    TreasuryStorage.Proposal storage p = LibTreasury._getTreasuryProposal(proposalId);
    require(!p.proposalAccepted, "Proposal is already accepted");
    require(pv.votingStarted, "No voting.");

    if (pv.votesYes > pv.votesNo) {
      if (LibTreasury._isProposalThresholdReached(pv.votesYes)) {
        // accept proposal
        pv.votingStarted = false;
        p.proposalAccepted = true;
        _removeProposalIdFromActive(proposalId);
        emit TreasuryProposalAccepted(
          proposalId,
          p.destinationAddress,
          p.value,
          p.callData
        );
      } else {
        // check deadlineTimestamp
        if (pv.deadlineTimestamp <= block.timestamp) {
          // reject proposal
          _removeProposalIdFromActive(proposalId);
          LibTreasury._removeTreasuryPropopalVoting(proposalId);
          emit TreasuryProposalRejected(
            proposalId,
            p.destinationAddress,
            p.value,
            p.callData
          );
          LibTreasury._removeTreasuryPropopal(proposalId);
        } else {
          console.log('waiting...');
          return; // no actions still need to vote and wait deadline
        }
      }
    } else {
      if (LibTreasury._isProposalThresholdReached(pv.votesNo)) {
        // proposal rejected
        LibTreasury._removeTreasuryPropopalVoting(proposalId);
        _removeProposalIdFromActive(proposalId);
        emit TreasuryProposalRejected(
          proposalId,
          p.destinationAddress,
          p.value,
          p.callData
        );
        LibTreasury._removeTreasuryPropopal(proposalId);
      } else {
        if (pv.deadlineTimestamp <= block.timestamp) {
          // proposal rejected
          LibTreasury._removeTreasuryPropopalVoting(proposalId);
          _removeProposalIdFromActive(proposalId);
          emit TreasuryProposalRejected(
            proposalId,
            p.destinationAddress,
            p.value,
            p.callData
          );
          LibTreasury._removeTreasuryPropopal(proposalId);
        } else {
          return; // no actions still need to vote and wait deadline
        }
      }
    }
  }

  function acceptOrRejectSeveralTreasuryProposals(
    uint[] calldata proposalIds
  ) external {
    for (uint i = 0; i < proposalIds.length; i++) {
      acceptOrRejectTreasuryProposal(proposalIds[i]);
    }
  }

  function _getTreasuryFreeProposalId() internal returns(uint proposalId) {
    TreasuryStorage.Layout storage ts = TreasuryStorage.layout();
    require(ts.activeProposalsIds.length < 200, "No more proposals pls");
    ts.proposalsCount = ts.proposalsCount + uint128(1);
    proposalId = uint(ts.proposalsCount);
    ts.activeProposalsIds.push(proposalId);
  }

  function _removeProposalIdFromActive(uint proposalId) internal {
    uint[] storage atp = LibTreasury._getTreasuryActiveProposalsIds(); // active proposals
    require(atp.length > 0, "No active proposals.");
    if (atp[atp.length - 1] == proposalId) {
      atp.pop();
    } else {
      // try to find array index
      uint indexId;
      for (uint index = 0; index < atp.length; index++) {
        if (atp[index] == proposalId) {
          indexId = index;
        }
      }
      // replace last
      atp[indexId] = atp[atp.length - 1];
      atp[atp.length - 1] = proposalId;
      atp.pop();
    }
  }

  function _checkIfDestinationIsDiamond(address _destination, bytes4 _selector) internal view {
    if (_destination == address(this)) {
      // allow to call diamond only as ERC20 functionallity
      //(transfer(address,uint256), approve(address,uint256), increaseAllowance, decreaseAllowance)
      require(
        _selector == 0xa9059cbb ||
        _selector == 0x095ea7b3 ||
        _selector == 0x39509351 ||
        _selector == 0xa457c2d7,
        "Treasury proposals are related only to governance token."
      );
    }
  }

  /// proposal execution functions
  function executeTreasuryProposal(uint proposalId) external returns(bool result) {
    TreasuryStorage.Proposal storage tp = LibTreasury._getTreasuryProposal(proposalId);

    require(tp.proposalAccepted && !tp.proposalExecuted, "Proposal not accepted.");
    tp.proposalExecuted = true;

    address destination = tp.destinationAddress;
    uint value = tp.value;
    bytes memory callData = tp.callData;

    assembly {
      result := call(
        gas(), 
        destination, 
        value, 
        add(callData, 0x20), 
        mload(callData), 
        0, 
        0
      )
    }

    // return data needed?
    // also maybe depend on result delete only proposalVoting if result 0

    //remove proposal and proposal voting
    LibTreasury._removeTreasuryPropopal(proposalId);
    LibTreasury._removeTreasuryPropopalVoting(proposalId);
    if (result = true) {
      emit ProposalExecuted(proposalId, destination, value, callData);
    } else if (result = false) {
      emit ProposalStuck(proposalId, destination, value, callData);
    }
  }

  function createSubTreasuryType0() external {
  }

  function createSubTreasuryType1() external {
  }


  /// treasury view functions

  function getTreasuryMaxDuration() external view returns(uint128) {
    return TreasuryStorage.layout().maxDuration;
  }

  function getTreasuryProposalsCount() external view returns(uint128) {
    return TreasuryStorage.layout().proposalsCount;
  }

  function getActiveProposalsIds() external view returns(uint[] memory) {
    return TreasuryStorage.layout().activeProposalsIds;
  }

  function getTreasuryProposal(uint proposalId) external view returns(TreasuryStorage.Proposal memory) {
    return LibTreasury._getTreasuryProposal(proposalId);
  }
  // return ProposalVoting struct
  function getTreasuryProposalVotingVotesYes(uint proposalId) external view returns(uint) {
    return LibTreasury._getTreasuryProposalVoting(proposalId).votesYes;
  }
  function getTreasuryProposalVotingVotesNo(uint proposalId) external view returns(uint) {
    return LibTreasury._getTreasuryProposalVoting(proposalId).votesNo;
  }
  function getTreasuryProposalVotingDeadlineTimestamp(uint proposalId) external view returns(uint) {
    return LibTreasury._getTreasuryProposalVoting(proposalId).deadlineTimestamp;
  }
  function isHolderVotedForProposal(uint proposalId, address holder) external view returns(bool) {
    return LibTreasury._getTreasuryProposalVoting(proposalId).voted[holder];
  }
  function isVotingForProposalStarted(uint proposalId) external view returns(bool) {
    return LibTreasury._getTreasuryProposalVoting(proposalId).votingStarted;
  }

  function hasVotedInActiveProposals(address voter) external view returns(bool) {
    TreasuryStorage.Layout storage t = TreasuryStorage.layout();

    if (t.activeProposalsIds.length == 0) {
      return false;
    }

    for (uint i = 0; i < t.activeProposalsIds.length; i++) {
      uint proposalId = t.activeProposalsIds[i];
      bool hasVoted = t.proposalVotings[proposalId].voted[voter];
      if (hasVoted) {
        return true;
      }
    }

    return false;
  }


  /// voting power viewer functions
  function minimumQuorumNumerator() external view returns(uint64) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    return tvp.minimumQuorum;
  }

  function thresholdForProposalNumerator() external view returns(uint64) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    return tvp.thresholdForProposal;
  }

  function thresholdForInitiatorNumerator() external view returns(uint64) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    return tvp.thresholdForInitiator;
  }

  function treasuryDenominator() external view returns(uint64) {
    TreasuryStorage.TreasuryVotingPower storage tvp = LibTreasury._getTreasuryVotingPower();
    return tvp.precision;
  }

  function getMinimumQuorum() external view returns(uint) {
    return LibTreasury._getMinimumQuorum();
  }

  function isQuorum() external view returns(bool) {
    return LibTreasury._isQuorum();
  }

  function isEnoughVotingPower(address holder) external view returns(bool) {
    return LibTreasury._isEnoughVotingPower(holder);
  }

  function isProposalThresholdReached(uint amountOfVotes) external view returns(bool) {
    return LibTreasury._isProposalThresholdReached(amountOfVotes);
  }

}
