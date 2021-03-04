const addr = process.argv[2];
const chainId = process.argv[3];

console.log('0x' + (addr.slice(2) + chainId.padStart(2, '0')).padStart(64, '0'));
