const proposeAdmin = async (address) => {
  try {
    const data = await accountManagerContract.methods
      .proposeAdmin(address)
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .proposeAdmin(address)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    console.log(err)
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const startVoting = async () => {
  try {
    const data = await accountManagerContract.methods
      .startVoting()
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .startVoting()
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {

    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const vote = async (address) => {
  try {
    const data = await accountManagerContract.methods
      .voteForAdmin(address)
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .voteForAdmin(address)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
 
};
const resetVoting = async () => {
  try {
    const data = await accountManagerContract.methods
      .finalizeAdmin()
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .finalizeAdmin()
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
 
};
const getProposed = async () => {
  try {
    const data = await accountManagerContract.methods
      .getProposedAdmins()
      .call({ from: account });
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};
const getCurrentAdmin = async () => {
  try {
    const data = await accountManagerContract.methods
      .getAdmin()
      .call({ from: account });
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};

