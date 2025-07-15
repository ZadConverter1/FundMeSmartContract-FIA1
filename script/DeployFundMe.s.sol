// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundCon} from "src/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract ScriptDeploy is Script {
    HelperConfig hc = new HelperConfig();
    address mathsExchange = hc.activeNetworkConfig();

    function run() external returns (FundCon) {
        vm.startBroadcast();
        FundCon fundCon = new FundCon(mathsExchange);
        vm.stopBroadcast();
        return fundCon;
    }
}
