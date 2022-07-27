// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract MessageSigner {

    address constant ORACLE = 0x6787162cF7473341fD3c566B7fa9b896a12f46A1;
    uint nextId;

    modifier onlyOracle {
        require (msg.sender == ORACLE, "Only Oracle");
        _;
    }

    event MessageSigned(uint indexed id, string message);
    
    function submitMessage(string calldata _msg) external returns (uint) {
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
        return nextId - 1;
    }

    function _callback(uint _id, string calldata _signedMsg) external onlyOracle {
        emit MessageSigned(_id, _signedMsg);
    }
}
