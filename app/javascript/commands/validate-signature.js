const utils = require('ethereumjs-util');

const message = utils.hashPersonalMessage(utils.toBuffer('numa'));

const sgn = process.argv[2];

const r = utils.toBuffer(sgn.slice(0, 66));
const s = utils.toBuffer('0x' + sgn.slice(66, 130));
const v = utils.bufferToInt(utils.toBuffer('0x' + sgn.slice(130, 132)));
const pub = utils.ecrecover(message, v, r, s);
const addr = utils.pubToAddress(pub);

console.log(utils.bufferToHex(addr));