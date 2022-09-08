const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Final Project", function () {
    let deployer, user, user_2;

    beforeEach(async function () {
        [deployer, user, user_2] = await ethers.getSigners();

        const EtbTokenSolution = await ethers.getContractFactory("ETBToken", deployer);
        this.etbToken = await EtbTokenSolution.deploy(ethers.utils.parseEther("1000"));

        const EtbDex = await ethers.getContractFactory("ETBDex", deployer);
        this.etbDex = await EtbDex.deploy(this.etbToken.address);

        await this.etbDex.setFee(1);
        await this.etbToken.setDexAddress(this.etbDex.address);
        await this.etbToken.approve(this.etbDex.address, ethers.utils.parseEther("1000"));
    });

    describe("ETB Token", function () {
        it("totalSupply should match Initial supply", async function () {
            expect(await this.etbToken.totalSupply()).to.eq(ethers.utils.parseEther("1000"));
        });
        describe("Transfer Function", function () {
            it("Should allow to transfer tokens if enough balance", async function () {
                await this.etbToken.transfer(user.address, ethers.utils.parseEther("100"));
                expect(await this.etbToken.balanceOf(user.address)).to.eq(ethers.utils.parseEther("100"));
            });
            it("Should allow to transfer tokens", async function () {
                await this.etbToken.transfer(user.address, ethers.utils.parseEther("100"));
                expect(await this.etbToken.balanceOf(user.address)).to.eq(ethers.utils.parseEther("100"));
            });
        });
        describe("Approve Function", function () {
            it("Should give allowance when approving", async function () {
                await this.etbToken.approve(user.address, ethers.utils.parseEther("100"));
                expect(await this.etbToken.allowanceOf(deployer.address, user.address)).to.eq(ethers.utils.parseEther("100"));
            });
        });
        describe("TransferFrom Function", function () {
            it("Should allow authorized user to transfer on behalf of another", async function () {
                await this.etbToken.approve(user.address, ethers.utils.parseEther("100"));
                await this.etbToken.connect(user).transferFrom(deployer.address, user_2.address, ethers.utils.parseEther("50"));
                expect(await this.etbToken.balanceOf(user_2.address)).to.eq(ethers.utils.parseEther("50"));
            });
            it("Should not allow an unauthorized user to transfer on behalf of another", async function () {
                await expect(this.etbToken.connect(user).transferFrom(deployer.address, user_2.address, ethers.utils.parseEther("50"))).to.be.revertedWith(
                    "ERC20: amount exceeds allowance"
                );
            });
        });
    });
    describe("EtbDex", function () {
        describe("buyTokens function", function () {
            it("Should allow to buy tokens", async function () {
                await this.etbDex.connect(user).buyTokens({ value: ethers.utils.parseEther("100") });
                expect(await this.etbToken.balanceOf(user.address)).to.eq(ethers.utils.parseEther("99"));
            });
            it("Should revert if not sending eth", async function () {
                await expect(this.etbDex.connect(user).buyTokens()).to.be.revertedWith("Should send ETH to buy tokens");
            });
            it("Should revert if not enough tokens to sell", async function () {
                await expect(this.etbDex.connect(user).buyTokens({ value: ethers.utils.parseEther("2000") })).to.be.revertedWith("Not enough tokens to sell");
            });
        });
    });
});
