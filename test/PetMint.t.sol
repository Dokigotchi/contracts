// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import 'src/Dokigotchi.sol';
import './PetTestHelper.sol';

contract PetMintTest is Test, PetTestHelper {
    function testMintSingle() public {
        vm.warp(block.timestamp + 15 days);
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1), address(1));

        pet.publicMint{value: pet.mintPrice()}(1);

        assertEq(pet.balanceOf(address(1)), 1);
    }

    function testMintMultiple() public {
        vm.warp(block.timestamp + 15 days);
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1), address(1));

        pet.publicMint{value: pet.MAX_MINT_PER_TX() * pet.mintPrice()}(
            pet.MAX_MINT_PER_TX()
        );

        assertEq(pet.balanceOf(address(1)), pet.MAX_MINT_PER_TX());
    }

    function testCannotMintPastLimit() public {
        vm.warp(block.timestamp + 15 days);
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1), address(1));

        uint256 amt = pet.MAX_MINT_PER_TX() + 1;
        uint256 val = amt * pet.mintPrice();

        vm.expectRevert(MintLimitReached.selector);
        pet.publicMint{value: val}(amt);
    }

    function testCannotMintZeroQuantity() public {
        vm.startPrank(address(1), address(1));
        vm.warp(block.timestamp + 15 days);

        vm.expectRevert(IERC721A.MintZeroQuantity.selector);
        pet.publicMint(0);
    }

    function testCannotMintToZeroAddress() public {
        vm.deal(address(0), 100 ether);
        vm.startPrank(address(0), address(0));
        vm.warp(block.timestamp + 15 days);

        uint256 price = pet.mintPrice();
        vm.expectRevert(IERC721A.MintToZeroAddress.selector);
        pet.publicMint{value: price}(1);
    }

    function testCannotMintPriceNotPaid() public {
        vm.prank(address(1), address(1));
        vm.warp(block.timestamp + 15 days);

        vm.expectRevert(MintPriceNotPaid.selector);
        pet.publicMint(1);
    }

    function testCannotMintBeforeStartTime() public {
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1), address(1));

        uint256 price = pet.mintPrice();
        vm.expectRevert(MintStartTime.selector);
        pet.publicMint{value: price}(1);
    }

    function testCannotMintNotEOA() public {
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1));
        vm.warp(block.timestamp + 15 days);

        uint256 price = pet.mintPrice();
        vm.expectRevert(NotEOA.selector);
        pet.publicMint{value: price}(1);
    }

    function testCannotMintPastMaxSupply() public {
        vm.warp(block.timestamp + 15 days);
        vm.deal(address(1), 100 ether);
        vm.store(address(pet), bytes32(uint256(0)), bytes32(uint256(5555)));
        vm.startPrank(address(1), address(1));
        
        uint256 mintPrice = pet.mintPrice();
        vm.expectRevert(MaxSupply.selector);
        pet.publicMint{value: mintPrice}(1);
    }
}
