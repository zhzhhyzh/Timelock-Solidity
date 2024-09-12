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
    document.getElementById("address").innerText= account
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
  const timelockAddress = "0xa6116D955A60E3dF784E2326871c703dc5311DF9";
  const accountManagerAddress =
    "0x7ad0C5e4dFA737c481c99C2295b37b9254A9c9c2";
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


const switchAccount = async (index) =>{
    if (window.ethereum !== "undefined") {
        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });
        account = accounts[index];
        console.log("Account Switched")
        document.getElementById("address").innerText= account
        // document.getElementById("accountArea").innerHTML = account;
      }
}

accessToMetamask()
accessToContract()