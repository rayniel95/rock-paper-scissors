// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.0;

contract RockPaperScissors {
  event GameCreated(address creator, uint gameNumber, uint bet);
  event GameStarted(address[] players, uint gameNumber);
  event GameComplete(address winner, uint gameNumber);
  
  struct Game {
    address[2] players;
    uint bet;
    uint move;
  }
  Game[] internal games;
  /**
   * Use this endpoint to create a game. 
   * It is a payable endpoint meaning the creator of the game will send ether directly to it.
   * The ether sent to the contract should be used as the bet for the game.
   * @param participant {address} - The address of the participant allowed to join the game.
   */
  function createGame(address payable participant) public payable {
    require(msg.value > 0, "The bet must be a positive value");
    games.push(Game([msg.sender, participant], msg.value, 0));
    emit GameCreated(msg.sender, games.length, msg.value);
  }
  
  /**
   * Use this endpoint to join a game.
   * It is a payable endpoint meaning the joining participant will send ether directly to it.
   * The ether sent to the contract should be used as the bet for the game. 
   * Any additional ether that exceeds the original bet of the creator should be refunded.
   * @param gameNumber {uint} - Corresponds to the gameNumber provided by the GameCreated event
   */
  function joinGame(uint gameNumber) public payable {
  
  }
  
  /**
   * Use this endpoint to make a move during a game 
   * @param gameNumber {uint} - Corresponds to the gameNumber provided by the GameCreated event
   * @param moveNumber {uint} - The move for this player (1, 2, or 3 for rock, paper, scissors respectively)
   */
  function makeMove(uint gameNumber, uint moveNumber) public { 
    
  }
}