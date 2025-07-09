// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundCon} from "src/FundMe.sol";
import {ScriptDeploy} from "script/DeployFundMe.s.sol";
import {Script} from "forge-std/Script.sol";
import {FundFundCon, WithdrawFundCon} from "script/Interactions.s.sol";

contract FundConTestIntegration is Test {
    FundCon internal fundCon;
    address USER = makeAddr("Nigga");
    uint256 STARTING_BALANCE = 10 ether;

    function setUp() external {
        ScriptDeploy sc = new ScriptDeploy();
        fundCon = sc.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testFundFundMe() public {
        FundFundCon funder = new FundFundCon();
        funder.fundIt(address(fundCon));
    }

    function testWithdrawFundMe() public {
        WithdrawFundCon withdrawer = new WithdrawFundCon();
        withdrawer.withdrawIt(address(fundCon));
    }
}
