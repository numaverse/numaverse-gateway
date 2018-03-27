pragma solidity ^0.4.2;

contract Messages {

  struct Message {
    // uint id;
    address sender;
    bytes32 ipfsHash;
  }

  event MessageCreated(
    uint indexed id,
    address indexed sender,
    bytes32 indexed ipfsHash
  );
  
  event MessageUpdated(
    uint indexed id,
    address indexed sender,
    bytes32 indexed ipfsHash
  );

  Message[] public messages;

  function Messages() public { }

  function messagesLength() public view returns (uint) {
    return messages.length;
  }

  function createMessage(bytes32 ipfsHash) public {
    messages.length++;
    uint index = messages.length - 1;

    messages[index].ipfsHash = ipfsHash;
    messages[index].sender = msg.sender;

    MessageCreated(index, msg.sender, ipfsHash);
  }

  function updateMessage(uint id, bytes32 ipfsHash) public {
    require(messages.length > id);
    require(messages[id].sender == msg.sender);
    
    messages[id].ipfsHash = ipfsHash;

    MessageUpdated(id, msg.sender, ipfsHash);
  }

}