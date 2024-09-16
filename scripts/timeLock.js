
const queue = async (address, _value, _func, _data, _timestamp) => {
  const data = await timelockContract.methods
    .queue(
      address, _value, _func, _data, _timestamp
    )
    .send({ from: account });
  console.log(data);
};

// const proposeGracePeriod = async (_newGracePeriod) => {
//   const data = await timelockContract.methods
//     .proposeGracePeriod(
//       _newGracePeriod
//     )
//     .send({ from: account });
//   console.log(data);
// };

const execute = async (_txid) => {
  const data = await timelockContract.methods
    .execute(
      _txid
    )
    .send({ from: account });
  console.log(data);
};

const cancel = async (_txid) => {
  const data = await timelockContract.methods
    .cancel(
      _txid
    )
    .send({ from: account });
  console.log(data);
};

const getTx = async (_txId) => {
  try {
    const data = await timelockContract.methods
      .getTx(_txId)
      .call({ from: account });
    console.log(data)
    return data
  } catch (err) {
    console.log(generateErrorMessage(err))
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};

const getTxId = async (address, _value, _func, _data, _timestamp) => {
  try {
    const data = await timelockContract.methods
      .getTxId(address, _value, _func, _data, _timestamp)
      .call({ from: account });
    console.log(data)
    return data
  } catch (err) {
    console.log(generateErrorMessage(err))
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

const generateErrorMessage = (err) => {
  const result = String(err).match(/{([^}]+)}/)[1];
  const json = JSON.parse("{" + result + "}");
  const decoded = web3.eth.abi.decodeParameter(
    "string",
    json.data.slice(10)
  );
  // Output the decoded message
  return decoded
};

