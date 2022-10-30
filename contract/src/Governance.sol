// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol"; 
import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol"; 
// https://docs.openzeppelin.com/contracts/3.x/api/utils#EnumerableSet

contract Governance {

    /*//////////////////// CONFIG //////////////////*/

    using Strings for string;
    using EnumerableSet for EnumerableSet.AddressSet;

    /*//////////////////// ERRORS //////////////////*/

    error NotHolder();
    error ProposalPending();
    error ProposalFinished();
    error QuizzPending();
    error QuizzFinished();
    error ProposalAlreadyVoted();
    error QuizzAlreadyAnswered();
    
    /*//////////////////// EVENTS //////////////////*/
    
    event CreateProject(uint nonce, string name, address owner, address token);
    event CreateProposal(uint32 id, string title, address author);
    // event createQuizz();
    // event verifyProposal();
    // event verifyQuizz();

    /*//////////////////// VARIABLES //////////////////*/
    
    enum STATE {
        PENDING,
        ACTIVE,
        FINISHED
    }

    struct Project {
        uint32 id;
        string name;
        address token;
        address owner;
        EnumerableSet.AddressSet admin;
        EnumerableSet.AddressSet author;
        uint32 proposalId;
        uint32 quizzId;
        mapping(uint32 => Proposal) proposals;
        mapping(uint32 => Quizz) quizzs;
    }

    struct Proposal {
        uint32 id;
        address author;
        uint256 notice;
        uint256 length;
        uint256 start;
        string title;
        string description;
        string[] optionsArray;
        uint32[] votesArray;
        uint32 votesTotal;
        STATE state;
    }

    struct Quizz {
        uint32 id;
        address author;
        uint256 notice;
        uint256 length;
        uint256 start;
        string title;
        string description;
        string[] questions;
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

    /*//////////////////// CONSTRUCTOR //////////////////*/
    
    constructor() {
        projectNonce = 0;
    }

/*//////////////////// UTILS //////////////////*/

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


/*//////////////////// PROJECT //////////////////*/
    /*//////////////////// PROJECT GETTERS //////////////////*/
    
    function getProjectName(uint32 id) external view returns(string memory) {return _project[id].name;}
    function getProjectToken(uint32 id) external view returns(address) {return _project[id].token;}
    function getProjectOwner(uint32 id) external view returns(address) {return _project[id].owner;}
    function getIsAddrProjectAdmin(uint32 id, address addr) external view returns(bool) {return _project[id].admin.contains(addr);}
    function getIsAddrProjectAuthor(uint32 id, address addr) external view returns(bool) {return _project[id].author.contains(addr);}
    function getProjectProposalNb(uint32 id) external view returns(uint32) {return _project[id].proposalId;}
    function getProjectQuizzNb(uint32 id) external view returns(uint32) {return _project[id].quizzId;}

    
   /*//////////////////// PROJECT FUNCTIONS //////////////////*/

   modifier isAdmin(uint32 id, address addr) {
        require(_project[id].admin.contains(addr), "address isn't admin");
        _;
   }

   modifier isAuthor(uint32 id, address addr) {
        require(_project[id].author.contains(addr), "address isn't author");
        _;
   }

    function createProject(string memory name_, address token_) external returns(uint32) {
        projectNonce++;
        Project storage proj = _project[projectNonce];
        proj.id = projectNonce; 
        proj.name = name_;
        proj.token = token_;
        proj.owner = msg.sender;
        proj.admin.add(msg.sender);
        proj.author.add(msg.sender);
        proj.proposalId = 0;
        proj.quizzId = 0;
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

/*//////////////////// PROPOSAL //////////////////*/
    /*//////////////////// PROPOSAL GETTERS //////////////////*/

    function getProposalAuthor(uint32 projectId, uint32 proposalId) external view returns(address) {return _project[projectId].proposals[proposalId].author;}
    function getProposalNotice(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].notice;}
    function getProposalLength(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].length;}
    function getProposalStart(uint32 projectId, uint32 proposalId) external view returns(uint256) {return _project[projectId].proposals[proposalId].start;}
    function getProposalTitle(uint32 projectId, uint32 proposalId) external view returns(string memory) {return _project[projectId].proposals[proposalId].title;}
    function getProposalDescription(uint32 projectId, uint32 proposalId) external view returns(string memory) {return _project[projectId].proposals[proposalId].description;}
    function getProposalOptionsArray(uint32 projectId, uint32 proposalId) external view returns(string[] memory) {return _project[projectId].proposals[proposalId].optionsArray;}
    function getProposalVotesArray(uint32 projectId, uint32 proposalId) external view returns(uint32[] memory) {return _project[projectId].proposals[proposalId].votesArray;}
    function getProposalTotalVotes(uint32 projectId, uint32 proposalId) external view returns(uint32) {return _project[projectId].proposals[proposalId].votesTotal;}
    function getProposalState(uint32 projectId, uint32 proposalId) external view returns(STATE) {return _project[projectId].proposals[proposalId].state;}


    /*//////////////////// PROPOSAL FUNCTIONS //////////////////*/
    
    modifier canVote(uint32 id, address addr) {_;}
    modifier isProposalActive(uint32 id) {_;}

    function createProposal(uint32 projectId, uint256 notice, uint256 length, string memory title, string memory description) external returns(uint32) {
        uint32 proposalId = _project[projectId].proposalId + 1;
        Proposal storage prop = _project[projectId].proposals[proposalId];
        prop.id = proposalId;
        prop.author = msg.sender;
        prop.notice = notice;
        prop.length = length;
        prop.start = block.timestamp + notice + length;
        prop.title = title;
        prop.description = description;
        prop.state = STATE.PENDING;
        emit CreateProposal(prop.id, prop.title, prop.author);
        return proposalId;
    }

    function cancelProposal() external {}

    function verifyVotes(address signer, string memory message, bytes memory signature) external pure returns(bool) {
        return verifySignature(signer, message, signature);
    }


/*//////////////////// QUIZZ //////////////////*/
    /*//////////////////// QUIZZ GETTERS //////////////////*/
    /*//////////////////// QUIZZ FUNCTIONS //////////////////*/
    modifier canAnswer(uint32 id, address addr) {_;}
    modifier isQuizzActive(uint32 id) {_;}
    function createQuizz() external {}
    function cancelQuizz() external {}

    function verifyQuizz(address signer, string memory message, bytes memory signature) external pure returns(bool) {
        return verifySignature(signer, message, signature);
    }


}

/*

// create a project
// project create a proposal
// project create a quizz
// quizz is active
// front end collect users signature (messages with all answers and quizz id)
// front end send these to the servers (now firebase but later ipfs)
// servers sent tx to trigger the verification of all the signatures of the quizz (array of signatures and array of messages)
// contract is giving a score to each user