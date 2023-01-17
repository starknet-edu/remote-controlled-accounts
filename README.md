# Remote controlled account
## This project is not ready for production purposes, use at your own risk

## Description
The goal of this project is to create two smart contracts that allow communication between Ethereum and StarkNet.
- `zombie-l1.sol` is an Ethereum contract that receives an arbitrary command from a starknet contract and executes it (L2 -> L1)
- `zombie-l2.cairo` is a StarkNet contract that receives an arbitrary command from an Ethereum contract and executes it (L1 -> L2)

## Design goals and potential usage
Use cases for such contracts are multiple: 
- Create a DAO that takes decision on StarkNet, at a low cost per vote, and executes decisions on L1 to move assets 
- Create a StarkNet deployment of an existing L1 dapp, while using the existing L1 governance mechanism
- Create a Starknet wallet for an L1 multisig such as Gnosis safe
- Create an ethereum Argent wallet controlled by a StarkNet Braavos or Argent wallet

Note that for both canals (L1 -> L2 and L2 -> L1), we created only the part that executes the decision. It is the only constant one; the scheme to send commands can be arbitrary. 

## How to contribute to this project
A LOT remains to be done, and you can help! 

### Repo structure
- Set up protostar to use the repo
- Add a quick guide to test L1 <-> L2 communication locally when developping
- Clean the repo from testing files

### L1 -> L2 zombie
#### What has been done
- `zombie-l2.cairo` is functional but needs to be tested more extensively
- `MessageSender.sol` is currently used to test that `zombie-l2.cairo` receives messages. It needs to be turned into a generic contract that can be inherited from by a solidity contract, to make it easy to call the L2 function. It can probably be turned into a library

#### What you can do
- Write test cases for `zombie-l2.cairo`
- Turn `MessageSender.sol` into a generic contract that can be inherited from
- Write an example integration use case with Gnosis safe
- Write an example integration that deploys a new contract from the zombie, given a class hash and constructor argument by an L1 message

### L2 -> L1 zombie
#### What has been done
- `zombie-l1.sol` has functionnalities to change the L2 brain, but is not functional to execute L2 messages. It has two functions `execute()` and `executeTest()` which I used to execute calls to other contracts based on a uint array; I'll describe the two paths to make these functional below

#### What you can do
- Make `zombie-l1.sol` functionnal. The issue is "how to turn a starknet message, which is an array of uint256, into calldata that can be sent in a call to another Ethereum contract". There are two paths here:
- 1. The message passes only the hash of (call data, the recipient smart contract on Ethereum, the value). This hash will be a uint256, so two felts. Upon calling execute(), the caller will need to supply the required calldata. The zombie will hash it, and match it to the hash of the message receives from L2. If it matches, the message is consumed and the call executed
- 2. The message passes the full payload of the call to be executed. This implies turning an array of uint256 into calldata to another contract.
- Add events to succesful call executions
- Write test cases for `zombie-l1.sol`
- Write an example integration where a StarkNet wallet can deposit assets in Aave using the zombie
- Write an example integration where a StarkNet wallet can deploy a new zombie with a factory, and have this zombie execute calls on L1 for it
