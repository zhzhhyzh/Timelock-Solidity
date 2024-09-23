var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0xec6D086866e3A898838d0C670A48400A78F1AAD2";
  let TimelockContractAddress = "0xdE3b63fe9750c351e2998fD1aFe3E412757CE1C3";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress, 10, 3600, 60).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
