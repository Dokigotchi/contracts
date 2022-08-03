const whitelist = require("../data/wl.json");
const getWhitelistMerkleData = require("../scripts/getWhitelistMerkleData");

(() =>{
  const { root } = getWhitelistMerkleData(whitelist);
  console.log(root)
})()
