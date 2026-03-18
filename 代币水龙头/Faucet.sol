// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ERC20代币的水龙头合约
contract Faucet {
    uint256 public amountAllowed = 100; // 每次领100单位代币
    address public tokenContract; // token合约地址

    mapping(address => bool) public requestedAddress;

    event SendToken(address indexed Receiver, uint256 indexed Amount);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }

    function requestTokens() external {
        require(!requestedAddress[msg.sender], "Can't Request Multiple Times!");

        IERC20 token = IERC20(tokenContract);

        require(
            token.balanceOf(address(this)) >= amountAllowed,
            "Faucet Empty!"
        );

        token.transfer(msg.sender, amountAllowed);

        requestedAddress[msg.sender] = true;

        emit SendToken(msg.sender, amountAllowed);
    }
}