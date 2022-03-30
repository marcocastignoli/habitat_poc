// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library VotingPowerStorage {

    enum Type {
      Governance, // 0
      Treasury // 1
    }

    struct Domain {
      uint precision;
      uint totalAmountOfVotingPower;
      uint maxAmountOfVotingPower;
      // tokenID => coefficient
      mapping(uint256 => uint256) multipliers;
      // user => votingpower
      mapping(address => uint) votingPower;
    }

    struct Layout {
      // Type (treasury or governance) => token settings of domain
      mapping(Type => Domain) domains;
      // roleID/token => isrole? roles are non-user-transferrable
      mapping(uint256 => bool) isRole;

      // // holder => token => staked amount
      // replaced by balanceOf(user, getIDByToken(token))
      // mapping(address => mapping(address => uint)) stakedHoldings;
    }

    bytes32 internal constant STORAGE_SLOT =
      keccak256('domains.votingpower.tokens.wrapper.storage');

    function layout() internal pure returns (Layout storage l) {
      bytes32 slot = STORAGE_SLOT;
      assembly {
          l.slot := slot
      }
    }
}
