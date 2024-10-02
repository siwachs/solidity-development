// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    // Use Chainlink and oracle to convert USD to ETH
    uint256 public minimumUSD = 1 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUSD, "Minimum 50USD need to for this transaction!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public {
       for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
        address funder =  funders[funderIndex];
        addressToAmountFunded[funder] = 0;
       }

        // Reset Array start at index 0    
       funders = new address[](0);

       // Three way to send ETH -> transfer, send, call

       // Use 2300 GAS and throw Error
       // payable(msg.sender).transfer(address(this).balance);

       // use 2300 GAS and return bool
       // bool sendSuccess = payable(msg.sender).send(address(this).balance);
       // require(sendSuccess,"Fail to transfer ETH.");

       // call A lower level command use all the GAS or use all avail GAS
       // Use memory because bytes object are array - bytes memory dataReturned
       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
       require(callSuccess,"Fail to transfer ETH.");
    }
}