
pragma solidity ^0.8.0;
// A smart contract used to debug the bridge communication
import "./IStarknetCore.sol";

contract MessageSender {
    IStarknetCore public starknetCore;
    uint256 public simpleSelector;
    uint256 public simpleContract;
    event messageHash(bytes32 returned);
    constructor(
        address starknetCore_,
        uint256 simpleSelector_,
        uint256 simpleContract_
    )  {
        starknetCore = IStarknetCore(starknetCore_);
        simpleSelector = simpleSelector_;
        simpleContract = simpleContract_;

    }

    function sendMessage(uint256 l2_contract, uint256 selector, uint256[] memory l2calldata, uint256 salt) public {
        sendMessageSuccess(salt);
         emit messageHash(starknetCore.sendMessageToL2(
            l2_contract,
            selector,
            l2calldata
        ));
        
    }
    function sendMessageSuccess(uint256 salt) public {
        uint256[] memory sender_payload = new uint256[](3);
        sender_payload[0] = 0;
        sender_payload[1] = 0;
        sender_payload[2] = salt;
        emit messageHash(starknetCore.sendMessageToL2(
            simpleContract,
            simpleSelector,
            sender_payload
        ));
    }
}