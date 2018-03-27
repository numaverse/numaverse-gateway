const bs58 = require('bs58');

module.exports = {
  encode(hash) {
    let h = bs58.decode(hash).toString('hex');
    return h;
  },
  bytes32(hash) {
    return '0x'+this.encode(hash).substring(4);
  }
}