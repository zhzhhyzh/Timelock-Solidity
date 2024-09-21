var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0x26aa06e10a8e1d6e5dd7dc20faab2be85b888e8a52df63c3e77bef3b75ca8cdf";
  let TimelockContractAddress = "0x51f34b3d1dbc0a6ac1a0d2df96dae5bc6a62edb944b4ee2fb96591c5adef3c4e";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress, 10, 3600, 60).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
