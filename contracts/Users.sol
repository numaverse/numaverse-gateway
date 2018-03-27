pragma solidity ^0.4.2;

contract Users {
  mapping(address => bytes32) public users;

  function update(bytes32 ipfsHash) public {
    users[msg.sender] = ipfsHash;
    UserUpdated(msg.sender, ipfsHash);
  }

  event UserUpdated(
    address indexed sender,
    bytes32 indexed ipfsHash
  );

}