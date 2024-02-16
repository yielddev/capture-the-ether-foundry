// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GuessTheSecretNumber {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable returns (bool) {
        require(msg.value == 1 ether);

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to Send 2 ether");
        }
        return true;
    }
}

// Write your exploit codes below
contract ExploitContract {
    GuessTheSecretNumber private guessTheSecretNumber;
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor(address challengeAddress) {
        guessTheSecretNumber = GuessTheSecretNumber(
            challengeAddress
        );
    }
    function Exploiter() public view returns (uint8 i) {
        // 255 is largest 8 bit uint
        for (i = 0; i < 256; i++) {
            if (keccak256(abi.encodePacked(i)) == answerHash) {
                //guessTheSecretNumber.guess{value: 1 ether}(i);    
                return i;
            }
        }
    }
}
