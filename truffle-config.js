/**
 * Truffle Config for Kooopa Racing league smart contracts!
 * 
 */

// const HDWalletProvider = require('@truffle/hdwallet-provider');
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
let web3 = require('web3');

let {nom , main} = require('./config.json');
const HDWalletProvider = require("@truffle/hdwallet-provider");

let _acc = 4;
let wallet = new HDWalletProvider(nom, main, _acc);

// let { ethers } = require('ethers');
// let _infura = new ethers.providers.JsonRpcProvider(config.main);
// let _wallet = new ethers.Wallet(config.key, _infura);

module.exports = {
  networks: {
    dev: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // match any network
      // websockets: true,
      // gas:  523088900,
      // gasPrice: 60
    },
    
    live: {
      // from: "0xc13C5f4C8853D5Fb39A184Cf0e71CEADF1fb474e",
      // gasPrice: web3.utils.toWei('80', 'gwei'),
      provider: wallet,
      network_id: 1,   // This network is yours, in the cloud.
      production: true,    // Treats this network as if it was a public net. (default: false)
      skipDryRun: true
    },
    
    matic: {
      // from: "0xc13C5f4C8853D5Fb39A184Cf0e71CEADF1fb474e",
      provider: wallet,
      network_id: 137,   // This network is yours, in the cloud.
      production: true,    // Treats this network as if it was a public net. (default: false)
      skipDryRun: true,
      // gasPrice: web3.utils.toWei('80', 'gwei')
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.2",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: false,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
       evmVersion: "berlin"
      }
    }
  }
};
