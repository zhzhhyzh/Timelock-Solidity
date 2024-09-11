
const proposeGracePeriod = async (_newGracePeriod) => {
    const data = await timelockContract.methods
      .proposeGracePeriod(
        _newGracePeriod
      )
      .send({ from: account });
    console.log(data);
  };
const vote = async () => {
    const data = await timelockContract.methods
      .vote(
      )
      .send({ from: account });
    console.log(data);
  };
const resetVoting = async () => {
    const data = await timelockContract.methods
      .resetVoting(
      )
      .send({ from: account });
    console.log(data);
  };
