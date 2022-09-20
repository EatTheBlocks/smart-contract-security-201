const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GasUsage", function () {
  it("Partitions Percentage", async function () {
    const GasUsage = await ethers.getContractFactory("GasUsage");
    const gu = await GasUsage.deploy();
    await gu.deployed();

    const [_, signer] = await ethers.getSigners()

    await gu.connect(signer).splitAmountToOwnerAndSeller(100)
    await gu.connect(signer).splitAmountToOwnerAndSellerV2(100)

    
  });
});