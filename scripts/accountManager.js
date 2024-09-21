const createAccount = async (address, name, email) => {
  try {
    const data = await accountManagerContract.methods
      .createAccount(address, name, email)
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .createAccount(address, name, email)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const getAccountCount = async () => {
  const data = await accountManagerContract.methods.getAccountCount().call();

  console.log(data, "HERE");
};
const getAccountDetails = async (address) => {
  try {
    const data = await accountManagerContract.methods
      .getAccountDetails(address)
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const purgeAccount = async (_user) => {
  try {
    const data = await accountManagerContract.methods
      .purgeAccount(_user)
      .call({ from: account })
      .then(async () => {
        const data = await accountManagerContract.methods
          .purgeAccount(_user)
          .send({ from: account });
        alert("Successful");
      });
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
};
const listAccounts = async (_user) => {
  try {
    const data = await accountManagerContract.methods
      .getAllAccounts()
      .call({ from: account });
    console.log(data);
    return data;
  } catch (err) {
    alert(generateErrorMessage(err));
    // // Decode the revert reason (skipping the first 4 bytes)
  }
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
