var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0xda4276a2c6848600d231AA0f5aDb11f04a3f6b7D";
  let TimelockContractAddress = "0x655A05eA7a7C64415BA16765D8D47BafCd6cE84B";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
