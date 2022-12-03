from brownie import accounts as acct
from brownie import ZERO_ADDRESS
import pytest
from scripts.deploy_social_token import deploy_social_token

@pytest.fixture(scope="module")
def social_token():
    # Arrange
    ## Initial variables
    total_supply = 100000

    ## Deploy required contract
    return deploy_social_token(total_supply, acct[0])

def test_get_token_total_supply(social_token):
    assert social_token.totalSupply({"from": acct[0]}) == 100000, "SocialToken token's total supply is wrong"

def test_set_operator(social_token):
    social_token.setOperator(acct[1], {"from": acct[0]}) 
    assert social_token.getOperator({"from": acct[0]}) == acct[1], "Operator address failed to change to new address"

def test_user_transfer(social_token):
    social_token.transfer(acct[2], 100, {"from": acct[1]})
    assert social_token.balanceOf(acct[2]) == 100, "Participant user does not have transferred tokens"

def test_total_supply_after_transfer(social_token):
    assert social_token.totalSupply() == 99900, "Total supply has not been updated correctly after transfer to user"

def test_burn_tokens(social_token):
    test = social_token.balanceOf(acct[2])
    print(test)
    social_token.burn(acct[2], 100, {"from": acct[1]})
    assert social_token.balanceOf(acct[2]) == 0, "Participant user still has transferred tokens"
