//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; // Making FundMe a storage variable

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 15 ether; // 15 ETH in wei
    uint256 constant GAS_PRICE = 1 gwei; // 1 Gwei in wei
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH in wei

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        // Fund the USER account and prank as USER
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // Directly fund using USER

        // Withdraw as owner
        address owner = fundMe.getOwner();
        vm.prank(owner); // Prank as owner for withdrawal
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
    }
}
