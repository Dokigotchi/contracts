function paddedBuffer(addr) {
  const normalizedAddress = addr
    .replace(/^0x/gi, "")
    .replace(/[^a-f0-9]/gi, ""); // strip any non-hex characters

  if (normalizedAddress.length !== 40)
    throw new Error("Invalid address: " + addr);

  const buf = Buffer.alloc(32);
  Buffer.from(normalizedAddress, "hex").copy(buf, 32 - 20, 0, 20);

  return buf;
}

module.exports = {
  paddedBuffer,
};
