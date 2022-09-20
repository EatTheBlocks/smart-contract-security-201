const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Result Oracle", function () {
    let owner, user, user_2, user_3, user_4;

    beforeEach(async function () {
        [owner, user, user_2, user_3, user_4] = await ethers.getSigners();

        const ResultOracle = await ethers.getContractFactory("ResultOracle", owner);
        this.resultOracle = await ResultOracle.deploy([user_3.address, user.address, user_2.address]);
    });

    describe("constructor() Function", function () {
        it("Should revert when trying to set the owner as judge in first position", async function () {
            const ResultOracle1 = await ethers.getContractFactory("ResultOracle", owner);

            await expect(ResultOracle1.deploy([owner.address, user.address, user_2.address])).to.be.revertedWith("The owner can't be a judge.");
        });

        it("Should revert when trying to set the owner as judge in third position", async function () {
            const ResultOracle1 = await ethers.getContractFactory("ResultOracle", owner);

            await expect(ResultOracle1.deploy([user.address, user_2.address, owner.address])).to.be.revertedWith("The owner can't be a judge.");
        });

        it("Should revert when trying to set more than 3 addresses as judges", async function () {
            const ResultOracle1 = await ethers.getContractFactory("ResultOracle", owner);

            await expect(ResultOracle1.deploy([user.address, user_2.address, user_3.address, owner.address])).to.be.revertedWith("You must set 3 judges.");
        });

        it("Should revert when trying to set address zero as a judge", async function () {
            const ResultOracle1 = await ethers.getContractFactory("ResultOracle", owner);

            await expect(ResultOracle1.deploy([user.address, user_2.address, ethers.constants.AddressZero])).to.be.revertedWith("Address zero can't be a judge.");
        });

        it("Should revert when trying to set the same address as judge", async function () {
            const ResultOracle1 = await ethers.getContractFactory("ResultOracle", owner);

            await expect(ResultOracle1.deploy([user.address, user_2.address, user_2.address])).to.be.revertedWith("You can't set the same address twice as a judge.");
        });

        it("Should ensure getJudge() function returns addresses with the same order as saved in the constructor", async function () {
            expect(user_3.address).to.eq(await this.resultOracle.getJudge(0));
            expect(user.address).to.eq(await this.resultOracle.getJudge(1));
            expect(user_2.address).to.eq(await this.resultOracle.getJudge(2));
        });
    });

    describe("setNewJudge() Function", function () {
        it("Should set a correct index for a new judge", async function () {
            await this.resultOracle.setNewJudge(0, user_4.address);

            expect(user_4.address).to.eq(await this.resultOracle.getJudge(0));
        });

        it("Should ensure only the owner can set a new judge", async function () {
            await expect(this.resultOracle.connect(user).setNewJudge(0, user_2.address)).to.be.revertedWith(
                "Ownable: caller is not the owner");
        });

        it("Should revert when trying to set again an existing judge", async function () {
            await expect(this.resultOracle.setNewJudge(0, user_2.address)).to.be.revertedWith(
                "You can't set the same address twice as a judge.");
        });

        it("Should revert when trying to set the owner as judge", async function () {
            await expect(this.resultOracle.setNewJudge(0, owner.address)).to.be.revertedWith(
                "The owner can't be a judge.");
        });

        it("Should revert when trying to set address(0) as judge", async function () {
            await expect(this.resultOracle.setNewJudge(0, ethers.constants.AddressZero)).to.be.revertedWith(
                "Address zero can't be a judge.");
        });

    });

    describe("getRoundResult() Function", function () {
        it("Should revert when there is no result", async function () {
            await expect(this.resultOracle.getRoundResult()).to.be.revertedWith(
                "There is no result yet.");
        });

        it("Should return the same result that everyone voted", async function () {
            var vote = ethers.BigNumber.from("11110011");

            await this.resultOracle.connect(user).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);

            await this.resultOracle.setRoundResult(vote);

            expect(vote).to.eq(await this.resultOracle.connect(user).getRoundResult());

        });
    });

    describe("addJudgeDebateToRound() Function", function () {
        it("Should revert when trying to add debate with an incorrect vote", async function () {
            await expect(this.resultOracle.connect(user_2).addJudgeDebateToRound(ethers.BigNumber.from("11122211"))).to.be.revertedWith(
                "Incorrect vote.");
        });

        it("Should revert when trying to add a debate with a non judge", async function () {
            await expect(this.resultOracle.connect(user_4).addJudgeDebateToRound(111)).to.be.revertedWith(
                "Is not a judge.");
        });

        it("Should set correct debate when set with correct data", async function () {
            var vote = ethers.BigNumber.from("10011001");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user).addJudgeDebateToRound(vote);

            await this.resultOracle.setRoundResult(vote);

            expect(vote).to.eq(await this.resultOracle.connect(user).getRoundResult());
        });

        it("Should set correct debate when set with zero", async function () {
            var vote = ethers.BigNumber.from("0");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user).addJudgeDebateToRound(vote);

            await this.resultOracle.setRoundResult(vote);

            expect(vote).to.eq(await this.resultOracle.connect(user).getRoundResult());
        });
    });

    describe("setRoundResult() Function", function () {
        it("Should revert when trying to set a result with an incorrect vote", async function () {
            await expect(this.resultOracle.setRoundResult(ethers.BigNumber.from("1101111001"))).to.be.revertedWith(
                "Incorrect vote.");
        });

        it("Should revert when trying to set a result from a not owner address", async function () {
            await expect(this.resultOracle.connect(user).setRoundResult(ethers.BigNumber.from("110101"))).to.be.revertedWith(
                "Ownable: caller is not the owner");
        });

        it("Should revert when trying to set a result but there are no debates", async function () {
            await expect(this.resultOracle.setRoundResult(ethers.BigNumber.from("110101"))).to.be.revertedWith(
                "The judges did not upload round results.");
        });

        it("Should revert when trying to set a result but there are not enough debates", async function () {
            var vote = ethers.BigNumber.from("1100111");

            this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await expect(this.resultOracle.setRoundResult(vote)).to.be.revertedWith(
                "The judges did not upload round results.");
        });

        // hasta aca
        it("Should return false if there is not match between 3 judges or more", async function () {
            var vote = ethers.BigNumber.from("1100111");
            var vote1 = ethers.BigNumber.from("11111");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote1);

            const result = await this.resultOracle.setRoundResult(vote);
            expect(false).to.eq(result);
        });

        it("Should return true if there is a match between 3 judges", async function () {
            var vote = ethers.BigNumber.from("1100111");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user).addJudgeDebateToRound(vote);

            expect(true).to.eq(await this.resultOracle.setRoundResult(vote));
        });

        it("Should return true if there is a match between only 2 judges", async function () {
            var vote = ethers.BigNumber.from("1100111");
            var vote1 = ethers.BigNumber.from("11111");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote);
            await this.resultOracle.connect(user).addJudgeDebateToRound(vote1);

            expect(true).to.eq(await this.resultOracle.setRoundResult(vote));
        });

        it("Should return false if there is no match between 2 judges", async function () {
            var vote = ethers.BigNumber.from("1100111");
            var vote1 = ethers.BigNumber.from("1111111");
            var vote2 = ethers.BigNumber.from("1100011");

            await this.resultOracle.connect(user_3).addJudgeDebateToRound(vote2);
            await this.resultOracle.connect(user_2).addJudgeDebateToRound(vote1);
            await this.resultOracle.connect(user).addJudgeDebateToRound(vote);

            expect(false).to.eq(await this.resultOracle.setRoundResult(vote));
        });
    });
});