const ethers = require('ethers')
const fs = require('fs')

const wl = require('../data/wl.json')

const normalizedWl = wl.map((address) => ethers.utils.getAddress(address))
const uniqueWl = [...new Set(normalizedWl)]

fs.writeFileSync('data/prodWl.json', JSON.stringify(uniqueWl))
