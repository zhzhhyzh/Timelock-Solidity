var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "0xC417333eFFb799A5e545C66DFD9c2fFC10877287";
  let TimelockContractAddress = "0x7F3961ed7d1571047e6bd09e4256B2B6075Ce095";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
  
};
