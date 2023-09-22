// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Flipper {
    event PaymentMade(address winner, address loser, uint256 amount);
    address payable private owner = payable(0x86C663a8bBf9E387c53d980a3334d2Aba052360B);
    address payable public player1;
    address payable public player2;
    uint256 public betAmount;

    function joinGame1() public payable {
        require(msg.value > 0, "You must bet some amount.");
        require(player1 == address(0), "Seat 1 is already occupied.");
        require(payable(msg.sender) != player2, "You cannot sit on both sides of the table.");
        if (player2 != address(0)) {
            require(msg.value == betAmount, "You must match the first player's bet.");
        } else {
            betAmount = msg.value;
        }
        player1 = payable(msg.sender);
        getWinner();
    }

    function joinGame2() public payable {
        require(msg.value > 0, "You must bet some amount.");
        require(player2 == address(0), "Seat 2 is already occupied.");
        require(payable(msg.sender) != player1, "You cannot sit on both sides of the table.");
        if (player1 != address(0)) {
            require(msg.value == betAmount, "You must match the first player's bet.");
        } else {
            betAmount= msg.value;
        }
        player2 = payable(msg.sender);
        getWinner();
    }

    function getWinner() private {
        if (player1 != address(0) && player2 != address(0)) {
            owner.transfer((betAmount * 2) / 1000);  // Send fee to owner
            if (block.timestamp % 2 == 0) {
                emit PaymentMade(player1, player2, address(this).balance);
                player1.transfer(address(this).balance);
            } else {
                emit PaymentMade(player2, player1, address(this).balance);
                player2.transfer(address(this).balance);
            }
            resetGame();
        }
    }

    function terminateGame() public {
        require(msg.sender == player1 || msg.sender == player2 || msg.sender == owner,
            "Only player 1, player 2 or the owner can terminate the game.");
        if (player1 != payable(address(0))) {
            player1.transfer(address(this).balance);
        }
        if (player2 != payable(address(0))) {
            player2.transfer(address(this).balance);
        }
        resetGame();
    }

    function resetGame() private {
        player1 = payable(address(0));
        player2 = payable(address(0));
    }
}
