%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.messages import send_message_to_l1
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_contract_address,
    get_caller_address,
    call_contract,
)
from starkware.cairo.common.alloc import alloc


// ######## Storage variables

// Authorized brain on L1
@storage_var
func l1_brain_address_stored() -> (l1_brain_address_stored: felt) {
}

// ######## Getters
// Functions to display the above variables

@view
func l1_brain_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    l1_brain_address: felt
) {
    let (l1_brain_address) = l1_brain_address_stored.read();
    return (l1_brain_address=l1_brain_address);
}

// ######## Constructor

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    l1_brain_address: felt
) {
    l1_brain_address_stored.write(l1_brain_address);
    return ();
}

@event
func log_something(to_log: felt) {
}

@event
func log_array_something(to_log_len: felt, to_log: felt*) {
}

// External functions and L1 handler

@l1_handler
@raw_input
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) {
    // Check if it L1caller is the L1 brain
    let (brain) = l1_brain_address_stored.read();
    // Calldate should be organized this way
    // Slot 0: from_address (by default)
    // Slot 1: to (set by caller on L1)
    // Slot 2: target_selector (set by caller on L1)
    // Slot 3 -> calldata_size: target_call_data
    let from_address = calldata[0];
    let to = calldata[1];
    let target_selector = calldata[2];

    with_attr error_message("Zombie: caller is not brain"){
    assert brain = from_address;
    }

    //  Execute the call
     call_contract(
         contract_address=to,
         function_selector=target_selector,
         calldata_size=calldata_size-3,
         calldata=calldata+3
    );
    return ();
}

@l1_handler
@raw_input
func execute_no_guard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) {
    // Check if it L1caller is the L1 brain
    let (brain) = l1_brain_address_stored.read();
    // Calldate should be organized this way
    // Slot 0: from_address (by default)
    // Slot 1: to (set by caller on L1)
    // Slot 2: target_selector (set by caller on L1)
    // Slot 3 -> calldata_size: target_call_data
    let from_address = calldata[0];
    let to = calldata[1];
    let target_selector = calldata[2];

    //  Execute the call
     call_contract(
         contract_address=to,
         function_selector=target_selector,
         calldata_size=calldata_size-3,
         calldata=calldata+3
    );
    return ();
}


@l1_handler
@raw_input
func execute_test_simple{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) {
    
    // Calldate should be organized this way
    // Slot 0: from_address (by default)
    // Slot 1: to (set by caller on L1)
    // Slot 2: target_selector (set by caller on L1)
    // Slot 3 -> calldata_size: target_call_data
    let from_address = calldata[0];
    let to = calldata[1];
    let target_selector = calldata[2];

    log_something.emit(to);
    log_something.emit(target_selector);

    return ();
}

@l1_handler
@raw_input
func execute_test{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) {
    
    // Calldate should be organized this way
    // Slot 0: from_address (by default)
    // Slot 1: to (set by caller on L1)
    // Slot 2: target_selector (set by caller on L1)
    // Slot 3 -> calldata_size: target_call_data
    let from_address = calldata[0];
    let to = calldata[1];
    let target_selector = calldata[2];

    log_something.emit(to);
    log_something.emit(target_selector);
    log_array_something.emit(calldata_size-3, calldata+3);

    return ();
}

// A function to change the account's brain

@external
func set_brain{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_brain: felt) {
    // Check if the caller is the L2 zombie itself
    let (self) = get_contract_address();
    let (caller) = get_caller_address();
    with_attr error_message("Account: caller is not this account") {
        assert self = caller;
    }
    // Change brain address
    l1_brain_address_stored.write(new_brain);
    return ();
}
