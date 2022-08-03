// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import 'src/Dokigotchi.sol';
import './PetTestHelper.sol';

contract PetHonorariesTest is Test, PetTestHelper {
    function testMintHonorary() public {
        assertEq(pet.balanceOf(address(1)), 0);
        pet.honorariesMint(address(1), 1);
        assertEq(pet.balanceOf(address(1)), 1);
        assertEq(pet.totalSupply(), 1);
    }

    function testMintMultipleHonoraries() public {
        assertEq(pet.balanceOf(address(1)), 0);
        pet.honorariesMint(address(1), 2);
        assertEq(pet.balanceOf(address(1)), 2);
        assertEq(pet.totalSupply(), 2);
    }

    function testMintAllHonoraries() public {
        assertEq(pet.balanceOf(address(1)), 0);
        
        uint256 max = pet.MAX_HONORARIES();
        pet.honorariesMint(address(1), max);
        assertEq(pet.balanceOf(address(1)), max);
        assertEq(pet.totalSupply(), max);
    }

    function testCannotMintHonoraryToZeroAddress() public {
        vm.expectRevert(IERC721A.MintToZeroAddress.selector);
        pet.honorariesMint(address(0), 1);
    }

    function testCanMintHonoraryToReceiver() public {
        assertEq(pet.balanceOf(address(receiver)), 0);
        pet.honorariesMint(address(receiver), 1);
        assertEq(pet.balanceOf(address(receiver)), 1);
    }

    function testCannotMintHonoraryToNonReceiver() public {
        vm.etch(address(80), bytes('mock'));
        vm.expectRevert();
        pet.honorariesMint(address(80), 1);
    }

    function testCannotMintHonoraryAsNotOwner() public {
        vm.prank(address(1));
        vm.expectRevert('UNAUTHORIZED');
        pet.honorariesMint(address(1), 1);
    }

    function testCannotOverflowHonorarySupply() public {
        uint256 max = pet.MAX_HONORARIES();
        pet.honorariesMint(address(1), max);
        assertEq(pet.balanceOf(address(1)), max);
        assertEq(pet.totalSupply(), max);

        vm.expectRevert(MaxHonoraries.selector);
        pet.honorariesMint(address(1), 1);
    }
}
