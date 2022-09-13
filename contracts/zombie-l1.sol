// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IStarknetCore.sol";

contract Zombie {
        IStarknetCore private starknetCore;
        uint256 public l2Brain;
        event callDataReconstructed(bytes executeCalldata);
 
        constructor(address starknetCore_, uint256 l2Brain_) 
        {
                starknetCore = IStarknetCore(starknetCore_);
                l2Brain = l2Brain_;
        }

        function setL2Brain(uint256 l2Brain_) external 
        {
                require(msg.sender == address(this), "Function can only be called by zombie");
                l2Brain = l2Brain_;
        }

        function execute(uint256[] memory payload) public payable returns (bool, bytes memory)
        {
                // Consume the message from the StarkNet core contract.
                // This will revert the (Ethereum) transaction if the message does not exist.
                starknetCore.consumeMessageFromL2(l2Brain, payload);
                address to = address(uint160(payload[0]));
                uint256 value = payload[1];
                uint256 gas = payload[2];
                bytes memory executeCalldata;
                for (uint256 i = 3; i < payload.length; i++)
                {
                        executeCalldata = abi.encodePacked(executeCalldata, payload[i]);
                }
                // bytes memory executeCalldata = payload[3];
                // Execute the call
                (bool success, bytes memory data) = to.call{value: value, gas: gas}(
                    // abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
                    executeCalldata
                );
                return(success, data);
        } 
        function executeTest(uint256[] memory payload) public payable 
        {
                address to = address(uint160(payload[0]));
                uint256 value = payload[1];
                uint256 gas = payload[2];
                bytes memory executeCalldata;
                for (uint256 i = 3; i < payload.length; i++)
                {
                        executeCalldata = abi.encodePacked(executeCalldata, payload[i]);
                }
        } 

        receive () external payable
        {}
}
