resource "aws_secretsmanager_secret" "infura_id" {
  name          = "infura_id"
  description   = "Infura ID to be used in Lambda function for smart contract calls"
}

resource "aws_secretsmanager_secret" "wallet_private_key" {
  name          = "wallet_private_key"
  description   = "The private key of the wallet that will send transactions. DO NOT DO NOT DO NOT USE A PRIMARY WALLET! USE A DEDICATED WALLET WITH LOW FUNDS!"
}
