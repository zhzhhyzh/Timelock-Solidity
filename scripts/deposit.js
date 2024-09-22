const deposit = async (value) => {
  try {
    const data = await accountManagerContract.methods
      .deposit()
      .call({ from: account, value, })
      .then(async () => {
        const data = await accountManagerContract.methods
          .deposit()
          .send({ from: account, value,  });
        alert("Successful");
      });
  } catch (err) {
    console.log(err)
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};


const getMyDeposit = async () => {
  try {
    const data = await accountManagerContract.methods
      .getMyDeposit()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const getAccountDeposit = async (_user) => {
  try {
    const data = await accountManagerContract.methods
      .adminGetAccountDeposit(_user)
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const withdraw = async (value) => {
  try {
    const data = await accountManagerContract.methods
      .withdraw(value)
      .call({ from: account,  })
      .then(async () => {
        const data = await accountManagerContract.methods
        .withdraw(value)
        .send({ from: account,   });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};