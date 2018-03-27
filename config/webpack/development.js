const environment = require('./environment')
require('babel-polyfill');
console.log(environment.toWebpackConfig().entry);

module.exports = environment.toWebpackConfig()
