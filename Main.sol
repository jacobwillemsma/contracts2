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
    string storjHash,
    string screeningName,
    uint256 minorReward,
    uint256 majorReward,
    uint256 criticalReward
  )
  onlyOwner payable returns (address) {
    require(msg.value != 0);

    address screening = new Screening(
      msg.sender,
      storjHash,
      screeningName,
      minorReward,
      majorReward,
      criticalReward
    );

    screening.transfer(msg.value);

    screenings[screeningCount] = screening;
    screeningCount += 1;

    return screening;
  }
}

contract Screening {

  address owner;

  string storjHash;
  uint256 public bounty;
  string public name;
  uint256 public minorReward;
  uint256 public majorReward;
  uint256 public criticalReward;
  bool isActive = true;

  // owner => claim
  mapping(address => address) public claims;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function Screening(
    address _owner,
    string _storjHash,
    string _name,
    uint256 _minorReward,
    uint256 _majorReward,
    uint256 _criticalReward
  ) {
    owner = _owner;
    bounty = msg.value;

    storjHash = _storjHash;
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
