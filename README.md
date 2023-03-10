My solution to the next problem:

Let's play the classic game of Rock, Paper, Scissors on the Ethereum blockchain! If you haven't already done so check out the Smart Contracts Introduction: GiftCoin kata for a quick introduction to smart contracts.

For this Kata we're going to need to implement three methods on our Rock Paper Scissors smart contract, as well as call three events when appropriate.

Methods
Create Game - This is a payable method that allows the creation of a new game. Since it is payable, the creator will send ether directly to the contract which will be used as the bet for the game (When the game is won the winner will receive both bets). The creator must also also specify a participant on this method call so that only one address will whitelisted to join the game. This method will call the GameCreated event if successful. A transaction to this endpoint is invalid only if no ether is sent, the amount of the bet must be greater than zero.

Join Game - This is a payable method that allows joining an existing game. Being payable, it requires the joining participant to send ether directly to the contract to match the bet of the game creator. If less ether is sent, it is invalid. If more ether is sent, the additional ether should be refunded and transferred back to the participant's address. This method will call the GameStarted event if successful.

Make Move - This method allows both players in the game to make their move. The move must be entered as a unsigned integer (uint) and must be 1, 2 or 3 corresponding to 'rock', 'paper', 'scissors' respectively. Refer to the Wikipedia entry for rules on winning moves. Once both players have completed their move, the GameComplete event should be called with the address of the winner. If one player wins both bets should be transferred to their address. In the event of a tie, the winner should be specified as the zero address (address(0)) and both bets should be evenly returned to the players.

Invalid Method Calls - Invalid Transactions (not sending enough ether to cover the bet, trying to join a non-existing game, joining from a non-whitelisted event) should throw exceptions. For more information on error handling refer to the error handling section of the Solidity Documentation.

Events
Game Created - This event is called after a game is created. It must contain the address of the creator of the game, a unique unsigned integer gameNumber, and the usigned integer size of the bet.

Game Started - This event is called after the valid participant joins the game. They will need to match the size of the bet. The event will include an array containing the addresses of the two players (the creator and the participant) as well as the gameNumber.

Game Complete - This event is called after both players have made their move the outcome of the game has been decided. It will contain the address of the winner (or the zero address in the event of a tie) as well as the gameNumber.