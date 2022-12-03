from brownie import SocialToken, accounts

def deploy_social_token(total_supply, address):
    exp_token = SocialToken.deploy(total_supply, {"from": address}) 
    return exp_token

def main():
    account = accounts.load('deployment-account')
    total_supply = 100000
    return SocialToken.deploy(total_supply, {"from": account}, publish_source=True)

if __name__ == "__main__":
    main()