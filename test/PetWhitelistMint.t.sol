// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import 'src/Dokigotchi.sol';
import './PetTestHelper.sol';

contract PetWhitelistMintTest is Test, PetTestHelper {
    using stdStorage for StdStorage;
    
    function testClaim() public {
        assertEq(pet.balanceOf(WL_USER), 0);

        vm.deal(WL_USER, 100 ether);
        vm.warp(block.timestamp + 7 days);

        populateCorrectProof();
        uint256 mintPrice = pet.mintPrice();

        vm.prank(WL_USER, WL_USER);
        pet.whitelistMint{value: mintPrice}(proof);

        assertEq(pet.balanceOf(WL_USER), 1);
    }

    function testCannotClaimEmptyMerkle() public {
        vm.deal(WL_USER, 100 ether);
        vm.warp(block.timestamp + 7 days);

        uint256 mintPrice = pet.mintPrice();

        vm.prank(WL_USER, WL_USER);
        vm.expectRevert(InvalidMerkleProof.selector);
        pet.whitelistMint{value: mintPrice}(proof);
    }

    function testCannotClaimInvalidProof() public {
        vm.deal(WL_USER, 100 ether);
        vm.warp(block.timestamp + 7 days);

        populateIncorrectProof();
        uint256 mintPrice = pet.mintPrice();

        vm.prank(WL_USER, WL_USER);
        vm.expectRevert(InvalidMerkleProof.selector);
        pet.whitelistMint{value: mintPrice}(proof);
    }

    function testNonWhitelistedCannotClaimWithValidProof() public {
        vm.deal(address(1), 100 ether);
        vm.warp(block.timestamp + 7 days);

        populateCorrectProof();
        uint256 mintPrice = pet.mintPrice();

        vm.prank(address(1), address(1));
        vm.expectRevert(InvalidMerkleProof.selector);
        pet.whitelistMint{value: mintPrice}(proof);
    }

    function testCannotClaimNotEOA() public {
        vm.deal(address(1), 100 ether);
        vm.startPrank(address(1));
        vm.expectRevert(NotEOA.selector);
        pet.whitelistMint(proof);
    }

    function testCannotClaimEarly() public {
        vm.deal(address(1), 100 ether);
        vm.prank(address(1), address(1));
        vm.expectRevert(MintStartTime.selector);
        pet.whitelistMint(proof);
    }

    function testCannotClaimPriceNotPaid() public {
        vm.prank(address(1), address(1));
        vm.warp(block.timestamp + 7 days);
        vm.expectRevert(MintPriceNotPaid.selector);
        pet.whitelistMint(proof);
    }

    function testCannotDoubleClaim() public {
        assertEq(pet.balanceOf(WL_USER), 0);
        vm.deal(WL_USER, 100 ether);
        vm.warp(block.timestamp + 7 days);

        populateCorrectProof();
        uint256 mintPrice = pet.mintPrice();

        vm.startPrank(WL_USER, WL_USER);
        pet.whitelistMint{value: mintPrice}(proof);
        assertEq(pet.balanceOf(WL_USER), 1);

        vm.expectRevert(AlreadyClaimed.selector);
        pet.whitelistMint{value: mintPrice}(proof);
    }

    function testCannotMintPastMaxSupply() public {
        vm.deal(WL_USER, 100 ether);
        vm.warp(block.timestamp + 7 days);

        populateCorrectProof();
        uint256 mintPrice = pet.mintPrice();
        
        vm.store(address(pet), bytes32(uint256(0)), bytes32(uint256(5555)));
        
        vm.startPrank(WL_USER, WL_USER);
        vm.expectRevert(MaxSupply.selector);
        pet.whitelistMint{value: mintPrice}(proof);
    }
}
