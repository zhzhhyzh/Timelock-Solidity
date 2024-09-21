//1- connect metamask
let account;
//   import TimelockContract from "./build/contracts/Timelock.json";
//   import AccountManagerContract from "./build/contracts/AccountManager.json";
let timelockContract;
let accountManagerContract;
let voteAdminContract;

const accessToMetamask = async () => {
  if (window.ethereum !== "undefined") {
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    account = accounts[1];
    document.getElementById("address").innerText = account
    // document.getElementById("accountArea").innerHTML = account;
  }
};

//2- connect to smart contract
const accessToContract = async () => {
  const response = await fetch("/build/contracts/Timelock.json");
  const data = await response.json();
  const response2 = await fetch("/build/contracts/AccountManager.json");
  const data2 = await response2.json();
  // const response3 = await fetch("/build/contracts/VoteAdmin.json");
  // const data3 = await response3.json();
  const timelockABI = data.abi;
  const accountManagerABI = data2.abi;
  // const voteAdminABI = data3.abi;
  const timelockAddress = "0x4e0264af0621eAeFbb23d9A677C4B23a2b034ba4";
  const accountManagerAddress =
    "0xF5F37Cf5dcced9b4B651B72AE9fA996318d3366f";

  // const voteAdminAddress =
  //   "0x5e3f514a35B57313E9650936fA096CB64303F2F5";
  window.web3 = await new Web3(window.ethereum); //how to access to smart contract
  timelockContract = await new window.web3.eth.Contract(
    timelockABI,
    timelockAddress
  ); //how you create an instance of that contract by using the abi and address
  accountManagerContract = await new window.web3.eth.Contract(
    accountManagerABI,
    accountManagerAddress
  );

  // voteAdminContract = await new window.web3.eth.Contract(
  //   voteAdminABI,
  //   voteAdminAddress
  // );//how you create an instance of that contract by using the abi and address
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