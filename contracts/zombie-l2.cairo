%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.messages import send_message_to_l1
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address


######### Storage variables

# Authorized brain on L1
@storage_var
func l1_brain_address_stored() -> (l1_brain_address_stored : felt):
end

######### Getters
# Functions to display the above variables

@view
func l1_brain_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        l1_brain_address : felt):
    let (l1_brain_address) = l1_brain_address_stored.read()
    return (l1_brain_address=l1_brain_address)
end


######### Constructor


@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        l1_brain_address : felt):
    l1_brain_address_stored.write(l1_brain_address)
    return ()
end


######### External functions and L1 handler

# A L1 handler to receive a payload from the brain
@l1_handler
func execute{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_address : felt):
        # Check if it L1caller is the L1 brain
        let (brain) = l1_brain_address_stored.read()
        with_attr error_message("Zombie: caller is not brain"):
                assert brain = from_address
        end
        # Execute the call
    return ()
end

# A function to change the account's brain

@external
func set_brain{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(new_brain : felt):
        # Check if the caller is the L2 zombie itself
        let (self) = get_contract_address()
        let (caller) = get_caller_address()
        with_attr error_message("Account: caller is not this account"):
                assert self = caller
        end
        # Change brain address
        l1_brain_address_stored.write(new_brain)
        return ()

end

