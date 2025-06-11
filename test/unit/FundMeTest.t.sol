//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {console} from "forge-std/console.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// This is a test contract for the FundMe contract

contract FundMeTest is Test {
    FundMe fundMe; // Making FundMe a storage variable
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 1 ETH in wei
        // Set the balance of USER to 1 ETH
    uint256 constant STARTING_BALANCE = 15 ether; // 10 ETH in wei
    uint256 constant GAS_PRICE = 1 gwei; // 1 Gwei in wei

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollarisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD should be 5");
    }

    function testOwnerisMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender, "Owner should be the contract deployer");
    }

    function testPriceFeedVersionisAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "Price feed version should be 4");
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund(); // Sending 1 ETH, which is less than the minimum USD value
    }

    function testFundUpdatedFundedDataStructure() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should be 1 ETH");
    }

    function testAddsFundertoArrayofFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "Funder should be the user address");
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);

        vm.expectRevert();

        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnwerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;


        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // Set gas price to 0 for testing
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // Calculate gas used in wei
        console.log("Gas used for withdrawal:", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;
        assertEq(endingfundMeBalance, 0, "FundMe balance should be 0 after withdrawal");
        assertEq(
            startingfundMeBalance + startingOwnwerBalance,
            endingOwnerBalance
        );


    }

    function testWthdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
           // vm.prank(address(uint160(i + 1)));
            //fundMe.fund{value: SEND_VALUE}();

            hoax(address(i), SEND_VALUE); // Simulate a user sending SEND_VALUE ETH
            fundMe.fund{value: SEND_VALUE}();


        }
        uint256 startingOwnwerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        
        assert(address(fundMe).balance == 0);
        assert(
            startingfundMeBalance + startingOwnwerBalance ==
            fundMe.getOwner().balance
           
        );
    }

    function testWthdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
           // vm.prank(address(uint160(i + 1)));
            //fundMe.fund{value: SEND_VALUE}();

            hoax(address(i), SEND_VALUE); // Simulate a user sending SEND_VALUE ETH
            fundMe.fund{value: SEND_VALUE}();


        }
        uint256 startingOwnwerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        
        assert(address(fundMe).balance == 0);
        assert(
            startingfundMeBalance + startingOwnwerBalance ==
            fundMe.getOwner().balance
           
        );
    }
}
