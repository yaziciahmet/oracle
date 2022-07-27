<template>
  <div id="app">
    <div v-if="walletConnected">
      <h3>Enter Message To Sign:</h3>
      <input type="text" v-model="msg">
      <button @click="submitMessage">Submit</button>
      <h5 v-if="state=='submitted'">Message is submitted, waiting for a response...</h5>
      <h5 v-if="state=='received'" style="overflow-wrap:break-word">Signed Message: {{ signedMsg }}</h5>
      <h5 v-if="state=='received' && validSign">Signed message matches with original message</h5>
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
const contractAddress = '0xA4A0F5b9ab55d4E4392145E60d1681583bd53bf9';
const web3 = new Web3(ethereum)
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
      state: '',
      account: null,
      validSign: false
    }
  },
  methods: {
    async submitMessage() {
      const encodedData = this.getEncodedData()
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

      this.state = 'submitted'
      this.startListeningForSignedMessage()
    },
    startListeningForSignedMessage() {
      const subscription = contractInstance.events.MessageSigned({})
        .on('data', async (e) => {
          this.signedMsg = e.returnValues.message
          const originalMsg = await ethereum.request({
            method: 'eth_decrypt',
            params: [this.signedMsg, this.account],
          });
          this.validSign = originalMsg === this.msg ? true : false
          this.state = 'received'
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
