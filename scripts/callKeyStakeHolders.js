const splitAbi = require('../out/Split.sol/Split.json');
const config = require('./config/config.json');
const getKeyStakeHolders = require('./getKeyStakeHolders.js');
const Web3 = require('web3');
const web3 = new Web3(process.env.RINKEBY_RPC_URL);

async function main() {
    const keyStakeHolders = await getKeyStakeHolders.getKeyStakeHolders();
    const split = new web3.eth.Contract(splitAbi.abi, config.SPLIT_ADDRESS);
    const account = web3.eth.accounts.privateKeyToAccount('0x' + process.env.TEST_PRIVATE_KEY);

    web3.eth.accounts.wallet.add(account);
    web3.eth.defaultAccount = account.address;

    const receipt = await split.methods.getKeyStakeHolders(keyStakeHolders).send({from: web3.eth.defaultAccount, gas: 3000000});

    console.log(receipt);
}

main();

