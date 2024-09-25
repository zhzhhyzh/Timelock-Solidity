var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0x1ff6A8318AB98E6947CcDEfed0b706271C122F65";
  let TimelockContractAddress = "0x2B5401603f0E87c81Bc1fa1CED83D11Fd84f0a8A";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
