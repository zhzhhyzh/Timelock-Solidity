var TimelockContract = artifacts.require("Timelock");
var AccountManagerContract = artifacts.require("AccountManager");

module.exports = async function (deployer) {
  // deployment steps

  let accManagerContractAddress = "";
  await deployer.deploy(AccountManagerContract).then(({ address }) => {
    console.log(address)
    accManagerContractAddress = address;
    // console.log(address);
    // .then(({address:address2})=>console.log(address2))
    // console.log("RANN")
    //   .then(({address:address2}) =>
    //     console.log(address2)
    // )
  });
  if (accManagerContractAddress) await deployer.deploy(TimelockContract, accManagerContractAddress);
};
