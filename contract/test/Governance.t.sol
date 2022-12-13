// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../src/Governance.sol";
import "../src/AccessToken.sol";

contract GovernanceTest is Test {
/* CONTRACTS */
    Governance internal governanceContract; 
    AccessToken internal accessToken; 
/* TEST ADDRESSES */
    address addr_1 = address(1); 
    address addr_2 = address(2); 
    address addr_3 = address(3); 
    address addr_4 = address(4); 
    address addr_5 = address(5); 

/* ENUMS */
    enum STATE {
        PENDING,
        ACTIVE,
        FINISHED,
        CANCELED
    }

/* PROJECT VARIABLES */
    uint32 olympusId;
    string olympusName = "olympus";
    string olympusSymbol = "ohm";
    uint8 olympusBoost = 10;

/* PROPOSAL VARIABLES */
    uint32 olympusProposalOne;
    uint256 proposalOneNotice = 3 days; 
    uint256 proposalOneLength = 5 days;
    string proposalOneTitle = "proposal one";
    string proposalOneDescription = "proposal one description";
    string[] proposalOptions = ["option 1", "option 2", "option 3", "option 4", "option 5"];
    uint32[] proposalVotes = [0, 0, 0, 0, 0];
    uint32 testProposalIndex = 1;

/* QUIZZ VARIABLES */
    uint32 olympusQuizzOne;
    uint256 quizzOneNotice = 3 days; 
    uint256 quizzOneLength = 5 days;
    string quizzOneTitle = "quizz one";
    string quizzOneDescription = "quizz one description";
    string[] quizzOneQuestions = ["question 1", "question 2", "question 3", "question 4", "question 5"];
    string[][] quizzOneChoices = [["1-1", "1-2", "1-3"], ["2-1", "2-2", "2-3"], ["3-1", "3-2", "3-3"], ["4-1", "4-2", "4-3"], ["5-1", "5-2", "5-3"]];
    string[][] quizzOneBadChoices = [["1-1", "1-2", "1-3"], ["2-1", "2-2", "2-3"], ["3-1", "3-2", "3-3"], ["4-1", "4-2", "4-3"]];
    uint8[] quizzOneAnswers = [1, 3, 2, 1, 3];
    uint8[] quizzOneBadAnswers = [1, 3, 2, 1];
    uint32 testQuizzIndex = 1;

/* REVERT VALUES */

    bytes notAdmin = "address isn't admin";
    bytes missingToken = "address don't hold access token";

    bytes notProposalAuthor = "need to be author of proposal to cancel it";
    bytes inactiveProposal = "can't vote on an inactive proposal";
    bytes alreadyVoted = "address has already voted";
    bytes cantCancelActiveProposal = "cant cancel an ongoing or finished proposal";

    bytes notQuizzAuthor = "need to be author of quizz to cancel it";
    bytes inactiveQuizz = "can't vote on an unactive quizz";
    bytes alreadyAnswered = "address has already voted";
    bytes cantCancelActiveQuizz = "cant cancel an ongoing or finished quizz";

    bytes quizzBadInput1 = "array size mismatch";
    bytes quizzBadInput2 = "number of answers provided don't match quizz number of questions";

/* SETUP */

    function setUp() public {
        vm.startPrank(addr_1);
        governanceContract = new Governance();
        olympusId = governanceContract.createProject(olympusName, olympusSymbol, olympusBoost);
        olympusProposalOne = governanceContract.createProposal(olympusId, proposalOneNotice, proposalOneLength, proposalOneTitle, proposalOneDescription, proposalOptions);
        olympusQuizzOne = governanceContract.createQuizz(olympusId, quizzOneNotice, quizzOneLength, quizzOneTitle, quizzOneDescription, quizzOneQuestions, quizzOneChoices);
        vm.stopPrank();
    }


/* TEST PROJECT */
    /* CREATE */
    function testCreateProject() public {
        vm.startPrank(addr_1);
        assertEq(governanceContract.getProjectName(olympusId), olympusName);
        assertEq(governanceContract.getProjectOwner(olympusId), addr_1);
        assertEq(governanceContract.getIsAddrProjectAdmin(olympusId, addr_1), true);
        assertEq(governanceContract.getIsAddrProjectAuthor(olympusId, addr_1), true);
        assertEq(governanceContract.getProjectProjectBoost(olympusId), olympusBoost);
        assertEq(governanceContract.getProjectProposalNb(olympusId), 0);
        assertEq(governanceContract.getProjectQuizzNb(olympusId), 0);
        vm.stopPrank();
    }
    /* ADMIN */
    function testAddAdmin() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert(notAdmin);
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
        vm.expectRevert(notAdmin);
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
    /* AUTHOR */
    function testAddAuthor() public {
        // addr2 isn't admin
        vm.startPrank(addr_2);
        vm.expectRevert(notAdmin);
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
        vm.expectRevert(notAdmin);
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

    /* CREATE */
    function testCreateProposal() public {
        assertEq(governanceContract.getProposalProjectId(olympusId, olympusProposalOne), olympusId);
        assertEq(governanceContract.getProposalAuthor(olympusId, olympusProposalOne), addr_1);
        assertEq(governanceContract.getProposalNotice(olympusId, olympusProposalOne), proposalOneNotice);
        assertEq(governanceContract.getProposalLength(olympusId, olympusProposalOne), proposalOneLength);
        assertEq(governanceContract.getProposalStart(olympusId, olympusProposalOne), block.timestamp + proposalOneNotice);
        assertEq(governanceContract.getProposalTitle(olympusId, olympusProposalOne), proposalOneTitle);
        assertEq(governanceContract.getProposalDescription(olympusId, olympusProposalOne), proposalOneDescription);
        for (uint32 i = 0; i < proposalOptions.length; i++) {
            assertEq(governanceContract.getProposalOptionsAtIndex(olympusId, olympusProposalOne, i), proposalOptions[i]);
            assertEq(governanceContract.getProposalVotesAtIndex(olympusId, olympusProposalOne, i), proposalVotes[i]);
        }
        assertEq(governanceContract.getProposalTotalVotes(olympusId, olympusProposalOne), 0);
        assertEq(uint256(governanceContract.getProposalState(olympusId, olympusProposalOne)), uint256(STATE.PENDING));
    }
    /* CANCEL */
    function testCancelActiveProposalByAuthor() public {
        vm.startPrank(addr_1);
        vm.warp(proposalOneNotice + 1);
        vm.expectRevert(cantCancelActiveProposal);
        governanceContract.cancelProposal(olympusId, olympusProposalOne);
        vm.stopPrank();
    }
    function testCancelActiveProposalByNotAuthor() public {
        vm.startPrank(addr_5);
        vm.warp(proposalOneNotice);
        vm.expectRevert(notProposalAuthor);
        governanceContract.cancelProposal(olympusId, olympusProposalOne);
        vm.stopPrank();
    }
    function testCancelInactiveProposalByAuthor() public {
        vm.startPrank(addr_1);
        governanceContract.cancelProposal(olympusId, olympusProposalOne);
        vm.stopPrank();
    }
    function testCancelInactiveProposalByNotAuthor() public {
        vm.startPrank(addr_5);
        vm.expectRevert(notProposalAuthor);
        governanceContract.cancelProposal(olympusId, olympusProposalOne);
        vm.stopPrank();
    }
    /* VOTE */
    function testVoteOnActiveProposalWithAccessToken() public {
        vm.startPrank(addr_1);
        vm.warp(governanceContract.getProposalNotice(olympusId, olympusProposalOne) + 1);
        assertEq(governanceContract.getProposalVotesAtIndex(olympusId, olympusProposalOne, testProposalIndex), 0);
        assertEq(governanceContract.getProposalTotalVotes(olympusId, olympusProposalOne), 0);
        governanceContract.voteOnProposal(olympusId, olympusProposalOne, testProposalIndex);
        assertEq(governanceContract.getProposalVotesAtIndex(olympusId, olympusProposalOne, testProposalIndex), 1);
        assertEq(governanceContract.getProposalTotalVotes(olympusId, olympusProposalOne), 1);
        vm.stopPrank();
    }
    function testVoteOnActiveProposalWithoutAccessToken() public {
        vm.startPrank(addr_5);
        vm.warp(governanceContract.getProposalNotice(olympusId, olympusProposalOne) + 1);
        vm.expectRevert(missingToken);
        governanceContract.voteOnProposal(olympusId, olympusProposalOne, testProposalIndex);
        vm.stopPrank();
    }
    function testVoteOnInactiveProposal() public {
        vm.expectRevert(inactiveProposal);  
        governanceContract.voteOnProposal(olympusId, olympusProposalOne, testProposalIndex);
    }
    function testVoteTwiceOnProposal() public {
        vm.startPrank(addr_1);
        vm.warp(governanceContract.getProposalNotice(olympusId, olympusProposalOne) + 1);
        governanceContract.voteOnProposal(olympusId, olympusProposalOne, testProposalIndex);
        vm.expectRevert(alreadyVoted);
        governanceContract.voteOnProposal(olympusId, olympusProposalOne, testProposalIndex);
        vm.stopPrank();
    }


/* TEST QUIZZ */

    /* CREATE */
    function testCreateQuizz() public {
        assertEq(governanceContract.getQuizzProjectId(olympusId, olympusQuizzOne), olympusId);
        assertEq(governanceContract.getQuizzAuthor(olympusId, olympusQuizzOne), addr_1);
        assertEq(governanceContract.getQuizzNotice(olympusId, olympusQuizzOne), quizzOneNotice);
        assertEq(governanceContract.getQuizzLength(olympusId, olympusQuizzOne), quizzOneLength);
        assertEq(governanceContract.getQuizzStart(olympusId, olympusQuizzOne), block.timestamp + quizzOneNotice);
        assertEq(governanceContract.getQuizzTitle(olympusId, olympusQuizzOne), quizzOneTitle);
        assertEq(governanceContract.getQuizzDescription(olympusId, olympusQuizzOne), quizzOneDescription);
        for (uint32 i = 0; i < quizzOneQuestions.length; i++) {
            assertEq(governanceContract.getQuizzQuestionAtIndex(olympusId, olympusQuizzOne, i), quizzOneQuestions[i]);
        }
        assertEq(uint256(governanceContract.getQuizzState(olympusId, olympusQuizzOne)), uint256(STATE.PENDING));
    }
    function testCreateQuizzWithBadArraySize() public {
        vm.startPrank(addr_5);   
        vm.expectRevert(quizzBadInput1);
        olympusQuizzOne = governanceContract.createQuizz(olympusId, quizzOneNotice, quizzOneLength, quizzOneTitle, quizzOneDescription, quizzOneQuestions, quizzOneBadChoices);
        vm.stopPrank();
    }
    /* CANCEL */
    function testCancelActiveQuizzByAuthor() public {
        vm.startPrank(addr_1);
        vm.warp(quizzOneNotice + 1);
        vm.expectRevert(cantCancelActiveQuizz);
        governanceContract.cancelQuizz(olympusId, olympusQuizzOne);
        vm.stopPrank();
    }
    function testCancelActiveQuizzByNotAuthor() public {
        vm.startPrank(addr_5);
        vm.warp(quizzOneNotice + 1);
        vm.expectRevert(notQuizzAuthor);
        governanceContract.cancelQuizz(olympusId, olympusQuizzOne);
        vm.stopPrank();
    }
    function testCancelInactiveQuizzByAuthor() public {
        vm.startPrank(addr_1);
        governanceContract.cancelQuizz(olympusId, olympusQuizzOne);
        vm.stopPrank();
    }
    function testCancelInactiveQuizzByNotAuthor() public {
        vm.startPrank(addr_5);
        vm.expectRevert(notQuizzAuthor);
        governanceContract.cancelQuizz(olympusId, olympusQuizzOne);
        vm.stopPrank();
    }
    /* ANSWER */
    function testAnswerQuizzHoldingToken() public {
        vm.startPrank(addr_1);
        vm.warp(quizzOneNotice + 1);
        governanceContract.answerQuizz(olympusId, olympusQuizzOne, quizzOneAnswers);
        for (uint32 index = 0; index < quizzOneAnswers.length; index++) {
            assertEq(governanceContract.getQuizzAnswerAtIndex(olympusId, olympusQuizzOne, index), quizzOneAnswers[index]);
        }
        vm.stopPrank();
    }
    function testAnswerQuizzWithoutHoldingToken() public {
        vm.startPrank(addr_5);
        vm.warp(quizzOneNotice + 1);
        vm.expectRevert(missingToken);
        governanceContract.answerQuizz(olympusId, olympusQuizzOne, quizzOneAnswers);
        vm.stopPrank();
    }
    function testAnswerQuizzWithInvalidAnswerNb() public {
        vm.startPrank(addr_1);
        vm.warp(quizzOneNotice + 1);
        vm.expectRevert(quizzBadInput2);
        governanceContract.answerQuizz(olympusId, olympusQuizzOne, quizzOneBadAnswers);
        vm.stopPrank();
    }
}