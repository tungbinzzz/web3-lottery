export const CONTRACT_ADDRESS = "0x8c9207BaA0Eb7bA6F969C6da3Dd1Ec672e22B8b5";

export const CONTRACT_ABI = [
  {
    "inputs": [
      { "internalType": "uint256", "name": "entranceFee", "type": "uint256" },
      { "internalType": "uint256", "name": "subscriptionId", "type": "uint256" },
      { "internalType": "address", "name": "vrfCoordinator", "type": "address" },
      { "internalType": "bytes32", "name": "keyHash", "type": "bytes32" },
      { "internalType": "uint32", "name": "callbackGasLimit", "type": "uint32" },
      { "internalType": "uint256", "name": "interval", "type": "uint256" }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  { "inputs": [], "name": "Lottery__InvalidEntranceFee", "type": "error" },
  { "inputs": [], "name": "Lottery__NotEnoughBalance", "type": "error" },
  { "inputs": [], "name": "Lottery__NotEnoughPlayers", "type": "error" },
  { "inputs": [], "name": "Lottery__NotOpen", "type": "error" },
  { "inputs": [], "name": "Lottery__TransferFailed", "type": "error" },
  { "inputs": [], "name": "Lottery__UpkeepNotNeeded", "type": "error" },
  {
    "inputs": [
      { "internalType": "address", "name": "have", "type": "address" },
      { "internalType": "address", "name": "want", "type": "address" }
    ],
    "name": "OnlyCoordinatorCanFulfill",
    "type": "error"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "have", "type": "address" },
      { "internalType": "address", "name": "owner", "type": "address" },
      { "internalType": "address", "name": "coordinator", "type": "address" }
    ],
    "name": "OnlyOwnerOrCoordinator",
    "type": "error"
  },
  { "inputs": [], "name": "ZeroAddress", "type": "error" },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "address", "name": "vrfCoordinator", "type": "address" }
    ],
    "name": "CoordinatorSet",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "address", "name": "winner", "type": "address" },
      { "indexed": false, "internalType": "uint256", "name": "balance", "type": "uint256" }
    ],
    "name": "LotteryClaimed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "address", "name": "player", "type": "address" }
    ],
    "name": "LotteryEntered",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "uint256", "name": "requestId", "type": "uint256" }
    ],
    "name": "LotteryRequested",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "address", "name": "from", "type": "address" },
      { "indexed": true, "internalType": "address", "name": "to", "type": "address" }
    ],
    "name": "OwnershipTransferRequested",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "address", "name": "from", "type": "address" },
      { "indexed": true, "internalType": "address", "name": "to", "type": "address" }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "address", "name": "winner", "type": "address" },
      { "indexed": false, "internalType": "uint256", "name": "balance", "type": "uint256" }
    ],
    "name": "WinnerPicked",
    "type": "event"
  },
  { "inputs": [], "name": "acceptOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  {
    "inputs": [{ "internalType": "bytes", "name": "", "type": "bytes" }],
    "name": "checkUpkeep",
    "outputs": [
      { "internalType": "bool", "name": "upkeepNeeded", "type": "bool" },
      { "internalType": "bytes", "name": "", "type": "bytes" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  { "inputs": [], "name": "enterLottery", "outputs": [], "stateMutability": "payable", "type": "function" },
  { "inputs": [], "name": "getEntranceFee", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getLastUpkeepTimeStamp", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getLotteryState", "outputs": [{ "internalType": "enum Lottery.LotteryState", "name": "", "type": "uint8" }], "stateMutability": "view", "type": "function" },
  { "inputs": [{ "internalType": "uint256", "name": "index", "type": "uint256" }], "name": "getPlayerByIndex", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getPlayersLength", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getRecentWinner", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getRewardBalance", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "getVRFCoordinator", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
  { "inputs": [{ "internalType": "address", "name": "winner", "type": "address" }], "name": "getWinnerBalance", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "i_interval", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "owner", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
  { "inputs": [{ "internalType": "bytes", "name": "", "type": "bytes" }], "name": "performUpkeep", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  {
    "inputs": [
      { "internalType": "uint256", "name": "requestId", "type": "uint256" },
      { "internalType": "uint256[]", "name": "randomWords", "type": "uint256[]" }
    ],
    "name": "rawFulfillRandomWords",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  { "inputs": [], "name": "s_lastTimeStamp", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
  { "inputs": [], "name": "s_vrfCoordinator", "outputs": [{ "internalType": "contract IVRFCoordinatorV2Plus", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
  { "inputs": [{ "internalType": "address", "name": "_vrfCoordinator", "type": "address" }], "name": "setCoordinator", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  { "inputs": [{ "internalType": "address", "name": "to", "type": "address" }], "name": "transferOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
  { "inputs": [], "name": "windrawReward", "outputs": [], "stateMutability": "nonpayable", "type": "function" }
];
