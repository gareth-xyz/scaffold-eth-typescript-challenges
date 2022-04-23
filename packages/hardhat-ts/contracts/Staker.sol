pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;
  mapping(address => uint256) public balances;
  event Stake(address, uint256);
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool openForWithdraw;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() external payable {
    emit Stake(msg.sender, msg.value);

    balances[msg.sender] += msg.value;

    console.log('received %s from %s, new balance: %s', msg.value, msg.sender, balances[msg.sender]);

    console.log('contract balance: %s', address(this).balance);
  }

  function execute() public {
    require(timeLeft() == 0, 'deadline has not passed');

    if (address(this).balance < threshold) {
      console.log('execute called but balance < threshold');
      openForWithdraw = true;
    } else {
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  function withdraw() external {
    require(openForWithdraw = true, 'contract is not open for withdraw');
    require(balances[msg.sender] > 0, 'caller has no funds deposited');
    payable(msg.sender).transfer(balances[msg.sender]);
    balances[msg.sender] = 0;
  }
}
