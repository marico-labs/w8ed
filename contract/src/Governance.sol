// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol"; 
import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol"; 
import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol"; 

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./AccessToken.sol";

import "../lib/forge-std/src/console.sol";
// https://docs.openzeppelin.com/contracts/3.x/api/utils#EnumerableSet

contract Governance {

/* //////////////////// CONFIG ////////////////// */

    using Strings for string;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

/* //////////////////// ERRORS ////////////////// */

    error NotHolder();
    error ProposalPending();
    error ProposalFinished();
    error QuizzPending();
    error QuizzFinished();
    error ProposalAlreadyVoted();
    error QuizzAlreadyAnswered();
    
/* //////////////////// EVENTS ////////////////// */
    
    event CreateProject(uint nonce, string name, address owner, address token);
    
    event CreateProposal(uint32 id, string title, address author);
    event CancelProposal(uint32 id, string title, address author);
    event VoteOnProposal(uint32 id, string title, address author);
    
    event CreateQuizz(uint32 id, string title, address author);
    event CancelQuizz(uint32 id, string title, address author);
    event AnswerQuizz(uint32 id, string title, address author);

/* //////////////////// VARIABLES ////////////////// */
    
    enum STATE {
        PENDING,
        ACTIVE,
        FINISHED,
        CANCELED
    }

    struct Project {
        uint32 id;
        string name;
        address token;
        address owner;
        EnumerableSet.AddressSet admin;
        EnumerableSet.AddressSet author;
        uint8 boost;
        uint32 proposalId;
        uint32 quizzId;
        mapping(uint32 => Proposal) proposals;
        mapping(uint32 => Quizz) quizzs;
    }

    struct Proposal {
        uint32 id;
        uint32 projectId;
        address author;
        uint256 notice;
        uint256 length;
        uint256 start;
        string title;
        string description;
        string[] options;
        uint32[] votes;
        uint32[] votesBoosted;
        uint32[] votesWeighted;
        uint32[] votesWeightedAndBoosted;
        mapping(address => bool) userVoted;
        uint32 totalVotes;
        STATE state;
    }

    struct Quizz {
        uint32 id;
        uint32 projectId;
        address author;
        uint256 notice;
        uint256 length;
        uint256 start;
        string title;
        string description;
        string[] questions;
        string[][] choices;
        uint8[] answers;
        mapping(address => bool) userAnswered;
        mapping(uint => User) scores;
        STATE state;
    }
    struct User {
        address addr;
        uint8 level;
        uint8 boost;
    }

    uint32 projectNonce;
    mapping(uint32 => Project) private _project;
    mapping(address => User) private _user;

/* //////////////////// CONSTRUCTOR ////////////////// */
    
    constructor() {
        projectNonce = 0;
    }

/* //////////////////// UTILS ////////////////// */

    // for future refactor transaction flow to signature - pending client side refactor

    function getMsgHash(string memory message) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(message));
    }
    function getEthSignedMsgHash(bytes32 messageHash) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
    function _split(bytes memory signature) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(signature.length == 65, "invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
    function recover(bytes32 ethSignedMsgHash, bytes memory signature) internal pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(signature);
        return ecrecover(ethSignedMsgHash, v, r, s);
    }
    function verifySignature(address signer, string memory message, bytes memory signature) internal pure returns(bool) {
        bytes32 msgHash = getMsgHash(message);
        bytes32 ethSignedMsgHash = getEthSignedMsgHash(msgHash);

        return recover(ethSignedMsgHash, signature) == signer;
    }
    function verifyVotes(address signer, string memory message, bytes memory signature) external pure returns(bool) {
        return verifySignature(signer, message, signature);
    }
    function verifyQuizz(address signer, string memory message, bytes memory signature) external pure returns(bool) {
        return verifySignature(signer, message, signature);
    }

/* //////////////////// PROJECT GETTERS ////////////////// */
    
    function getProjectName(uint32 id) external view returns(string memory) {return _project[id].name;}
    function getProjectToken(uint32 id) external view returns(address) {return _project[id].token;}
    function getProjectOwner(uint32 id) external view returns(address) {return _project[id].owner;}
    function getIsAddrProjectAdmin(uint32 id, address addr) external view returns(bool) {return _project[id].admin.contains(addr);}
    function getIsAddrProjectAuthor(uint32 id, address addr) external view returns(bool) {return _project[id].author.contains(addr);}
    function getProjectProjectBoost(uint32 id) external view returns(uint8) {return _project[id].boost;}
    function getProjectProposalNb(uint32 id) external view returns(uint32) {return _project[id].proposalId;}
    function getProjectQuizzNb(uint32 id) external view returns(uint32) {return _project[id].quizzId;}

/* //////////////////// PROJECT FUNCTIONS ////////////////// */

    modifier isAdmin(uint32 id, address addr) {
        require(_project[id].admin.contains(addr), "address isn't admin");
        _;
    }

    function createProject(string memory name_, string memory symbol_, uint8 boost_) external returns(uint32) {
        projectNonce++;
        Project storage proj = _project[projectNonce];
        proj.id = projectNonce; 
        proj.name = name_;
        proj.token = address(new AccessToken(name_, symbol_));
        proj.owner = msg.sender;
        proj.admin.add(msg.sender);
        proj.author.add(msg.sender);
        proj.boost = boost_;
        proj.proposalId = 0;
        proj.quizzId = 0;
        (bool success, /*..*/) = proj.token.call(abi.encodeWithSignature("mint(address)", msg.sender));
        require(success == true, "failed to mint token for owner");
        emit CreateProject(proj.id, proj.name, proj.owner, proj.token);
        return projectNonce;
    }

    function addAdmin(uint32 id, address addr) external isAdmin(id, msg.sender) {
        _project[id].admin.add(addr);
    }

    function removeAdmin(uint32 id, address addr) external isAdmin(id, msg.sender) {
        _project[id].admin.remove(addr);
    }

    function addAuthor(uint32 id, address addr) external isAdmin(id, msg.sender) {
        _project[id].author.add(addr);
    }

    function removeAuthor(uint32 id, address addr) external isAdmin(id, msg.sender) {
        _project[id].author.remove(addr);
    }

/* //////////////////// PROPOSAL GETTERS ////////////////// */

    function getProposalProjectId(uint32 projectId, uint32 proposalId) external view returns(uint32) {return _project[projectId].proposals[proposalId].projectId;}
    function getProposalAuthor(uint32 projectId, uint32 proposalId) external view returns(address) {return _project[projectId].proposals[proposalId].author;}
    function getProposalNotice(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].notice;}
    function getProposalLength(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].length;}
    function getProposalStart(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].start;}
    function getProposalTitle(uint32 projectId, uint32 proposalId) external view returns(string memory) {return _project[projectId].proposals[proposalId].title;}
    function getProposalDescription(uint32 projectId, uint32 proposalId) external view returns(string memory) {return _project[projectId].proposals[proposalId].description;}
    function getProposalOptionsAtIndex(uint32 projectId, uint32 proposalId, uint32 index) external view returns(string memory) {return _project[projectId].proposals[proposalId].options[index];}
    function getProposalVotesAtIndex(uint32 projectId, uint32 proposalId, uint32 index) external view returns(uint32) {return _project[projectId].proposals[proposalId].votes[index];}
    function getProposalUserVoted(uint32 projectId, uint32 proposalId, address addr) external view returns(bool) {return _project[projectId].proposals[proposalId].userVoted[addr];}
    function getProposalTotalVotes(uint32 projectId, uint32 proposalId) external view returns(uint32) {return _project[projectId].proposals[proposalId].totalVotes;}
    function getProposalState(uint32 projectId, uint32 proposalId) external view returns(STATE) {return _project[projectId].proposals[proposalId].state;}

/* //////////////////// PROPOSAL FUNCTIONS ////////////////// */
    
    modifier isProposalAuthor(uint32 projectId, uint32 proposalId, address addr) {
        require(_project[projectId].proposals[proposalId].author == addr, "need to be author of proposal to cancel it");
        _;
    }
    modifier canVote(uint32 projectId, uint32 proposalId, address addr) {
        updateProposalState(projectId, proposalId);
        require(_project[projectId].proposals[proposalId].state == STATE.ACTIVE, "can't vote on an inactive proposal");
        (bool success, bytes memory data) = _project[projectId].token.call(abi.encodeWithSignature("balanceOf(address)", addr));
        require(success == true, "holder verification failed");
        require(uint256(bytes32(data)) > 0, "address don't hold access token");
        require(_project[projectId].proposals[proposalId].userVoted[addr] == false, "address has already voted");
        _;
    }
    function updateProposalState(uint32 projectId, uint32 proposalId) internal {
        Proposal storage prop = _project[projectId].proposals[proposalId];
        if (prop.state == STATE.PENDING) {
            if (block.timestamp >= prop.start)
                prop.state = STATE.ACTIVE;
        }
        if (prop.state == STATE.ACTIVE) {
            if (block.timestamp > prop.start + prop.length) {
                prop.state = STATE.FINISHED;
            }
        }
    }
    function createProposal(uint32 projectId, uint256 notice, uint256 length, string memory title, string memory description, string[] memory _options) external returns(uint32) {
        uint32 proposalId = _project[projectId].proposalId + 1;
        Proposal storage prop = _project[projectId].proposals[proposalId];
        prop.id = proposalId;
        prop.projectId = projectId;
        prop.author = msg.sender;
        prop.notice = notice;
        prop.length = length;
        prop.start = block.timestamp + notice;
        prop.title = title;
        prop.description = description;
        prop.options = _options;
        prop.votes = new uint32[](_options.length);
        prop.votesBoosted = new uint32[](_options.length);
        prop.votesWeighted = new uint32[](_options.length);
        prop.votesWeightedAndBoosted = new uint32[](_options.length);
        prop.totalVotes = 0;
        prop.state = STATE.PENDING;
        emit CreateProposal(prop.id, prop.title, prop.author);
        return proposalId;
    }
    function cancelProposal(uint32 projectId, uint32 proposalId) isProposalAuthor(projectId, proposalId, msg.sender) external {
        updateProposalState(projectId, proposalId);
        require(_project[projectId].proposals[proposalId].state == STATE.PENDING, "cant cancel an ongoing or finished proposal");
        _project[projectId].proposals[proposalId].state = STATE.CANCELED;
        emit CancelProposal(_project[projectId].proposals[proposalId].id, _project[projectId].proposals[proposalId].title, _project[projectId].proposals[proposalId].author);

    }
    /** @dev this function goal is to look on the last n proposal how many time the user has voted **/
    function computeUserBoost(uint32 projectId, uint32 proposalId, address addr) internal view returns(uint8) {
        uint32 index = 0;
        uint8 returnValue = 0;
        proposalId < _project[projectId].boost ? index = proposalId : index = _project[projectId].boost;
        for (index; index > 0; index--) {
            if (_project[projectId].proposals[index].userVoted[addr] == true)
                returnValue += 1;
        }
        return returnValue;
    } 
    function voteOnProposal(uint32 projectId, uint32 proposalId, uint32 optionId) canVote(projectId, proposalId, msg.sender) external {
        _project[projectId].proposals[proposalId].totalVotes += 1;
        _project[projectId].proposals[proposalId].votes[optionId] += 1;
        _project[projectId].proposals[proposalId].userVoted[msg.sender] = true;
        _project[projectId].proposals[proposalId].votesBoosted[optionId] += 1 * computeUserBoost(projectId, proposalId, msg.sender);
        _project[projectId].proposals[proposalId].votesWeighted[optionId] += 1 * _user[msg.sender].level;
        _project[projectId].proposals[proposalId].votesWeightedAndBoosted[optionId] += 1 * _user[msg.sender].level * computeUserBoost(projectId, proposalId, msg.sender);
        emit VoteOnProposal(_project[projectId].proposals[proposalId].id, _project[projectId].proposals[proposalId].title, _project[projectId].proposals[proposalId].author);
    }


/* //////////////////// QUIZZ GETTERS ////////////////// */

    function getQuizzProjectId(uint32 projectId, uint32 quizzId) external view returns(uint32) {return _project[projectId].quizzs[quizzId].projectId;}
    function getQuizzAuthor(uint32 projectId, uint32 quizzId) external view returns(address) {return _project[projectId].quizzs[quizzId].author;}
    function getQuizzNotice(uint32 projectId, uint32 quizzId) external view returns(uint256) {return _project[projectId].quizzs[quizzId].notice;}
    function getQuizzLength(uint32 projectId, uint32 quizzId) external view returns(uint256) {return _project[projectId].quizzs[quizzId].length;}
    function getQuizzStart(uint32 projectId, uint32 quizzId) external view returns(uint256) {return _project[projectId].quizzs[quizzId].start;}
    function getQuizzTitle(uint32 projectId, uint32 quizzId) external view returns(string memory) {return _project[projectId].quizzs[quizzId].title;}
    function getQuizzDescription(uint32 projectId, uint32 quizzId) external view returns(string memory) {return _project[projectId].quizzs[quizzId].description;}
    function getQuizzQuestionAtIndex(uint32 projectId, uint32 quizzId, uint32 index) external view returns(string memory) {return _project[projectId].quizzs[quizzId].questions[index];}
    function getQuizzChoiceAtIndex(uint32 projectId, uint32 quizzId, uint32 index) external view returns(string[] memory) {return _project[projectId].quizzs[quizzId].choices[index];}
    function getQuizzAnswerAtIndex(uint32 projectId, uint32 quizzId, uint32 index) external view returns(uint8) {return _project[projectId].quizzs[quizzId].answers[index];}
    function getQuizzState(uint32 projectId, uint32 quizzId) external view returns(STATE) {return _project[projectId].quizzs[quizzId].state;}


/* //////////////////// QUIZZ FUNCTIONS ////////////////// */
    
        
    modifier isQuizzAuthor(uint32 projectId, uint32 quizzId, address addr) {
        require(_project[projectId].quizzs[quizzId].author == addr, "need to be author of quizz to cancel it");
        _;
    }

    modifier canAnswerQuizz(uint32 projectId, uint32 quizzId, address addr) {
        updateQuizzState(projectId, quizzId);
        require(_project[projectId].quizzs[quizzId].state == STATE.ACTIVE, "can't vote on an inactive quizz");
        (bool success, bytes memory data) = _project[projectId].token.call(abi.encodeWithSignature("balanceOf(address)", addr));
        require(success == true, "holder verification failed");
        require(uint256(bytes32(data)) > 0, "address don't hold access token");
        require(_project[projectId].quizzs[quizzId].userAnswered[addr] == false, "address has already answered this quizz");
        _;
    }

    function updateQuizzState(uint32 projectId, uint32 quizzId) internal {
        Quizz storage quizz = _project[projectId].quizzs[quizzId];
        if (quizz.state == STATE.PENDING) {
            if (block.timestamp >= quizz.start)
                quizz.state = STATE.ACTIVE;
        }
        if (quizz.state == STATE.ACTIVE) {
            if (block.timestamp > quizz.start + quizz.length)
                quizz.state = STATE.FINISHED;
        }
    }

    function createQuizz(uint32 projectId, uint256 notice, uint256 length, string memory title, string memory description, string[] memory questions, string[][] memory choices) external returns(uint32) {
        require(questions.length == choices.length, "array size mismatch");
        uint32 quizzId = _project[projectId].quizzId + 1;
        Quizz storage quizz = _project[projectId].quizzs[quizzId];
        quizz.id = quizzId;
        quizz.projectId = projectId;
        quizz.author = msg.sender;
        quizz.notice = notice;
        quizz.length = length;
        quizz.start = block.timestamp + notice;
        quizz.title = title;
        quizz.description = description;
        quizz.questions = questions;
        quizz.choices = choices;
        quizz.answers = new uint8[](questions.length);
        quizz.state = STATE.PENDING;
        emit CreateQuizz(quizz.id, quizz.title, msg.sender);
        return quizzId;
    }

    function cancelQuizz(uint32 projectId, uint32 quizzId) isQuizzAuthor(projectId, quizzId, msg.sender) external {
        updateQuizzState(projectId, quizzId);
        require(_project[projectId].quizzs[quizzId].state == STATE.PENDING, "cant cancel an ongoing or finished quizz");
        _project[projectId].quizzs[quizzId].state = STATE.CANCELED;
        emit CancelQuizz(_project[projectId].quizzs[quizzId].id, _project[projectId].quizzs[quizzId].title, msg.sender);
    }

    function answerQuizz(uint32 projectId, uint32 quizzId, uint8[] memory answers) canAnswerQuizz(projectId, quizzId, msg.sender) external {
        require(_project[projectId].quizzs[quizzId].answers.length == answers.length, "number of answers provided don't match quizz number of questions");
        _project[projectId].quizzs[quizzId].answers = answers;
        _project[projectId].quizzs[quizzId].userAnswered[msg.sender] = true;
        emit AnswerQuizz(_project[projectId].quizzs[quizzId].id, _project[projectId].quizzs[quizzId].title, msg.sender);
    }

}

/*
    add signatures
    add delegation
    add zero knowledge
*/
