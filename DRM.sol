pragma solidity ^0.4.0;

contract DRM {

  address screeningAddress;
  address claimAddress;

  uint16 contractorVotes;
  uint16 reviwerVotes;
  uint16 votes;

  bool votingOpen;

  modifier onlyIfOpen() {
    require(votingOpen);
    _;
  }

  function DRM(address _screeningAddress, address _claimAddress){
    screeningAddress = _screeningAddress;
    claimAddress = _claimAddress;
  }

  function voteForContractor() onlyIfOpen {
    // to do check perms
    contractorVotes += 1;
    votes +=1;
  }

  function voteForReviewer() onlyIfOpen {
    // to do check perms
    reviwerVotes += 1;
    votes +=1;
  }

  function setDecision() internal {

  }
}
