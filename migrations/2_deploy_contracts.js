var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0x43bF796AA1f21996783418b9725A0EeB2523A7B1";
  let TimelockContractAddress = "0x89dD744E9fe90286c4936100fc073b302a4cDCC2";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress, 10, 3600, 60).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
