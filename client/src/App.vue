<template>
  <div id="app">
    <div v-if="walletConnected">
      <h3>Enter Message To Sign:</h3>
      <input type="text" v-model="msg">
      <button @click="submitMessage">Submit</button>
      <h5 v-if="msgSubmitted">Message is submitted, waiting for a response...</h5>
      <h5 v-if="signedMsg !== ''">Signed Message: {{ signedMsg }}</h5>
    </div>
    <div v-else>
      <h3>You Need To Connect Your Metamask</h3>
      <button @click="connectMetamask">Connect Metamask</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import contractAbi from './abi/MessageSigner_abi.json'

const ethereum = window.ethereum
const contractAddress = '0x9c07180E0A073BF01a28992594C1B35259b21047';
const web3 = new Web3("wss://goerli.infura.io/ws/v3/f27c3d5982f54337a9795d5bc0b8d5d8")
const contractInstance = new web3.eth.Contract(
  contractAbi, 
  contractAddress
)

export default {
  name: 'App',
  data() {
    return {
      msg: '',
      signedMsg: '',
      walletConnected: false,
      msgSubmitted: false,
      account: null,
    }
  },
  methods: {
    async submitMessage() {
      const encodedData = await this.getEncodedData()
      const transactionParams = {
        nonce: '0x00', 
        gasPrice: '0x00004e72a000', 
        gas: '0x10000', 
        to: contractAddress, 
        from: this.account, 
        data: encodedData,
        chainId: '0x5'
      }

      await ethereum.request({
        method: 'eth_sendTransaction',
        params: [transactionParams]
      })

      this.msgSubmitted = true
      this.startListeningForSignedMessage()
    },
    startListeningForSignedMessage() {
      const subscription = contractInstance.events.MessageSigned({})
        .on('data', e => {
          this.signedMsg = e.returnValues.message
          this.msgSubmitted = false
          subscription.unsubscribe()
        }
      )
    },
    async connectMetamask() {
      if (typeof ethereum !== undefined) {
        if (ethereum.chainId !== '0x5') {
          await ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: '0x5' }]
          })
        }

        const accounts = await ethereum.request({method: 'eth_requestAccounts'})
        this.account = accounts[0]
        this.walletConnected = true
      }
    },
    getEncodedData() {
      const call = web3.eth.abi.encodeFunctionCall({
        name: 'submitMessage',
        type: 'function',
        inputs: [{
            type: 'string',
            name: '_msg'
        }]
      }, [this.msg]);

      return call
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
