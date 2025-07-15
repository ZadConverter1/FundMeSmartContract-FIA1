// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundCon} from "src/FundMe.sol";
import {ScriptDeploy} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundCon internal fundCon;
    address USER = makeAddr("Home");
    uint256 STARTING_BALANCE = 1 ether;

    function setUp() external {
        ScriptDeploy scriptDeploy = new ScriptDeploy();
        fundCon = scriptDeploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testOwner() public view {
        address owner = fundCon.getOwner();
        assertNotEq(USER, owner);
    }

    function testVersion() public view {
        uint256 vers = fundCon.versionCheck();
        assertEq(vers, 6);
    }

    function testMathsStuff() public view {
        uint256 price = fundCon.MINUSDPRICE();
        assertGt(6e18, price);
    }

    function testFundReversion() public {
        vm.expectRevert();
        fundCon.fund{value: 20}();
    }

    function testUpdateValueStructures() public {
        vm.prank(USER);
        fundCon.fund{value: STARTING_BALANCE}();
        address funder = fundCon.getAddress(0);
        assertEq(funder, USER);

        uint256 amount = fundCon.getAddressAmount(USER);
        assertGt(amount, USER.balance);
    }

    function testOnlyOwner() public view {
        address owner = fundCon.getOwner();
        console.log(owner);
    }

    function testWithdrawWithOne() public funded poor {
        uint256 initialOwnerBalance = fundCon.getOwner().balance;
        uint256 initialConBalance = address(fundCon).balance;
        vm.prank(fundCon.getOwner());
        fundCon.withdraw();
        uint256 finalOwnerBalance = fundCon.getOwner().balance;
        uint256 finalConBalance = address(fundCon).balance;
        assertEq(initialOwnerBalance, finalConBalance);
        assertEq(initialConBalance, finalOwnerBalance);
    }

    function testWithdrawWithMultiple() public poor {
        uint256 initialOwnerBalance = fundCon.getOwner().balance;
        console.log(initialOwnerBalance, "<-- Should be null.");
        for (uint160 idx; idx < 10; idx++) {
            hoax(address(idx), STARTING_BALANCE + 1 ether);
            fundCon.fund{value: STARTING_BALANCE + 1 ether}();
        }
        uint256 initialConBalance = address(fundCon).balance;
        console.log(initialConBalance, "<-- Should be 20000000000000000000.");
        vm.prank(fundCon.getOwner());
        fundCon.withdraw();
        uint256 finalConBalance = address(fundCon).balance;
        console.log(finalConBalance, "<-- should be null");
        uint256 finalOwnerBalance = fundCon.getOwner().balance;
        console.log(finalOwnerBalance, "<-- should be 20000000000000000000");
        assertEq(initialConBalance, finalOwnerBalance);
        assertEq(finalConBalance, initialOwnerBalance);
    }

    modifier funded() {
        vm.prank(USER);
        fundCon.fund{value: STARTING_BALANCE}();
        _;
    }

    modifier poor() {
        address owner = fundCon.getOwner();
        vm.deal(owner, 0);
        _;
    }
}
