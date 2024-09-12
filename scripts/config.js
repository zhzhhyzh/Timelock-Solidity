//1- connect metamask
let account;
//   import TimelockContract from "./build/contracts/Timelock.json";
//   import AccountManagerContract from "./build/contracts/AccountManager.json";
let timelockContract;
let accountManagerContract;

const accessToMetamask = async () => {
  if (window.ethereum !== "undefined") {
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    account = accounts[1];
    console.log(account)
    // document.getElementById("accountArea").innerHTML = account;
  }
};

//2- connect to smart contract
const accessToContract = async () => {
  const response = await fetch("/build/contracts/Timelock.json");
  const data = await response.json();
  const response2 = await fetch("/build/contracts/AccountManager.json");
  const data2 = await response2.json();
  const timelockABI = data.abi;
  const accountManagerABI = data2.abi;
  const timelockAddress = "0x5f9a39fb59486B98FCFC091188f2faB0B1ECe0B0";
  const accountManagerAddress =
    "0x59FEEc8024597B04a6b51aD25597E1d78dde3E44";
  window.web3 = await new Web3(window.ethereum); //how to access to smart contract
  timelockContract = await new window.web3.eth.Contract(
    timelockABI,
    timelockAddress
  ); //how you create an instance of that contract by using the abi and address
  accountManagerContract = await new window.web3.eth.Contract(
    accountManagerABI,
    accountManagerAddress
  ); //how you create an instance of that contract by using the abi and address
  // var accManagerContract = await new window.web3.eth.Contract(
  //   AccountManagerABI,
  //   accountManagerAddress
  // ); //how you create an instance of that contract by using the abi and address
  console.log(
    "connected to smart contract")


};


const switchAccount = async (index) => {
  if (window.ethereum !== "undefined") {
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    account = accounts[index];
    console.log("Account Switched")
    document.getElementById("address").innerText = account
    // document.getElementById("accountArea").innerHTML = account;
  }
}

accessToMetamask()
accessToContract()