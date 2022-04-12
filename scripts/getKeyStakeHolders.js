const stakeAbi = require('../out/MockERC20.sol/MockERC20.json');
const config = require('./config/config.json');
const Web3 = require('web3');
const web3 = new Web3(process.env.RINKEBY_RPC_URL);

async function getKeyStakeHolders() {
    
    let stakeHolders = [];
    let keyStakeHolders = [];

    const stake = new web3.eth.Contract(stakeAbi.abi, config.STAKE_ADDRESS);
    const data = await stake.getPastEvents("Transfer", { fromBlock: 0, toBlock: 'latest' });
    const decimals = await stake.methods.decimals().call();
    

    data.forEach(i => {
        stakeHolders.push(i.returnValues.to);
    });
    
    stakeHolders = Array.from(new Set(stakeHolders));

    for (let i = 0; i < stakeHolders.length; i++) {
        const balance = await stake.methods.balanceOf(stakeHolders[i]).call()
            .then(res => {
                if(res * 10 ** -decimals >= 100000) {
                    keyStakeHolders.push(stakeHolders[i]);
                }
            });
    }

    return keyStakeHolders;
}

module.exports = {
    getKeyStakeHolders: getKeyStakeHolders
}