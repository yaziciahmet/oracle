// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract MessageSigner {

    address constant ORACLE = 0xB9e2A2008d3A58adD8CC1cE9c15BF6D4bB9C6d72;
    uint nextId;

    modifier onlyOracle {
        require (msg.sender == ORACLE, "Only Oracle");
        _;
    }

    event Message(uint indexed id, string message);
    
    function submitMessage(string calldata _msg) external {
        (bool success, ) = ORACLE.call(
            abi.encodeWithSignature(
                "submitMessageRequest(uint256,string,address,string)", 
                nextId, 
                _msg, 
                address(this), 
                "_callback(uint256,string)"
            )
        );
        require (success);
        ++nextId;
    }

    function _callback(uint _id, string calldata _signedMsg) external onlyOracle {
        emit Message(_id, _signedMsg);
    }
}
