// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import 'chiru-labs/mocks/ERC721ReceiverMock.sol';
import 'solmate/test/utils/mocks/MockERC20.sol';

import 'src/Dokigotchi.sol';

abstract contract PetTestHelper is Test {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    bytes4 constant RECEIVER_MAGIC_VALUE = 0x150b7a02;
    uint256 constant ETH_BLOCK_1 = 1438269988;
    bytes32 constant MERKLE_ROOT = 0x290654de0171b708c67c8cb43c1355f4b3fb9005614a59d06ac597a0b235922a;
    address constant WL_USER = 0xC098B2a3Aa256D2140208C3de6543aAEf5cd3A94;

    Dokigotchi pet;

    ERC721ReceiverMock receiver;
    MockERC20 token;
    bytes32[] proof;

    function setUp() public {
        vm.warp(ETH_BLOCK_1);
        pet = new Dokigotchi(
            'Dokigotchi',
            'DOKIGOTCHI',
            '',
            0.1 ether,
            MERKLE_ROOT,
            block.timestamp + 7 days,
            block.timestamp + 14 days,
            address(this),
            address(0x407),
            address(0xc0d3)
        );

        receiver = new ERC721ReceiverMock(RECEIVER_MAGIC_VALUE, address(pet));
        token = new MockERC20('Token', 'TKN', 18);
        token.mint(address(this), 1e18);
    }

    function mockMint() internal {
        vm.warp(block.timestamp + 15 days);
        vm.deal(address(1), 1 ether);

        uint256 price = pet.mintPrice();
        vm.prank(address(1), address(1));
        pet.publicMint{value: price}(1);
    }

    function populateCorrectProof() internal {
        proof.push(
            0x000000000000000000000000be0eb53f46cd790cd13851d5eff43d12404d33e8
        );
        proof.push(
            0x6a7d30963a8caf18d448766c89405beba9d49ac4fe030900281a4da1809eae81
        );
        proof.push(
            0x6f4e61936ca1136bc7c1b208085f216732b92f3a7c3f58436b965a60af368a19
        );
    }

    function populateIncorrectProof() internal {
        proof.push(bytes32(0x00));
    }
}
