pragma solidity ^0.4.2;

contract StatelessNuma {

    event NewBatch(
        bytes32 indexed ipfsHash
    );

    function StatelessNuma() public { }
    
    function newBatch(bytes32 ipfsHash) public {
        NewBatch(ipfsHash);
    }
}