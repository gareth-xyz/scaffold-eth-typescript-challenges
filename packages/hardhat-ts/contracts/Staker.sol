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

  function execute() {
    require(block.timestamp > deadline, 'deadline has not passed');

    if (address(this).balance < threshold) {
      openForWithdraw = true;
    } else {
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // Add the `receive()` special function that receives eth and calls stake()
}
