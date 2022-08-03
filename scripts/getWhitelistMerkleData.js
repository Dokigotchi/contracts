const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const { paddedBuffer } = require("./utils");

function getWhitelistMerkleData(whitelist) {
  const tree = new MerkleTree(whitelist.map(paddedBuffer), keccak256, {
    sort: true,
  });

  const root = `0x${tree.getRoot().toString("hex")}`;

  const proofs = {};

  for (const address of whitelist) {
    const leaf = paddedBuffer(address);
    const proof = tree.getHexProof(leaf);
    proofs[address] = proof;
  }

  return {
    root,
    proofs,
  };
}

module.exports = getWhitelistMerkleData;
