//1- connect metamask
let account;
//   import TimelockContract from "./build/contracts/Timelock.json";
//   import AccountManagerContract from "./build/contracts/AccountManager.json";
let timelockContract;
let accountManagerContract;
let voteAdminContract;
let totalAccounts = 0;

const accessToMetamask = async () => {
  if (window.ethereum !== "undefined") {
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    totalAccounts = accounts.length;
    account = accounts[0];
    document.getElementById("accounts").innerHTML = `
    <p id="address"></p>
    ${
      accounts.map((account,i)=>
      `
         <a href="#" onclick="switchAccount(${i})" class="avatars__item"
        ><img
          class="avatar"
          src="https://randomuser.me/api/portraits/men/${i}.jpg"
          alt=""
      /></a>  
      `)
    }
    `
 
    document.getElementById("address").innerHTML = account;
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
  const timelockAddress = data.networks["5777"].address;
  const accountManagerAddress = data2.networks["5777"].address;

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
  console.log("connected to smart contract");
  const admin = await accountManagerContract.methods
  .getAdmin()
  .call({ from: account });

  document.getElementById("address").innerText = account +( account.toLowerCase()==admin.toLowerCase()?" (Admin)":"");

};

const switchAccount = async (index) => {
  if (window.ethereum !== "undefined") {
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    account = accounts[index];
    console.log("Account Switched");
    const admin = await accountManagerContract.methods
    .getAdmin()
    .call({ from: account });

    console.log(admin)

    document.getElementById("address").innerText = account +( account.toLowerCase()==admin.toLowerCase()?" (Admin)":"");
    // document.getElementById("accountArea").innerHTML = account;
  }
};

accessToMetamask();
accessToContract();
