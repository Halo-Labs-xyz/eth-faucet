#!/bin/bash

echo "🪙 Deploying Faucet Token for Halo Privacy Network"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Configuration
RPC_URL="http://127.0.0.1:34141"
PRIVATE_KEY="b3a12f125fd29fbbf7c942b2101c718a8478e817070092a9b60fe54d411c2cb9"
INITIAL_SUPPLY=10000000  # 10 million tokens
GAS_LIMIT=2000000

echo "📋 Configuration:"
echo "   RPC: $RPC_URL"
echo "   Initial Supply: $INITIAL_SUPPLY HALO tokens"
echo "   Deployer: 0x557FacC4905B830769576AfF115C1437aE1A2612"
echo ""

# Check if cast is available
if ! command -v cast &> /dev/null; then
    echo "❌ 'cast' not found. Please install foundry first:"
    echo "   curl -L https://foundry.paradigm.xyz | bash"
    echo "   foundryup"
    exit 1
fi

echo "📝 Compiling contract..."
solc --version > /dev/null 2>&1 || { echo "❌ solc not found. Installing..."; sudo apt-get install -y solc; }

# Compile the contract
solc --optimize --combined-json abi,bin FaucetToken.sol > FaucetToken.json 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

echo "✅ Contract compiled"
echo ""

# Extract bytecode
BYTECODE=$(cat FaucetToken.json | jq -r '.contracts["FaucetToken.sol:FaucetToken"].bin')

echo "🚀 Deploying contract..."
echo "   Bytecode length: ${#BYTECODE} characters"
echo ""

# Encode constructor args properly
CONSTRUCTOR_DATA=$(cast abi-encode "constructor(uint256)" $INITIAL_SUPPLY)
# Remove 0x prefix if present
CONSTRUCTOR_DATA=${CONSTRUCTOR_DATA#0x}

# Combine bytecode and constructor
FULL_BYTECODE="0x${BYTECODE}${CONSTRUCTOR_DATA}"

echo "   Deploying..."
# Deploy using cast send
DEPLOY_OUTPUT=$(cast send --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --create "$FULL_BYTECODE" \
    --json 2>&1)

if [ $? -eq 0 ]; then
    CONTRACT_ADDRESS=$(echo $DEPLOY_OUTPUT | jq -r '.contractAddress')
    TX_HASH=$(echo $DEPLOY_OUTPUT | jq -r '.transactionHash')
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ FAUCET TOKEN DEPLOYED SUCCESSFULLY!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 Contract Address: $CONTRACT_ADDRESS"
    echo "📝 Transaction Hash: $TX_HASH"
    echo "🪙 Token Name: Halo Testnet Token"
    echo "🏷️  Symbol: HALO"
    echo "💰 Total Supply: $INITIAL_SUPPLY HALO"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "1. Update faucet configuration:"
    echo "   TOKEN_ADDRESS=$CONTRACT_ADDRESS"
    echo ""
    echo "2. Restart faucet with:"
    echo "   ./eth-faucet -httpport 8080 \\"
    echo "     -wallet.provider http://127.0.0.1:34141 \\"
    echo "     -wallet.privkey $PRIVATE_KEY \\"
    echo "     -faucet.amount 1 \\"
    echo "     -faucet.tokenamount 100 \\"
    echo "     -faucet.tokenaddress $CONTRACT_ADDRESS \\"
    echo "     -faucet.name 'Halo Privacy Testnet' \\"
    echo "     -faucet.symbol 'HALO'"
    echo ""
    echo "3. Users can then:"
    echo "   • Get HALO tokens from faucet"
    echo "   • Deposit HALO into privacy contract (0x2210899f4Dd9944bF1b26836330aefEDD4050508)"
    echo "   • Do private transfers with TEE"
    echo ""
    
    # Save for later use
    echo "export FAUCET_TOKEN_ADDRESS=$CONTRACT_ADDRESS" > token-address.env
    echo "✅ Token address saved to token-address.env"
    
else
    echo ""
    echo "❌ Deployment failed!"
    echo "Check your RPC connection and private key"
    exit 1
fi

