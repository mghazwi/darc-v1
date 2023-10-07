// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
// import {Initializable} from '@openzeppelin/contracts/proxy/utils/Initializable.sol';

/**
 * @title Merkle Forests and Merkle tree Groups
 * @author MG
 * @notice This contract stores the merkle forest roots and group information 
 *         required by credential issuer so they can verify user claims
 *
 **/
contract Groups is Ownable {
  event RootRegistered(uint256 root);
  event RootUpdated(uint256 root);
  event RootUnregistered(uint256 root);
  event groupAdded(uint256 groupId, string title);
  // event groupRemoved(uint256 root, string title);

  IssuerInfo public issuer;
  uint public _root;
  mapping(uint => Group) public _groups;
  mapping(uint => bool) public groupsMapping;
  uint public GROUP_ID;

  struct IssuerInfo{
    address add;
    string name;
    string extraInfo;
  }

  struct Group {
    string title;
    string desc;
  }

  /**
   * @dev Constructor
   */
  constructor() {
    _transferOwnership(msg.sender);
    issuer.add = msg.sender;
  }

  /**
   * @dev Initializes the contract, 
   * @param name: name of issuer
   * @param extra: extra data to include in description 
   */
  function initialize(string calldata name, string calldata extra) external onlyOwner {
    issuer.name = name;
    issuer.extraInfo = extra;
  }

  /*
   * @dev Register a root
   * @param root: Root to register
   */
  function registerRoot(uint256 root) external onlyOwner {
    require(_root == 0);
    _root = root;
    emit RootRegistered(root);
  }

  /*
   * @dev update a root
   * @param root: updated Root to register
   */
  function updateRoot(uint256 root) external onlyOwner {
    require(_root != 0);
    _root = root;
    emit RootUpdated(root);
  }

  /*
   * @dev Unregister a root
   */
  function unregisterRoot() external onlyOwner {
    require(_root != 0);
    _root = 0;
    emit RootUnregistered(_root);
  }

  /*
   * @dev Register a root
   * @param root: Root to register
   */
  function addGroup(string memory title, string memory desc) external onlyOwner {
    uint g_id = GROUP_ID;
    GROUP_ID++;
    Group storage g = _groups[g_id];
    g.title = title;
    g.desc = desc;
    groupsMapping[g_id] = true;
    emit groupAdded(g_id, title);
  }

  function getGroupName(uint groupId) external view returns (string memory) {
    return _groups[groupId].title;
  }

  function getGroupDesc(uint groupId) external view returns (string memory) {
    return _groups[groupId].desc;
  }

  function isGroup(uint groupId) external view returns (bool) {
    return groupsMapping[groupId];
  }

  function getAdd() public view returns (address){
    return issuer.add;
  }

}
