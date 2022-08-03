const { expect } = require("chai");
const hre = require("hardhat");
const ethers = hre.ethers;

const whitelist = require("../data/prodWl.json");
const getWhitelistMerkleData = require("../scripts/getWhitelistMerkleData");

describe("Full whitelist run.", function () {
  it("Minting should work for all whitelist addresses.", async function () {
    let [deployer] = await ethers.getSigners();

    const { root, proofs } = getWhitelistMerkleData(whitelist);

    const Dokigotchi = await ethers.getContractFactory("Dokigotchi");
    const pet = await Dokigotchi.deploy(
      "Pet",
      "PET",
      "https://test.com/",
      ethers.utils.parseEther("0.1"),
      root,
      0,
      0,
      deployer.address,
      ethers.constants.AddressZero,
      ethers.constants.AddressZero
    );

    for ([index, address] of whitelist.entries()) {
      await deployer.sendTransaction({
        to: address,
        value: ethers.utils.parseEther("1.0"),
      });

      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [address],
      });

      const signer = await ethers.getSigner(address);

      const balanceBefore = await pet.balanceOf(address);
      const tx = await pet.connect(signer).whitelistMint(proofs[address], {
        value: ethers.utils.parseEther("0.1"),
      });
      await tx.wait();
      const balanceAfter = await pet.balanceOf(address);

      expect(balanceBefore).to.equal(0);
      expect(balanceAfter).to.equal(1);

      console.log(address, balanceAfter);

      await hre.network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [address],
      });
    }
  });
});
