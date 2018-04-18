require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*", // Match any network id
            gas: 4000000,
            // gasPrice: 65000000000,
            solc: {
                optimizer: {
                  enabled: true,
                  runs: 0
                }
            },
        },
    }
};
