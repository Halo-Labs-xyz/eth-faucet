#!/usr/bin/env python3
"""Deploy Faucet Token using web3.py"""

import json
from web3 import Web3
from eth_account import Account

# Configuration
RPC_URL = "http://127.0.0.1:34141"
PRIVATE_KEY = "b3a12f125fd29fbbf7c942b2101c718a8478e817070092a9b60fe54d411c2cb9"
INITIAL_SUPPLY = 10_000_000  # 10 million tokens

print("🪙 Deploying Faucet Token for Halo Privacy Network")
print("=" * 60)
print()

# Connect to RPC
w3 = Web3(Web3.HTTPProvider(RPC_URL))
if not w3.is_connected():
    print("❌ Cannot connect to RPC at", RPC_URL)
    exit(1)

account = Account.from_key(PRIVATE_KEY)
print(f"✅ Connected to RPC")
print(f"📍 Deployer: {account.address}")
print(f"💰 Balance: {w3.from_wei(w3.eth.get_balance(account.address), 'ether')} ETH")
print()

# Read compiled contract
print("📝 Loading compiled contract...")
with open('FaucetToken.json', 'r') as f:
    compiled_json = json.load(f)

contract_data = compiled_json['contracts']['FaucetToken.sol:FaucetToken']
abi = contract_data['abi']
# ABI might be string or already parsed
if isinstance(abi, str):
    abi = json.loads(abi)

contract_interface = {
    'abi': abi,
    'bin': contract_data['bin']
}

print("✅ Contract loaded")
print()

# Deploy contract
print("🚀 Deploying contract...")
FaucetToken = w3.eth.contract(abi=contract_interface['abi'], bytecode=contract_interface['bin'])

# Build transaction
tx = FaucetToken.constructor(INITIAL_SUPPLY).build_transaction({
    'from': account.address,
    'nonce': w3.eth.get_transaction_count(account.address),
    'gas': 2000000,
    'gasPrice': w3.eth.gas_price
})

# Sign and send
signed_tx = account.sign_transaction(tx)
tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)

print(f"📝 Transaction sent: {tx_hash.hex()}")
print("⏳ Waiting for confirmation...")

# Wait for receipt
receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=60)

if receipt['status'] == 1:
    contract_address = receipt['contractAddress']
    print()
    print("=" * 60)
    print("✅ FAUCET TOKEN DEPLOYED SUCCESSFULLY!")
    print("=" * 60)
    print()
    print(f"📍 Contract Address: {contract_address}")
    print(f"📝 Transaction Hash: {tx_hash.hex()}")
    print(f"🪙 Token Name: Halo Testnet Token")
    print(f"🏷️  Symbol: HALO")
    print(f"💰 Total Supply: {INITIAL_SUPPLY:,} HALO")
    print()
    print("=" * 60)
    print()
    print("📋 Next Steps:")
    print()
    print("1. Start faucet with this token:")
    print(f"   export FAUCET_TOKEN_ADDRESS={contract_address}")
    print()
    print("2. Run faucet:")
    print("   ./eth-faucet -httpport 8080 \\")
    print("     -wallet.provider http://127.0.0.1:34141 \\")
    print("     -wallet.privkey YOUR_KEY \\")
    print("     -faucet.amount 1 \\")
    print("     -faucet.tokenamount 100 \\")
    print(f"     -faucet.tokenaddress {contract_address} \\")
    print("     -faucet.name 'Halo Privacy Testnet' \\")
    print("     -faucet.symbol 'HALO'")
    print()
    
    # Save address
    with open('token-address.env', 'w') as f:
        f.write(f'export FAUCET_TOKEN_ADDRESS={contract_address}\n')
    
    print("✅ Token address saved to token-address.env")
else:
    print("❌ Deployment failed!")
    print(f"Receipt: {receipt}")

