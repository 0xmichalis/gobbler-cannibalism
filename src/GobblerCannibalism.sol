// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from "solmate/tokens/ERC721.sol";

import { IArtGobblers } from "./interfaces/IArtGobblers.sol";

/// @notice Feed a gobbler another gobbler.
contract GobblerCannibalism is ERC721 {
    /*//////////////////////////////////////////////////////////////
                                MENU
    //////////////////////////////////////////////////////////////*/

    IArtGobblers public immutable gobblers;


    /*//////////////////////////////////////////////////////////////
                        CANNIBAL-RELATED STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal mealId;
    /// @notice GobblerCannibalism id to ArtGobblers id
    mapping(uint256 => uint256) public mealForGobbler;


    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor (address _gobblers) ERC721('GobblerCannibalism', 'GOBBLER_CANNIBAL') {
        gobblers = IArtGobblers(_gobblers);
    }


    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 id) public view override returns (string memory) {
        return gobblers.tokenURI(mealForGobbler[id]);
    }


    /*//////////////////////////////////////////////////////////////
                                CANNIBAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepare an ArtGobbler to be devoured by
    /// another ArtGobbler yummy yummy
    /// @dev Requires approval
    function cook(uint256 gobblerId) external {
        uint256 _mealId = mealId;
        unchecked {
            ++_mealId;
        }
        _mint(msg.sender, _mealId);
        mealForGobbler[_mealId] = gobblerId;
        mealId = _mealId;

        gobblers.transferFrom(msg.sender, address(this), gobblerId);
    }
}
