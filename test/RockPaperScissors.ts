import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect, assert } from "chai";
import { ethers } from "hardhat";

describe('RockPaperScissors', function() {
  async function deployRockPaperScissorsFixture() {
    const accounts = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("RockPaperScissors");
    const contract = await Contract.deploy();
    await contract.deployed();
    
    async function findEvent(transaction: any, evt: any) {
      console.log(transaction);
      const logs = (await transaction.wait()).logs.map((x: any) => Contract.interface.parseLog(x));
      const event = logs.find(({ eventFragment }: any) => eventFragment?.name === evt);
      if (!event) throw new Error(`Remember to call ${evt} event!`);
      return event.args;
    }

    return { accounts, contract, findEvent }; 
  }
  
  describe('createGame', function() {
    it("should let us create a game", async function() {
      const { accounts, contract, findEvent } = await loadFixture(deployRockPaperScissorsFixture);
      const bet = 1000;
      const transaction = await contract.createGame(accounts[1].address, { value: bet });
      const gameCreatedEvent = await findEvent(transaction, 'GameCreated');
      assert.equal(gameCreatedEvent.creator, accounts[0].address, `GameCreated Event should include the creators address ${accounts[0].address}`);
      assert(gameCreatedEvent.gameNumber, `GameCreated Event should include a game number for us to refer to`);
      assert.equal(gameCreatedEvent.bet, bet, `GameCreated Event should include the bet size`);
    });
  });

  describe('joinGame', function() {
    it("should let us join a game for a valid participant", async function() {
      const { accounts, contract, findEvent } = await loadFixture(deployRockPaperScissorsFixture);
      const bet = 1000;
      const createGame = await contract.createGame(accounts[1].address, { value: bet });
      const game = (await findEvent(createGame, 'GameCreated')).gameNumber;
      const joinGame = await contract.connect(accounts[1]).joinGame(game, { value: bet });
      const players = (await findEvent(joinGame, 'GameStarted')).players;
      assert.isAbove(players.indexOf(accounts[0].address), -1, `Could not find ${accounts[0].address} in players array on the Game Started Event`);
      assert.isAbove(players.indexOf(accounts[1].address), -1, `Could not find ${accounts[1].address} in players array on the Game Started Event`);
    });
  });

  describe('makeMove', function() {
    it("should detect a winner", async function() {
      const { accounts, contract, findEvent } = await loadFixture(deployRockPaperScissorsFixture);
      const createGame = await contract.createGame(accounts[1].address, { value: 1000 });
      const game = (await findEvent(createGame, 'GameCreated')).gameNumber;
      await contract.connect(accounts[1]).joinGame(game, { value: 1000 });
      await contract.connect(accounts[0]).makeMove(game, 1); // rock
      const transaction = await contract.connect(accounts[1]).makeMove(game, 2); // paper
      const winner = (await findEvent(transaction, 'GameComplete')).winner;
      assert.equal(winner, accounts[1].address, `Expected the winner to be ${accounts[1].address} (paper covers rock)`);
    });
  });
});