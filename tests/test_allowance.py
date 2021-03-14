import brownie


def test_check_allowance_list(gov, vault, invited, not_invited):
    vault.deposit(10 * 10 ** 18, {"from": invited})
    with brownie.reverts():
        vault.deposit(10 * 10 ** 18, {"from": not_invited})


def test_check_allowance_from_registry(accounts, token, vault, strategy):
    strategy_account = accounts.at(strategy, force=True)
    token.approve(vault, 2 ** 256 - 1, {"from": accounts[2]})
    
    print(vault.strategies(strategy_account))

    vault.deposit(10 * 10 ** 18, {"from": strategy_account, "gas": 10_000_000}) 
