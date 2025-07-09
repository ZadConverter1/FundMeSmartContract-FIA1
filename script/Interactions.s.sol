// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundCon} from "src/FundMe.sol";
import {ScriptDeploy} from "./DeployFundMe.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundCon is Script {
    uint256 constant TO_SEND = 0.1 ether;

    function run() external {
        address latestDeploy = DevOpsTools.getMostRecentDeployment(
            "FundCon",
            block.chainid
        );
        fundIt(latestDeploy);
    }

    function fundIt(address _latestDep) public {
        vm.startBroadcast();
        FundCon(payable(_latestDep)).fund{value: TO_SEND}();
        vm.stopBroadcast();
    }
}

contract WithdrawFundCon is Script {
    function run() external {
        address latestDeploy = DevOpsTools.getMostRecentDeployment(
            "FundCon",
            block.chainid
        );
        withdrawIt(latestDeploy);
    }

    function withdrawIt(address _latestDep) public {
        vm.startBroadcast();
        FundCon(payable(_latestDep)).withdraw();
        vm.stopBroadcast();
    }
}
