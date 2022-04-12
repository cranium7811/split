// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/stdlib.sol";
import {Split} from "../Split.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract ContractTest is DSTest {
    using stdStorage for StdStorage;
    StdStorage public stdstore;

    Split public split;
    MockERC20 public stake;
    Vm public vm = Vm(HEVM_ADDRESS);

    address public one = address(0xbeef);
    address public two = address(0x1337);

    address[] public stakeHolders = new address[](2);

    function writeTokenBalance(
        address who,
        address token,
        uint256 amt
    ) internal {
        stdstore
            .target(token)
            .sig(MockERC20(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }

    function setUp() public {
        stake = new MockERC20("STAKE", "STAKE", 18);
        split = new Split(address(stake), "NFT", "NFT", 10000);

        writeTokenBalance(address(one), address(stake), 100000 * 1e18);
        writeTokenBalance(address(two), address(stake), 100000 * 1e18);

        stakeHolders[0] = address(one);
        stakeHolders[1] = address(two);
    }

    function testFailGetKeyStakeHolders() public {

        vm.prank(address(one));
        split.getKeyStakeHolders(stakeHolders);
    }

    function testSplitETH() public {
        vm.deal(address(split), 100e18);
        split.getKeyStakeHolders(stakeHolders);

        vm.startPrank(address(one));
        split.splitETH();
        vm.stopPrank();

        vm.startPrank(address(two));
        split.splitETH();
        vm.stopPrank();

        assertEq(address(one).balance, 50e18);
        assertEq(address(two).balance, 50e18);
        assertEq(address(split).balance, 0);
    }

    function testFailSplitETH() public {
        address[] memory testStakeHolders;

        split.getKeyStakeHolders(testStakeHolders);

        vm.startPrank(address(one));
        split.splitETH();
        vm.stopPrank();
    }

    function testMint() public {
        vm.deal(address(one), 1e18);
        
        vm.prank(address(one));
        split.mint{value: 1e18}(0);

        assertEq(address(one).balance, 1e18);
    }

    function testFuzzMint(uint256 number) public {
        vm.assume(number <= 10000);
        
        vm.deal(address(one), 1e18 * number);

        vm.prank(address(one));
        split.mint{value: 1e18 * number}(number);

        assertEq(address(one).balance, 1e18 * number - 0.05e18 * number);
    }

    function testFuzzSplitETH(uint256 number) public {
        vm.assume(number > 0);
        vm.assume(number <= 10000);

        split.getKeyStakeHolders(stakeHolders);
        
        vm.deal(address(one), 1e18 * number);

        vm.startPrank(address(one));
        split.mint{value: 1e18 * number}(number);
        split.splitETH();
        vm.stopPrank();

        assertEq(address(two).balance, (0.05e18 * number) / 2);
        assertEq(address(one).balance, 1e18 * number - (0.05e18 * number / 2));
    }
}
