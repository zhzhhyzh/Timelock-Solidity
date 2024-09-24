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
  return Math.floor(new Date(date).getTime() / 1000)

}

function unixToDateTime(unixTimestamp) {
    // Create a new JavaScript Date object based on the Unix timestamp (in milliseconds)
    const date = new Date(unixTimestamp * 1000); // Multiply by 1000 to convert seconds to milliseconds

    // Extract date and time components
    const year = date.getFullYear();
    const month = ("0" + (date.getMonth() + 1)).slice(-2); // Months are zero-indexed
    const day = ("0" + date.getDate()).slice(-2);
    const hours = ("0" + date.getHours()).slice(-2);
    const minutes = ("0" + date.getMinutes()).slice(-2);
    const seconds = ("0" + date.getSeconds()).slice(-2);

    // Return the formatted date and time
    return `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
}
function getStatus(index) {
  index  = parseInt(index)
   switch(index){
    case 0:
      return "Queued";
    case 1:
      return "Completed";
    case 2:
      return "Cancelled";
    case 3:
      return "Failed";
   }
}