// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import 'src/Dokigotchi.sol';
import './PetTestHelper.sol';

contract PetTest is Test, PetTestHelper {
    function testBalanceIncrement() public {
        assertEq(address(pet).balance, 0);
        mockMint();
        assertEq(address(pet).balance, pet.mintPrice());
    }

    function testWithdrawWorksAsOwner() public {
        assertEq(address(pet).balance, 0);
        assertEq(address(0x407).balance, 0);
        assertEq(address(0xc0d3).balance, 0);

        mockMint();
        pet.retrieveFunds();

        uint256 price = pet.mintPrice();
        assertEq(address(pet).balance, 0);
        assertEq(address(0x407).balance, (price * 70) / 100);
        assertEq(address(0xc0d3).balance, (price * 30) / 100);
    }

    function testCannotQueryNonexistentTokenUri() public {
        vm.expectRevert(IERC721A.URIQueryForNonexistentToken.selector);
        pet.tokenURI(1);
    }

    function testSetBaseUriAsOwner() public {
        mockMint();

        string memory uri = pet.tokenURI(0);
        assertEq(uri, '');

        pet.setBaseURI('https://path/to/');
        assertEq(pet.tokenURI(0), 'https://path/to/0');
    }

    function testCannotSetBaseUriAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert('UNAUTHORIZED');
        pet.setBaseURI('https://path/to');
    }

    function testCanRescueAsOwner() public {
        uint256 startBal = token.balanceOf(address(this));
        token.transfer(address(pet), startBal);
        pet.rescue(address(token));
        uint256 endBal = token.balanceOf(address(this));
        assertEq(startBal, endBal);
    }

    function testCannotRescueAsNonOwner() public {
        vm.expectRevert('UNAUTHORIZED');
        vm.prank(address(0x0));
        pet.rescue(address(token));
    }

    function testCanSetWhitelistStartTimeAsOwner() public {
        uint256 newDate = block.timestamp + 1 days;
        assertFalse(pet.whitelistStartTime() == newDate);
        pet.setWhitelistStartTime(newDate);
        assertEq(pet.whitelistStartTime(), newDate);
    }

    function testCannotSetInvalidWhitelistStartTime() public {
        vm.expectRevert(MintStartTime.selector);
        pet.setWhitelistStartTime(0);
    }

    function testCannotSetWhitelistStartTimeAsNonOwner() public {
        vm.prank(address(0));
        vm.expectRevert('UNAUTHORIZED');
        pet.setWhitelistStartTime(50);
    }

    function testCanSetPublicStartTimeAsOwner() public {
        uint256 newDate = block.timestamp + 1 days;
        assertFalse(pet.publicStartTime() == newDate);
        pet.setPublicStartTime(newDate);
        assertEq(pet.publicStartTime(), newDate);
    }

    function testCannotSetInvalidPublicStartTime() public {
        vm.expectRevert(MintStartTime.selector);
        pet.setPublicStartTime(0);
    }

    function testCannotSetPublicStartTimeAsNonOwner() public {
        vm.prank(address(0));
        vm.expectRevert('UNAUTHORIZED');
        pet.setPublicStartTime(50);
    }

    function testArtistsCanSetAddress() public {
        address newAddr = address(1);
        vm.startPrank(address(0x407));
        pet.setArtists(address(newAddr));
        assertEq(pet.artists(), newAddr);
    }

    function testArtistsCannotSetToZeroAddress() public {
        vm.startPrank(address(0x407));
        vm.expectRevert(InvalidAddress.selector);
        pet.setArtists(address(0));
    }

    function testArtistsCannotSetToOwnerAddress() public {
        vm.startPrank(address(0x407));
        vm.expectRevert(NotOwner.selector);
        pet.setArtists(address(this));
    }

    function testOtherCannotSetArtistAddress() public {
        vm.startPrank(address(0));
        vm.expectRevert(NotArtists.selector);
        pet.setArtists(address(1));
    }

    function testDevsCanSetAddress() public {
        address newAddr = address(1);
        vm.startPrank(address(0xc0d3));
        pet.setDevs(address(newAddr));
        assertEq(pet.devs(), newAddr);
    }

    function testDevsCannotSetToZeroAddress() public {
        vm.startPrank(address(0xc0d3));
        vm.expectRevert(InvalidAddress.selector);
        pet.setDevs(address(0));
    }
    
    function testDevsCannotSetToOwnerAddress() public {
        vm.startPrank(address(0xc0d3));
        vm.expectRevert(NotOwner.selector);
        pet.setDevs(address(this));
    }

    function testOtherCannotSetDevAddress() public {
        vm.startPrank(address(0));
        vm.expectRevert(NotDevs.selector);
        pet.setDevs(address(1));
    }

    function testCanSetMerkleRootAsOwner() public {
        assertFalse(pet.merkleRoot() == 0);
        pet.setMerkleRoot(0);
        assertEq(pet.merkleRoot(), 0);
    }

    function testCannotSetMerkleRootAsNonOwner() public {
        vm.prank(address(0));
        vm.expectRevert('UNAUTHORIZED');
        pet.setMerkleRoot(0);
    }

    function testCannotSetMerkleRootWhileMinting() public {
        vm.warp(block.timestamp + 10 days);
        vm.expectRevert(MintStartTime.selector);
        pet.setMerkleRoot(0);
    }
}
