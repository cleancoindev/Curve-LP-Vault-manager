import pytest
from brownie import config
from brownie import Contract


@pytest.fixture
def gov(accounts):
    yield accounts[0]


@pytest.fixture
def rewards(accounts):
    yield accounts[3]


@pytest.fixture
def management(accounts):
    yield accounts[4]


@pytest.fixture
def token(pm, gov):
    Token = pm(config["dependencies"][0]).Token
    token = gov.deploy(Token)

    yield token


@pytest.fixture
def guest_list(gov, GuestList):
    yield gov.deploy(GuestList, gov)


@pytest.fixture
def vault(pm, gov, rewards, management, guest_list, token):
    Vault = pm(config["dependencies"][0]).Vault
    vault = gov.deploy(Vault)
    vault.initialize(token, gov, rewards, "", "", gov)
    vault.setDepositLimit(2 ** 256 - 1, {"from": gov})
    vault.setManagement(management, {"from": gov})
    vault.setGuestList(guest_list, {"from": gov})
    yield vault


@pytest.fixture
def invited(accounts, token, gov, guest_list, vault):
    guest_list.invite_guest(accounts[1], {"from": gov})
    token.transfer(accounts[1], 100 * 10 ** 18)
    token.approve(vault, 2 ** 256 - 1, {"from": accounts[1]})

    yield accounts[1]


@pytest.fixture
def not_invited(accounts, token, gov, vault):
    token.transfer(accounts[2], 100 * 10 ** 18)
    token.approve(vault, 2 ** 256 - 1, {"from": accounts[2]})

    yield accounts[2]
