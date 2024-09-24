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

const convertDateToUnixTimestamp = (date) =>{
  Math.floor(new Date(date).getTime() / 1000)

}