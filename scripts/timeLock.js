
const queue = async (address, _value, _func, _data, _timestamp) => {
  const data = await timelockContract.methods
    .queue(
      address, _value, _func, _data, _timestamp
    )
    .send({ from: account });
  console.log(data);
};

const purposeGracePeriod = async (_newGracePeriod) => {
  const data = await timelockContract.methods
    .purposeGracePeriod(
      _newGracePeriod
    )
    .send({ from: account });
  console.log(data);
};

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
const resetVoting = async () => {
  const data = await timelockContract.methods
    .resetVoting()
    .send({ from: account });
  console.log(data);
};

const vote = async () => {
  const data = await timelockContract.methods
    .vote()
    .send({ from: account });
  console.log(data);
};

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

//     //3-read data from smart contract
//     const readfromContract = async () => {
//         const data = await window.contract.methods.getInitialProduct().call();
//     document.getElementById("ownerProduct").innerHTML = `Owner Product information:<br> Product Name: ${data[0]},<br> Price(wei): ${data[1]} <br>Owner Address: ${data[2]}`;
//         document.getElementById("dataArea0").innerHTML = data[0];
//         document.getElementById("dataArea1").innerHTML = data[1];
//         document.getElementById("dataArea2").innerHTML = data[2];
//     }

// //4- buyer buy the product, transfer wei, update the ownership
// const BuyerBuyProduct = async () =>{
// 	//need to retrieve product data from the contract
// 	const data = await window.contract.methods.getInitialProduct().call();
// 	const price = data[1];
// 	const ownerAddress = data[2];
// 	await window.contract.methods.buyProduct(ownerAddress).send({from: account, value:price });
// }

// //5- set new product- product name and price, owner address
//      const setNewProduct = async () => {
//       const ProductName = document.getElementById("Pname").value;
//       const ProductPrice = document.getElementById("Pprice").value;
//       await window.contract.methods.setProduct(ProductName, ProductPrice).send({from: account });
// 	  document.getElementById("Pname").value = "";
// 	  document.getElementById("Pprice").value= "";
//     }