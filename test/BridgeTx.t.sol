// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgeTx} from "../src/BridgeTx.sol";

contract SourceTest is Test {
    BridgeTx public btx;
    address public user1 = vm.addr(1);
    BridgeTx.BridgeTransfer[] public messageArr;

    event BridgeTransaction(
        uint256 globalActionId,
        address from,
        string foreignAddress,
        uint256 foreignChainId,
        uint256 amount,
        uint256 conversionRate,
        uint256 conversionDecimals
    );

    function setUp() public{
        btx = new BridgeTx();
        vm.deal(user1, 20 ether);
    }

    function test_PostMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        uint256 _chainId = 0;
        uint256 _actionId = uint256(keccak256(abi.encodePacked(_chainId, block.chainid, address(btx), block.timestamp)));
        BridgeTx.BridgeTransfer memory message = BridgeTx.BridgeTransfer("0x000d", 1, 1 ether);     
        messageArr.push(message);

        vm.expectEmit(false, false, false, true);
        emit BridgeTransaction(_actionId, user1, "0x000d", 1, 1 ether, 3 * 1e21, 1e18);
        btx.postMessage{value: 1 ether}(messageArr);
    }

    function test_PostMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        BridgeTx.BridgeTransfer memory message = BridgeTx.BridgeTransfer("0x000d", 1, 4 ether);     
        messageArr.push(message);

        vm.expectRevert("BridgeTx: amount to be transferred exceeds slinding window transfer limit");
        btx.postMessage{value: 1 ether}(messageArr);
    }
}
