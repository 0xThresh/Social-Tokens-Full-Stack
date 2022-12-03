import os
import json 
from web3 import Web3
from web3.middleware import geth_poa_middleware

def lambda_handler(event, context):
    # Address that logs in to frontend
    transfer_address = event["walletAddress"]
    
    # Operator address from contract
    operator_address = "0xc2b60CfFe4f20b2046C951CDEB459aF897cff571"
    
    w3, contract = configure_web3_provider() 
        
    try:
        print("Wallet address received, sending tokens...")
        txn = send_tokens(w3, transfer_address, contract, operator_address)
        
        # line below results in a string
        txn_json = Web3.toJSON(txn)
        txn_json = json.loads(txn_json)

        txn_id = txn_json["transactionHash"]
        return {
            'statusCode': 200,
            'body': json.dumps(f'Tokens sent successfully, transaction ID: {txn_id}')
        }
        
    except:
        print("Unknown error; most likely reason is that an invalid wallet address was sent in the event.")
        return {
            'statusCode': 403,
            'body': json.dumps("Unknown error; most likely reason is that an invalid wallet address was sent in the event.")
        }
   
    
def configure_web3_provider():
    """Configures a web3 provider and contract object
    
    :param infura_id: ID of the Infura project used for access to blockchains
    :type infura_id: str 
    :param w3: provider object created using Web3 library 
    :type w3: <class 'web3.main.Web3'>
    :param abi: contract ABIs loaded from a file 
    :type abi: dict 
    :returns: a w3 provider object and a contract object
    :param contract: contract object used to make calls and transactions to the contract on Polygon 
    :type contract: <class 'web3._utils.datatypes.Contract'>
    :rtype: w3, contract 
    """
    
    infura_id = os.environ.get("INFURA_ID")
    
    # creates the web3 provider using the Infura backend
    w3 = Web3(Web3.HTTPProvider(f'https://polygon-mainnet.infura.io/v3/{infura_id}'))
    
    # required for non-ETH blockchains where extraData field > 32 bytes
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    
    # loads contract ABIs into a variable
    with open("abi.json") as f:
        abi = json.load(f)
    
    # creates contract object, with callable functions and contract address on Polygon
    contract = w3.eth.contract(address='0x51a5485C7C66ee38dda45e39d705C04Ebe43E2dF', abi=abi)
    
    return w3, contract
    


def send_tokens(_w3, _transfer_address, _contract, _operator_address):
    """Sends tokens to the wallet address received in the event
    
    Sends tokens to the wallet address received in the event.
    
    :param nonce: current nonce value of the wallet calling the transfer() function 
    :type nonce: int 
    :param transaction_parameters: parameters passed into the transaction sent to the contract 
    :type transaction_parameters: dict 
    :param private_key: private key of the operator address
    :type private_key: str
    :param transfer_txn: the transaction that transfers tokens from the contract to the receving wallet 
    :type transfer_txn: dict
    :param signed_txn: transaction signed using private key, giving it the ability to be sent 
    :type signed_txn: <class 'eth_account.datastructures.SignedTransaction'>
    :param txn: hex data of sent transaction
    :type txn: <class 'hexbytes.main.HexBytes'>
    :param txn_receipt: receipt object that includes data about transaction, such as transaction ID
    :type txn_receipt: <class 'hexbytes.main.HexBytes'>
    :returns: txn_receipt, which is used to extract the transaction ID 
    :rtype: <class 'hexbytes.main.HexBytes'>
    """
    
    nonce = _w3.eth.getTransactionCount(_operator_address)
    
    transaction_parameters = {
        'from': _operator_address,
        'nonce': nonce
    }
    
    # Private key from Lambda env vars
    private_key = os.environ.get("PRIVATE_KEY")
    assert private_key is not None, "PRIVATE_KEY environment variable is not set; cannot send transaction without it"
    
    transfer_txn = _contract.functions.transfer(_transfer_address, 1).build_transaction(transaction_parameters)
    
    signed_txn = _w3.eth.account.signTransaction(transfer_txn, private_key=private_key)
    
    txn = _w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    
    txn_receipt = _w3.eth.wait_for_transaction_receipt(txn)

    return txn_receipt