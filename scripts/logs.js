
const listLogs = async () => {
  try {
    const data = await timelockContract.methods
      .listLogs()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const listQueued = async () => {
  try {
    const data = await timelockContract.methods
      .listQueued()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const listExecuted = async () => {
  try {
    const data = await timelockContract.methods
      .listExecuted()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const listFailed = async () => {
  try {
    const data = await timelockContract.methods
      .listFailed()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const listCancelled = async () => {
  try {
    const data = await timelockContract.methods
      .listCancelled()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
// const resetVoting = async () => {
//   const data = await timelockContract.methods
//     .resetVoting()
//     .send({ from: account });
//   console.log(data);
// };

// const vote = async () => {
//   const data = await timelockContract.methods
//     .vote()
//     .send({ from: account });
//   console.log(data);
// };

// const generateErrorMessage = (err) => {
//   const result = String(err).match(/{([^}]+)}/)[1];
//   const json = JSON.parse("{" + result + "}");
//   const decoded = web3.eth.abi.decodeParameter("string", json.data.slice(10));
//   // Output the decoded message
//   return decoded;
// };
