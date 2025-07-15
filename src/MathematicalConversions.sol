// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {AggregatorV3Interface as agr} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library MathsConversions {
    function ethValueInUsd(agr _priceFeed) internal view returns (uint256) {
        agr feedAddress = agr(_priceFeed);
        (, int256 price, , , ) = feedAddress.latestRoundData();
        return uint256(price * 1e10); // return price;
    }

    function convertEthToUsd(uint256 _amount, agr _priceFeed) internal view returns (uint256) {
        uint256 priceOfEthInUsd = ethValueInUsd(_priceFeed);
        uint256 amountSentInUsd = (priceOfEthInUsd * _amount) / 1e18;
        return amountSentInUsd; // 2560 x _amount wei
    }
}
