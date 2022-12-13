// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/AccessToken.sol";

contract AccessToken_Test is Test {
    
    AccessToken internal accessToken; 

    string name = "access-token";
    string symbol = "AT";

    // uint256 supply = 100;
    uint256 price = 0.1 ether;

    address internal owner1 = address(1); 
    address internal owner2 = address(2); 
    address internal owner3 = address(3); 
    address internal owner4 = address(4); 
    address internal owner5 = address(5); 

    function setUp() public {
        accessToken = new AccessToken(name, symbol);
        vm.deal(owner1, 0.1 ether);
        vm.deal(owner2, 0.5 ether);
        vm.deal(owner3, 1 ether);

        vm.startPrank(owner1);
        accessToken.mint{value: 0.1 ether}(owner1);
        vm.stopPrank();
        
        vm.startPrank(owner2);
        accessToken.mint{value: 0.5 ether}(owner1);
        vm.stopPrank();
        
        vm.startPrank(owner3);
        accessToken.mint{value: 1 ether}(owner1);
        vm.stopPrank();
    }

    function testContractState() public {
        assertEq(accessToken.name(), name);        
        assertEq(accessToken.symbol(), symbol);        
        // assertEq(accessToken.supply(), supply);        
        // assertEq(accessToken.price(), price);     
    }

    function testMint() public {
        // vm.expectEmit();
        assertEq(accessToken.balanceOf(owner1), 1);
    }

    function testApprove() public {
        vm.startPrank(owner1);
        accessToken.approve(owner2, 1);
        vm.expectRevert("token not minted");
        accessToken.approve(owner1, 0);
        vm.expectRevert("only owner can approve");
        accessToken.approve(owner1, 2);
        vm.expectRevert("token not minted");
        accessToken.approve(owner1, 10000);
        vm.stopPrank();

        vm.startPrank(owner2);
        accessToken.transferFrom(owner1, owner3, 1);
        vm.stopPrank();
    }

    function testApproveForAll() public {
        vm.startPrank(owner2);
        accessToken.setApprovalForAll(owner1, true);
        accessToken.transferFrom(owner2, owner3, 2);
        accessToken.transferFrom(owner2, owner3, 3);
        accessToken.transferFrom(owner2, owner3, 4);
        accessToken.transferFrom(owner2, owner3, 5);
        accessToken.transferFrom(owner2, owner3, 6);
        vm.stopPrank();
        vm.startPrank(owner3);
        accessToken.transferFrom(owner3, owner1, 3);
        vm.stopPrank();
    }
    function testIsApproveForAll() public {
        vm.startPrank(owner2);
        accessToken.setApprovalForAll(owner1, true);
        assertEq(accessToken.isApprovedForAll(owner2, owner1), true);
        assertEq(accessToken.isApprovedForAll(owner2, owner3), false);
        vm.stopPrank();
    }

    function testTransferFrom() public {
        vm.startPrank(owner1);
        accessToken.transferFrom(owner1, owner3, 1);
        vm.stopPrank();
        vm.startPrank(owner3);
        accessToken.transferFrom(owner3, owner1, 1);
        vm.stopPrank();
    }
    function testSafeTransferFrom() public {
        vm.startPrank(owner1);
        accessToken.safeTransferFrom(owner1, owner3, 1);
        vm.stopPrank();
        vm.startPrank(owner3);
        accessToken.safeTransferFrom(owner3, owner1, 1);
        vm.stopPrank();
    }
 
    function testSafeTransferFromWithData() public {
        vm.startPrank(owner1);
        accessToken.safeTransferFrom(owner1, owner3, 1);
        vm.stopPrank();
        vm.startPrank(owner3);
        accessToken.safeTransferFrom(owner3, owner1, 1);
        vm.stopPrank();
    }


}
