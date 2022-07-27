<template>
  <div id="app">
    <div v-if="walletConnected">
      <div v-if="!started">
        <h3>Start Oracle Node</h3>
        <button @click="startListening">Start</button>
      </div>
      <div v-else>
        <h3>Running Oracle Node...</h3>
        <button @click="stopListening">Stop</button>
        <h5 v-for="msg, i in msgs" :key="i">
          Received a message sign request: {{ msg.message }}
          <h5 v-if="i < signedMsgs.length" style="overflow-wrap:break-word">
            Signed the message: {{ signedMsgs[i] }}
          </h5>
        </h5>
      </div>
    </div>
    <div v-else>
      <h3>You Need To Connect Your Metamask</h3>
      <button @click="connectMetamask">Connect Metamask</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import contractAbi from './abi/Oracle_abi.json'
import { encrypt } from 'eth-sig-util'

const ethereum = window.ethereum
const contractAddress = '0x6787162cF7473341fD3c566B7fa9b896a12f46A1';
const web3 = new Web3(ethereum)
const contractInstance = new web3.eth.Contract(
  contractAbi, 
  contractAddress
)

export default {
  name: 'App',
  data() {
    return {
      msgs: [],
      signedMsgs: [],
      walletConnected: false,
      started: false,
      account: null,
      subscription: null,
    }
  },
  methods: {
    startListening() {
      this.subscription = contractInstance.events.MessageRequest({})
        .on('data', this.handleMessageRequest)
      this.started = true;
    },
    stopListening() {
      this.subscription.unsubscribe()
      this.started = false
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
    async handleMessageRequest(e) {
      const retValues = e.returnValues
      this.msgs.push({ id: retValues.id, message: retValues.message })

      let signedMsg = await this.signMessage(retValues.message)

      const encodedData = this.getEncodedData(retValues, signedMsg)
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

      this.signedMsgs.push(signedMsg)
    },
    async signMessage(msg) {
      const encryptKey = await ethereum.request({
        method: 'eth_getEncryptionPublicKey',
        params: [this.account],
      })

      const encryptMsg = encrypt(
        encryptKey,
        { data: msg },
        'x25519-xsalsa20-poly1305',
      )

      const signedMsg = web3.utils.stringToHex(JSON.stringify(encryptMsg))

      return signedMsg
    },
    getEncodedData(retValues, signedMsg) {
      const call = web3.eth.abi.encodeFunctionCall({
        name: 'fulfillMessageRequest',
        type: 'function',
        inputs: [
          {
              type: 'uint256',
              name: '_id'
          },
          {
              type: 'string',
              name: '_signedMsg'
          },
          {
              type: 'address',
              name: '_callbackAddress'
          },
          {
              type: 'string',
              name: '_callbackFunction'
          },
        ]
      }, [retValues.id, signedMsg, retValues.callbackAddress, retValues.callbackFunction]);

      return call
    },
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
