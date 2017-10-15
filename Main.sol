pragma solidity ^0.4.15;


contract CompanyFactory {

  // owner => company
  mapping(address => address) public companies;

  function createCompany(string name, string fileHash) returns (address) {
    address company = new Company(msg.sender, name, fileHash);

    companies[msg.sender] = company;

    return company;
  }
}

contract Company {

  address owner;

  string public name;
  string public fileHash;
  uint256 public spentETH;
  address[256] public screenings;
  uint32 public screeningCount;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function Company(address _owner, string _name, string _fileHash) {
    owner = _owner;
    name = _name;
    fileHash = _fileHash;
  }

  function createScreening(
    uint16 dbID,
    string screeningName,
    uint8 minorReward,
    uint8 majorReward,
    uint8 criticalReward
  )
  onlyOwner returns (address) {
    address screening = new Screening(msg.sender, dbID, screeningName, minorReward, majorReward, criticalReward);

    screenings[screeningCount] = screening;
    screeningCount += 1;

    return screening;
  }
}

contract Screening {

  address owner;

  uint16 dbID;
  uint256 public bounty;
  string public name;
  uint8 public minorReward;
  uint8 public majorReward;
  uint8 public criticalReward;
  bool isActive = true;

  // owner => claim
  mapping(address => address) public claims;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function Screening(
    address _owner,
    uint16 _dbID,
    string _name,
    uint8 _minorReward,
    uint8 _majorReward,
    uint8 _criticalReward
  ) {
    owner = _owner;
    bounty = msg.value;

    dbID = _dbID;
    name = _name;
    minorReward = _minorReward;
    majorReward = _majorReward;
    criticalReward = _criticalReward;
  }

  function stop() onlyOwner {
    isActive = false;
  }

  function start() onlyOwner {
    isActive = true;
  }

  function close() onlyOwner {

  }

  function createClaim(
    uint16 dbID,
    uint8 startLineNum,
    uint8 endLineNum,
    string comment,
    int isMinor,
    int isMajor,
    int isCritical
  )
  returns (address) {
    address claim = new Claim(dbID, startLineNum, endLineNum, comment, isMinor, isMajor, isCritical);

    claims[msg.sender] = claim;

    return claim;
  }

  function acceptClaim(address claimAddress) onlyOwner {
    Claim claim = Claim(claimAddress);
    uint256 reward = 0;

    if (claim.isMinor() == 1) {
      reward = minorReward;
    }
    if (claim.isMajor() == 1) {
      reward = majorReward;
    }
    if (claim.isCritical() == 1) {
      reward = criticalReward;
    }

    msg.sender.transfer(reward);
    claim.accept();
  }

  function rejectClaim(address claimAddress) onlyOwner {
    Claim claim = Claim(claimAddress);
    claim.reject();
  }

  function () payable {}
}

contract Claim {

  address screeningAddress;

  uint16 dbID;
  uint8 public startLineNum;
  uint8 public endLineNum;
  string public comment;
  string public category;
  int public isMinor;
  int public isMajor;
  int public isCritical;
  bool public isAccepted = false;
  bool public isRejected = false;

  modifier onlyScreeningOwner {
    require(msg.sender == screeningAddress);
    _;
  }

  function Claim(
    uint16 _dbID,
    uint8 _startLineNum,
    uint8 _endLineNum,
    string _comment,
    int _isMinor,
    int _isMajor,
    int _isCritical
  ) {
    screeningAddress = msg.sender;

    dbID = _dbID;
    startLineNum = _startLineNum;
    endLineNum = _endLineNum;
    comment = _comment;
    isMinor = _isMinor;
    isMajor = _isMajor;
    isCritical = _isCritical;
  }

  function accept() onlyScreeningOwner {
    isAccepted = true;
  }

  function reject() onlyScreeningOwner {
    isRejected = true;
  }
}
