var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "";
  let TimelockContractAddress = "";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress, 10, 3600, 60).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
