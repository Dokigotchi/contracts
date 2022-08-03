const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const { paddedBuffer } = require("./utils");
const wl = require("../data/prodWl.json");

function getProof(addressToMint) {
  const tree = new MerkleTree(wl.map(paddedBuffer), keccak256, { sort: true });
  const leaf = paddedBuffer(addressToMint);
  const proof = tree.getHexProof(leaf);
  console.log(`The proof for ${addressToMint} is ${proof}`);
}

getProof(wl[0]);
