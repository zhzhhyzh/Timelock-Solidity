const proposeGracePeriod = async (_newGracePeriod) => {
  try {
    const data = await timelockContract.methods
      .startVoting(_newGracePeriod)
      .call({ from: account })
      .then(async () => {
        const data = await timelockContract.methods
          .startVoting(_newGracePeriod)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {

    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const vote = async () => {
  try {
    const data = await timelockContract.methods
      .voteGracePeriod()
      .call({ from: account })
      .then(async () => {
        const data = await timelockContract.methods
          .voteGracePeriod()
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
    const data = await timelockContract.methods
      .finalizeVote()
      .call({ from: account })
      .then(async () => {
        const data = await timelockContract.methods
          .finalizeVote()
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
 
};
const getProposedGracePeriod = async () => {
  try {
    const data = await timelockContract.methods
      .getProposedGracePeriod()
      .call({ from: account });
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};
const getCurrentGracePeriod = async () => {
  try {
    const data = await timelockContract.methods
      .getCurrentGracePeriod()
      .call({ from: account });
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};

