// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract Oracle {

    mapping (address => bool) authenticatedNodes;
    address owner;

    event MessageRequest(uint indexed id, string message, address callbackAddress, string callbackFunction);

    modifier onlyAuthenticatedNodes {
        require (authenticatedNodes[msg.sender] || msg.sender == owner, "Only authenticated nodes");
        _;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function submitMessageRequest(uint _id, string calldata _msg, address _callbackAddress, string calldata _callbackFunction) 
        external 
    {
        emit MessageRequest(_id, _msg, _callbackAddress, _callbackFunction);
    }

    function fulfillMessageRequest(uint _id, string calldata _signedMsg, address _callbackAddress, string calldata _callbackFunction)
        external onlyAuthenticatedNodes 
    {
        (bool success, ) = _callbackAddress.call(
            abi.encodeWithSignature(_callbackFunction, _id, _signedMsg)
        );
        require (success);
    }

    function authenticateNode(address _nodeAddress) external onlyOwner {
        authenticatedNodes[_nodeAddress] = true;
    }
}
