// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {MathsConversions} from "src/MathematicalConversions.sol";
import {AggregatorV3Interface as agr} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundCon__minPriceNotReached();
error FundCon__withdrawlFailure();
error FundCon__unmatchingPublisherAddress();

contract FundCon {
    using MathsConversions for uint256;

    agr internal immutable s_priceList;
    address private immutable i_owner;
    uint256 public constant MINUSDPRICE = 5e18;
    mapping(address => uint256) private s_funderToAmount;
    address[] private s_listOfFunders;

    constructor(address priceFeed) {
        s_priceList = agr(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        uint256 amount_sent = msg.value.convertEthToUsd(s_priceList);
        if (amount_sent < MINUSDPRICE) {
            revert FundCon__minPriceNotReached();
        } else {
            s_funderToAmount[msg.sender] = amount_sent;
            s_listOfFunders.push(msg.sender);
        }
    }

    function withdraw() public onlyOnwer {
        uint256 length_needed = s_listOfFunders.length;
        for (uint256 idx; idx < length_needed; idx++) {
            s_funderToAmount[s_listOfFunders[idx]] = 0;
        }
        s_listOfFunders = new address[](0);
        (bool sendSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (sendSuccess != true) {
            revert FundCon__withdrawlFailure();
        }
    }

    function versionCheck() public view returns (uint256) {
        uint256 vers = s_priceList.version();
        return vers;
    }

    function getAddress(uint256 _addressIndex) external view returns (address) {
        return s_listOfFunders[_addressIndex];
    }

    function getAddressAmount(address _funder) external view returns (uint256) {
        return s_funderToAmount[_funder];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getListLength() external view returns (uint256) {
        uint256 funders = s_listOfFunders.length;
        return funders;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier onlyOnwer() {
        if (msg.sender != i_owner) {
            revert FundCon__unmatchingPublisherAddress();
        }
        _;
    }
}
