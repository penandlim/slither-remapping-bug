// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BaseStrategy} from "tokenized-strategy/src/BaseStrategy.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title TestStrategy
/// @notice This contract extends the BaseStrategy contract, which uses Openzeppelin 4.9.5
/// as a dependency, and also extends Openzeppelin 5.3.0's ReentrancyGuard contract
contract TestStrategy is BaseStrategy, ReentrancyGuard {
    constructor(address _asset, string memory _name) BaseStrategy(_asset, _name) {}

    function _deployFunds(uint256 _amount) internal override {}

    function _freeFunds(uint256 _amount) internal override {}

    function _harvestAndReport() internal override returns (uint256) {
        return 0;
    }

    function nonReentrantFunction() external nonReentrant {
        // This function is not reentrant thanks to Openzeppelin 5.3.0's ReentrancyGuard
    }
}
