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
        assertEq(vers, 4);
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
        for (uint160 idx = 1; idx < 10; idx++) {
            hoax(address(idx), STARTING_BALANCE);
            fundCon.fund{value: 1 ether}();
        }
        uint256 initialConBalance = address(fundCon).balance;
        uint256 initialOwnerBalance = fundCon.getOwner().balance;
        assertGt(initialConBalance, initialOwnerBalance);
        console.log(initialConBalance, "<-- Contract after being funded.");
        address owner = fundCon.getOwner();
        vm.prank(owner);
        fundCon.withdraw();
        console.log(
            fundCon.getOwner().balance,
            "<-- Owner balance after withdrawing"
        );
        assertEq(initialConBalance, fundCon.getOwner().balance);
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
