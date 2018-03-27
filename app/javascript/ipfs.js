const bs58 = require('bs58');

const [node, fname, method] = process.argv;

if (method == "decode") {
  const hash = process.argv[3];
  let h = bs58.decode(hash).toString('hex');
  console.log(h.substring(0,2))
  console.log(h.substring(2,4))
  console.log(h.substring(4));
} else if (method == "encode") {
  const hashFn = process.argv[3];
  const size = process.argv[4];
  const hex = process.argv[5];

  const buf = new Buffer(hashFn + size + hex, 'hex');
  console.log(bs58.encode(buf));
}