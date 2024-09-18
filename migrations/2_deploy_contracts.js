var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");
var VoteAdminContract = artifacts.require("VoteAdmin")

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "";
  let TimelockContractAddress = "";
  let voteAdminContractAddress = "";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;

  });
  if (accManagerContractAddress) await deployer.deploy(VoteAdminContract, accManagerContractAddress).then(({ address }) => {
    console.log(address)
    voteAdminContractAddress = address;

  });
  if (voteAdminContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress, voteAdminContractAddress).then(({ address }) => {
    console.log(address)
    TimelockContractAddress = address;

  });
};
