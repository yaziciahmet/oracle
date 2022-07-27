# ORACLE NODE AND CLIENT

This is a project developed by me for study purposes.

# ORACLE NODE
This is an oracle node for signing messages. Execution flow is as follows:
1. Call to `submitMessageRequest` is made with a message by outside contracts
2. `MessageRequest` event is emitted
3. Oracle node captures the event and signs the message
4. Oracle node calls `fulfillMessageRequest` with signed message
5. Low level call is made to the specified callback function and address

# CLIENT
This is an example client which can interact with the oracle node. Execution flow is as follows:
1. Contract is created to interact with oracle contract
2. `submitMessage` makes a low level call to oracle with a message and a callback function
3. Oracle is done signing and calls `_callback` function
4. `MessageSigned` event is emitted
5. Client node captures the event and decrypts the signed message to check if signature is valid

# CONTRACTS
1. Oracle.sol: 0x6787162cF7473341fD3c566B7fa9b896a12f46A1
2. MessageSigner.sol: 0xA4A0F5b9ab55d4E4392145E60d1681583bd53bf9

# REQUIREMENTS
1. Node.js
2. Yarn: `npm install -g yarn`
3. Vue.cli: `npm install -g @vue/cli`
4. MetaMask installed browser
5. Goerli enabled MetaMask
6. Existing GoerliETH: https://goerlifaucet.com/

# SETUP
Setup of the projects are in their corresponding folders

# TESTING
After setting up and running both oracle and client node, this is an example test flow you can use:
1. Connect your metamask to oracle
2. Start the oracle
3. Connect your metamask to client
4. Enter a message to be signed and submit it
5. Metamask popups from both of them will come up:
    1. Client: Accept transaction
    2. Oracle: Accept sign request
    3. Oracle: Accept transaction
    4. Client: Accept decryption request
