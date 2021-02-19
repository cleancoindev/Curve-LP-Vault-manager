# @version 0.2.8
"""
@title Guest List
@license GNU AGPLv3
@author steffenix
"""

event GuestInvited:
    guest: address

guests: public(HashMap[address, bool])
governance: address

@external
def __init__(_gov: address):
    self.governance = _gov

@external
def invite_guest(guest: address):
    assert msg.sender == self.governance

    assert not self.guests[guest]  # dev: already invited
    self.guests[guest] = True
    log GuestInvited(guest)

@view
@external
def authorized(_guest: address, _amount: uint256) -> bool:
    if self.guests[_guest]:
        return True
    return False
