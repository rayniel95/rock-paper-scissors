// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.0;

contract RockPaperScissors {
  event GameCreated(address creator, uint gameNumber, uint bet);
  event GameStarted(address[] players, uint gameNumber);
  event GameComplete(address winner, uint gameNumber);
  
  struct Game {
    address[2] players;
    uint bet;
    MoveType[2] moves;
  }
  enum MoveType {
    None,
    ROCK,
    PAPER,
    SCISSORS
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
    games.push(Game([msg.sender, participant], msg.value, [MoveType.None, MoveType.None]));
    emit GameCreated(msg.sender, games.length-1, msg.value);
  }
  
  /**
   * Use this endpoint to join a game.
   * It is a payable endpoint meaning the joining participant will send ether directly to it.
   * The ether sent to the contract should be used as the bet for the game. 
   * Any additional ether that exceeds the original bet of the creator should be refunded.
   * @param gameNumber {uint} - Corresponds to the gameNumber provided by the GameCreated event
   */
  function joinGame(uint gameNumber) public payable {
    require(msg.sender == games[gameNumber].players[1], "You can not participate");
    require(msg.value >= games[gameNumber].bet, "You must send a value grether or equal of the initial bet");
    
    if (msg.value > games[gameNumber].bet) {
        (bool success,) = msg.sender.call{value: msg.value - games[gameNumber].bet}("");
        require(success,"Failed to send Eth!");
    }
    address[] memory players = new address[](2);
    // TODO - will be a good idea to add a library for casting from fixed 
    // array to dynamic one
    for (uint index = 0; index < 2; index++) {
        players[index] = games[gameNumber].players[index];
    }

    emit GameStarted(players, gameNumber);
  }
  
  /**
   * Use this endpoint to make a move during a game 
   * @param gameNumber {uint} - Corresponds to the gameNumber provided by the GameCreated event
   * @param moveNumber {uint} - The move for this player (1, 2, or 3 for rock, paper, scissors respectively)
   */
  function makeMove(uint gameNumber, uint moveNumber) public { 
    require(moveNumber > 0, "Move number must be grather than zero");
    require(moveNumber < 4, "Move number must be less than four");
    require(msg.sender == games[gameNumber].players[1] || msg.sender == games[gameNumber].players[0], "You can not participate");

    if (games[gameNumber].moves[0] == MoveType.None && games[gameNumber].moves[1] == MoveType.None) {
      if (msg.sender == games[gameNumber].players[0]) {
        games[gameNumber].moves[0] = MoveType(moveNumber);
        return;
      }
      games[gameNumber].moves[1] = MoveType(moveNumber);
      return;
    }
    uint winner;
    if (msg.sender == games[gameNumber].players[0]) {
      winner = checkWinner(games[gameNumber].moves[0], MoveType(moveNumber));
    }else {
      winner = checkWinner(MoveType(moveNumber), games[gameNumber].moves[1]);
    }
    bool sent;
    if (winner == 0) {
      (sent,) = games[gameNumber].players[0].call{value: address(this).balance/2}("");
      require(sent, "Failed to send Ether to first player");
      (sent,) = games[gameNumber].players[1].call{value: address(this).balance}("");
      require(sent, "Failed to send Ether to second player");
      emit GameComplete(address(0), gameNumber);
      return;
    }
    if (winner == 1) {
      (sent,) = games[gameNumber].players[0].call{value: address(this).balance}("");
      require(sent, "Failed to send Ether to first player");
      emit GameComplete(games[gameNumber].players[0], gameNumber);
      return;
    }
    (sent,) = games[gameNumber].players[1].call{value: address(this).balance}("");
    require(sent, "Failed to send Ether to second player");
    emit GameComplete(games[gameNumber].players[1], gameNumber);
  }

  function checkWinner(MoveType first, MoveType second) internal pure returns (uint) {
    uint8[9] memory result = [0, 2, 1, 1, 0, 2, 2, 1, 0];
    return result[(uint(first)-1)*3+(uint(second)-1)];
  }
}