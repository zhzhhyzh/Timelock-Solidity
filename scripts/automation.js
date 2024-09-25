setInterval(async () => {
  const data = await timelockContract.methods
    .getTxArr()
    .call({ from: account });
    console.log(data)
  for (var i = 0; i < data.length; i++) {
    console.log(data    )
    if (data[i][6]!="0" &&data[i][4]<= Date.now()) execute(data[i][0]);
  }
}, 10000);

setInterval(async () => {
  // Increase time by 1 second
  window.web3 = await new Web3("http://localhost:8545"); //how to access to smart contract
  console.log(web3.currentProvider);
  await web3.currentProvider.send(
    {
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [1],
      id: new Date().getTime(),
    },
    (err, result) => {
      // second call within the callback
      web3.currentProvider.send(
        {
          jsonrpc: "2.0",
          method: "evm_mine",
          params: [],
          id: new Date().getTime(),
        },
        (err, result) => {
          // need to resolve the Promise in the second callback
        //   resolve();
        }
      );
    }
  );

  // Optionally log the new timestamp
  const latestBlock = await web3.eth.getBlock("latest");
  console.log("Latest timestamp", latestBlock.timestamp);

  // Wait for 1 second before the next iteration
  //   await new Promise((resolve) => setTimeout(resolve, interval));
}, 1000);
