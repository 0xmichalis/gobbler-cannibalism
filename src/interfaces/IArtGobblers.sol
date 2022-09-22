// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IArtGobblers {
    function transferFrom(address from, address to, uint256 id) external;
    function tokenURI(uint256 gobblerId) external view returns (string memory);
}
