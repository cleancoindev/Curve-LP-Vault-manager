import brownie


def test_allowance(gov, vault, invited, not_invited):
    vault.deposit(10 * 10 ** 18, {"from": invited})
    with brownie.reverts():
        vault.deposit(10 * 10 ** 18, {"from": not_invited})
