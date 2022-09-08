const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Pool", function () {
    let owner, user, user_2, user_3, user_4;

    beforeEach(async function () {
        [owner, user, user_2, user_3, user_4] = await ethers.getSigners();

        const ERC20Mock = await ethers.getContractFactory("ERC20Mock", owner);
        this.stablecoin = await ERC20Mock.deploy("stablecoin", "DAI", owner.address, 10000);

        const CPERC1155 = await ethers.getContractFactory("CPERC1155", owner);
        this.cPERC1155 = await CPERC1155.deploy(["QmZZJ9vivyDtmZcpjVhmQdA2kUvjDVpidvSWn3U2FE49p7", "QmS6WUYi2dxyMDkZ5G9yF6YiXbwpZbZV3u5T8Z2LG5bB5V"]);

        const ResultOracle = await ethers.getContractFactory("ResultOracle", owner);
        this.resultOracle = await ResultOracle.deploy([user_3.address, user.address, user_2.address]);

        const Pool = await ethers.getContractFactory("Pool", owner);
        this.pool = await Pool.deploy(this.stablecoin.address, this.cPERC1155.address, this.resultOracle.address);

        await this.stablecoin.mint(this.pool.address, 1000);
    });

    describe("buyNFT() Function", function () {
        it("Should revert when trying to buy nft with 0 DAI", async function () {
            await expect(this.pool.connect(user).buyRandomNFT()).to.be.reverted;
        });

        it("Should revert when trying to buy nft with 50 DAI without whitelist", async function () {
            await this.stablecoin.transfer(user.address, 50);

            await this.stablecoin.connect(user).increaseAllowance(this.pool.address, 50);

            await this.pool.connect(user).buyRandomNFT();

            expect(50).to.eq(await this.pool.totalPrize());
        });
    });
});

