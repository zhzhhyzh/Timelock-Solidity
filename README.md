Download Ganache application, Truffle by npm and Metamask chrome extension
1) Run the Ganache application then reset the server port to 8545, then link the truffle project by selecting the truffle_config.js in the folder
2) Run the truffle command in the project folder:
   >truffle compile
   >truffle migrate --network development
   Copy the contract address and paste it in migrate/2_deploy_contract.js accordingly
   >node server.js
   Connect to 5000 port 
