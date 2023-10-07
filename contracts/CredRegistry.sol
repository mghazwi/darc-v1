/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

/**
 * @title Credential Registry contract
 * @author Mohammed Alghazwi
 * @notice Credential attributes are only stored as events for off-chain usage
 *         modified version of the EthereumDIDRegistry: https://github.com/uport-project/ethr-did-registry
 */

//[TODO]: add access control from openZapplin 

contract CredRegistry {

  mapping(address => address) public owners;
  mapping(address => mapping(bytes32 => mapping(address => uint))) public delegates;
  mapping(address => uint) public changed;
  mapping(address => uint) public nonce;
  mapping(address => bool) public approved; // list of approved issuer contracts

  modifier onlyOwner(address identity, address actor) {
    require (actor == identityOwner(identity), "bad_actor");
    _;
  }

  event DIDOwnerChanged(
    address indexed identity,
    address owner,
    uint previousChange
  );

  event DIDDelegateChanged(
    address indexed identity,
    bytes32 delegateType,
    address delegate,
    uint validTo,
    uint previousChange
  );

  event DIDAttributeChanged(
    address indexed identity,
    address indexed source,
    address indexed issuer,
    string attributeName,
    uint attributeValue,
    uint validTo,
    uint previousChange
  );

  function identityOwner(address identity) public view returns(address) {
     address owner = owners[identity];
     if (owner != address(0x00)) {
       return owner;
     }
     return identity;
  }

  function validDelegate(address identity, bytes32 delegateType, address delegate) public view returns(bool) {
    uint validity = delegates[identity][keccak256(abi.encode(delegateType))][delegate];
    return (validity > block.timestamp);
  }

  function changeOwner(address identity, address actor, address newOwner) internal onlyOwner(identity, actor) {
    owners[identity] = newOwner;
    emit DIDOwnerChanged(identity, newOwner, changed[identity]);
    changed[identity] = block.number;
  }

  function changeOwner(address identity, address newOwner) public {
    changeOwner(identity, msg.sender, newOwner);
  }

  function addDelegate(address identity, address actor, bytes32 delegateType, address delegate, uint validity) internal onlyOwner(identity, actor) {
    delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp + validity;
    emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp + validity, changed[identity]);
    changed[identity] = block.number;
  }

  function addDelegate(address identity, bytes32 delegateType, address delegate, uint validity) public {
    addDelegate(identity, msg.sender, delegateType, delegate, validity);
  }

  function revokeDelegate(address identity, address actor, bytes32 delegateType, address delegate) internal onlyOwner(identity, actor) {
    delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp;
    emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeDelegate(address identity, bytes32 delegateType, address delegate) public {
    revokeDelegate(identity, msg.sender, delegateType, delegate);
  }

    /*
   * @dev Register a root
   * @param address indexed identity,
   * @param address indexed source,
   * @param address indexed issuer,
   * @param bytes32 attributeName,
   * @param bytes attributeValue,
   * @param uint validTo,
   * @param uint previousChange
   */
  function setAttribute(address identity, address issuer, string calldata name, uint value, uint validity ) public {
    // require(approved[msg.sender]);
    emit DIDAttributeChanged(identity, msg.sender, issuer, name, value, block.timestamp + validity, changed[identity]);
    changed[identity] = block.number;
  }

}