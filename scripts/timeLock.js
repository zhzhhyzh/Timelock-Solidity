const queue = async (address, _value, date) => {
  try {
    const data = await timelockContract.methods
      .queue(address, String(_value), String(date))
      .call({ from: account })
      .then(async () => {
        const data = await timelockContract.methods
          .queue(address,String( _value), String(date))
          .send({ from: account })

          .then((res)=>{
            document.forms[0].txId.value = res.events.Queue.returnValues[0];
            alert("Successful");
          })
      });
  } catch (err) {
    console.log(err)
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};

// const proposeGracePeriod = async (_newGracePeriod) => {
//   const data = await timelockContract.methods
//     .proposeGracePeriod(
//       _newGracePeriod
//     )
//     .send({ from: account });
//   console.log(data);
// };

const execute = async (_txid, _address) => {
  try {
    
    console.log(_txid)
    const data = await timelockContract.methods
      .execute(_txid)
      .call({ from: _address })
      .then(async () => {
        const data = await timelockContract.methods
          .execute(_txid)
          .send({ from: _address });

        alert("Successful");
      });

      console.log(data)

  } catch (err) {
    console.log(err)
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};

const cancel = async (_txid) => {
  try {
    const data = await timelockContract.methods
      .cancel(_txid)
      .call({ from: account })
      .then(async () => {
        const data = await timelockContract.methods
          .cancel(_txid)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    console.log(err)
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }

};

const getTx = async (_txId) => {
  try {
    const data = await timelockContract.methods
      .getTx(_txId)
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};

const getTxId = async (address, _value) => {
  try {
    const data = await timelockContract.methods
      .getTxId(address, _value)
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    console.log(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const getTxArr = async () => {
  try {
    const data = await timelockContract.methods
      .getTxArr()
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
