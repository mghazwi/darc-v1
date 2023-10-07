// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Initializable} from '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {Groups} from './Groups.sol';
import {Verifier} from './verifier/verifier.sol';
import {CredRegistry} from './CredRegistry.sol';

/**
 * @title Verifiable Credential contract
 * @author Mohammed Alghazwi
 * @notice 
 */
contract DARC is Initializable, AccessControl {

  event IssuerRegistered(uint256 issuerId ,uint256 root);
  event IssuerUpdated(uint256 issuerId ,uint256 root);
  event verifierAdded(address verifierAddress);
  event RegistryAdded(address registryAddress);
  
  CredRegistry internal _CredRegistry; // registry contract
  mapping (uint => Groups) internal issuers; // maps issuerId to Groups address
  uint private ISSUER_ID; //counter to generate unique issuerId
  Verifier internal VERIFIER; //verifier contract
  uint private validity = 2592000; // validity of the credential ~ 30 days

  /**
   * @dev Constructor
   * @param owner Owner of the contract, super admin, can setup roles and update the attestation registry
   */
  constructor(
    address owner // This is Sismo Frontend Contract
  ) {
    initialize(owner);
  }

  /**
   * @dev Initializes the contract
   * @param owner Owner of the contract, super admin, can setup roles and update the attestation registry
   */
  function initialize(
    address owner
  ) public {
    if (address(this).code.length == 0) {
      _grantRole(DEFAULT_ADMIN_ROLE, owner);
    }
  }
  
  /*******************************************************
    Issuer FUNCTIONS
  *******************************************************/

  /** 
   * @dev add the address of the groups contract containing the issuer details, merkle tree root, and group info. Can only be called by owner (default admin)
   * @param groupsAddress: address of groups contract
   */
  function addIssuer(
    address groupsAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint i_id = ISSUER_ID;
    ISSUER_ID++;
    issuers[i_id] = Groups(groupsAddress);
  }

  /**
   * @dev update the address of the groups contract containing the issuer details, merkle tree root, and group info. Can only be called by owner (default admin)
   * @param groupsAddress: new address of groups contract
   */
  function UpdateIssuer(
    uint i_id,
    address groupsAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    issuers[i_id] = Groups(groupsAddress);
  }

  /*******************************************************
    Registry FUNCTIONS
  *******************************************************/

  /** 
   * @dev Set the credential registry address. Can only be called by owner (default admin)
   * @param registry: new credential registry address
   */
  function setCredRegistry(
    address registry
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _CredRegistry = CredRegistry(registry);
  }

  /**
   * @dev Getter of the Cred registry
   */
  function getCredRegistry() external view returns (address) {
    return address(_CredRegistry);
  }

  /*******************************************************
    Verifier FUNCTIONS
  *******************************************************/
  /**
   * @dev set the address of the snarks verifier address. Can only be called by owner (default admin)
   * @param verifierAddress: address of verifier contract
   */
  function setVerifier(
    address verifierAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    VERIFIER = Verifier(verifierAddress);
  }

  /*******************************************************
    Request FUNCTIONS
  *******************************************************/

  /**
   * @dev function can be called to request a credential given request input and proof.
   * @param a: part of the proof
   * @param b: part of the proof
   * @param c: part of the proof
   * @param input: public input to the ZKP circuit
   * @param issuerId: user claims to have a credential from this issuer
   * @param groupId: user claims to have an account in this group
   * @param claimedValue: user claims this value for its account in the group
   * @param recipient: the address of the credential recipient
   */
  function RequestCred(
    uint256[2] calldata a,
    uint256[2][2] calldata b,
    uint256[2] calldata c,
    uint256[2] calldata input,
    uint256 issuerId,
    uint256 groupId, 
    uint256 claimedValue, 
    address recipient
  ) public {
    // verifies the proof validity
    _validateInput(issuerId,groupId,claimedValue,input);
    require(_verifyProof(a,b,c,input));
    //build credential
    _buildCredential(issuerId,groupId,claimedValue, recipient);
  }

  /*******************************************************
    verification FUNCTIONS
  *******************************************************/

  /**
   * @dev Checks whether the user claim and the snark public input are a match
   * @param input: public input to the ZKP circuit
   * @param issuerId: user claims to have a credential from this issuer
   * @param groupId: user claims to have an account in this group
   * @param claimedValue: user claims this value for its account in the group
   */
  function _validateInput(
    uint256 issuerId,
    uint256 groupId,
    uint256 claimedValue,
    uint256[2] calldata input
  ) internal view {
    require (input[1] == groupId);
    Groups g = issuers[issuerId];
    require (g._root() == input[0]);
    // check group exists
    require(g.isGroup(groupId));
  }

  /**
   * @dev verify the snark proof
   * @param a: part of the proof
   * @param b: part of the proof
   * @param c: part of the proof
   * @param input: public input to the ZKP circuit
   */
  function _verifyProof(
    uint256[2] calldata a,
    uint256[2][2] calldata b,
    uint256[2] calldata c,
    uint256[2] calldata input) internal view returns (bool){
    return VERIFIER.verifyProof(a, b, c, input);
  }

  /*******************************************************
    Generate Cred FUNCTIONS
  *******************************************************/

  /**
   * @dev record the credential in the registy, constructed from the user request
   * @param issuerId: user claims to have a credential from this issuer
   * @param groupId: user claims to have an account in this group
   * @param claimedValue: user claims this value for its account in the group
   * @param recipient: the address of the credential recipient
   */
    function _buildCredential(
    uint256 issuerId,
    uint256 groupId, 
    uint256 claimedValue, 
    address recipient
  ) internal {

    // get info from the group
    Groups i = issuers[issuerId]; 
    string memory attributeName = i.getGroupName(groupId);
    // send build request to Registry
    _CredRegistry.setAttribute(recipient ,i.getAdd(),attributeName,claimedValue, validity);

  }


}
