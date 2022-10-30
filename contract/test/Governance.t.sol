// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/Governance.sol";

contract GovernanceTest is Test {
    //contracts
    Governance internal governanceContract; 

    //test addresses
    address addr_1 = address(1); 
    address addr_2 = address(2); 
    address addr_3 = address(3); 
    address addr_4 = address(4); 
    address addr_5 = address(5); 

    //project var
    uint32 olympusId = 1;
    string olympusName = "project 1";
    address olympusToken = address(0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5);

    // proposals var

    function setUp() public {
        vm.startPrank(addr_1);
        governanceContract = new Governance();
        olympusId = governanceContract.createProject(olympusName, olympusToken);
        vm.stopPrank();
    }

/* TEST PROJECT */

    function testCreateProject() public {
        vm.startPrank(addr_1);
        assertEq(governanceContract.getProjectName(olympusId), olympusName);
        assertEq(governanceContract.getProjectToken(olympusId), olympusToken);
        assertEq(governanceContract.getProjectOwner(olympusId), addr_1);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_1), true);
        assertEq(governanceContract.getIsAddrProjectAuthor(olympusId, addr_1), true);
        assertEq(governanceContract.getProjectProposalNb(olympusId), 0);
        assertEq(governanceContract.getProjectQuizzNb(olympusId), 0);
        vm.stopPrank();
    }

    function testAddAdmin() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert("address isn't admin");
        governanceContract.addAdmin(olympusId, addr_2);
        vm.stopPrank();

        // addr1 is admin and add addr2 admin
        vm.startPrank(addr_1);
        governanceContract.addAdmin(olympusId, addr_2);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_2), true);
        vm.stopPrank();

        // addr2 is now admin and add addr3 admin
        vm.startPrank(addr_2);
        governanceContract.addAdmin(olympusId, addr_3);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_3), true);
        vm.stopPrank();
    }

    function testRemoveAdmin() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert("address isn't admin");
        governanceContract.removeAdmin(olympusId, addr_1);
        vm.stopPrank();

        // addr1 is admin and makes addr2 admin
        vm.startPrank(addr_1);
        governanceContract.addAdmin(olympusId, addr_2);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_2), true);
        vm.stopPrank();

        //addr2 is admin and remove addr1 admin
        vm.startPrank(addr_2);
        governanceContract.removeAdmin(olympusId, addr_1);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_1), false);
        vm.stopPrank();
    }

    function testAddAuthor() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert("address isn't admin");
        governanceContract.addAuthor(olympusId, addr_2);
        vm.stopPrank();

        // addr1 is admin and add addr2 admin
        vm.startPrank(addr_1);
        governanceContract.addAdmin(olympusId, addr_2);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_2), true);
        vm.stopPrank();

        // addr2 is now admin and add addr2 author
        vm.startPrank(addr_2);
        governanceContract.addAuthor(olympusId, addr_2);
        assertEq(governanceContract.getIsAddrProjectAuthor(olympusId, addr_2), true);
        vm.stopPrank();
    }

    function testRemoveAuthor() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert("address isn't admin");
        governanceContract.removeAuthor(olympusId, addr_1);
        vm.stopPrank();

        // addr1 is admin and makes addr2 admin
        vm.startPrank(addr_1);
        governanceContract.addAdmin(olympusId, addr_2);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_2), true);
        vm.stopPrank();

        //addr2 is admin and remove addr1 author
        vm.startPrank(addr_2);
        governanceContract.removeAuthor(olympusId, addr_1);
        assertEq(governanceContract.getIsAddrProjectAuthor(olympusId, addr_1), false);
        vm.stopPrank();

    }

/* TEST PROPOSAL */

    function testCreateProposal() public {}
    function testVerifyProposal() public {}

/* TEST QUIZZ */

    function testVerifyQuizz() public {
        
    }
}

/*



*/