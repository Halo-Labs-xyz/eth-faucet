#!/bin/bash

echo "🪙 Deploying Simple ERC20 Token for Faucet"
echo "=========================================="
echo ""

# Configuration
RPC_URL="http://64.34.84.209:34141"
PRIVATE_KEY="b3a12f125fd29fbbf7c942b2101c718a8478e817070092a9b60fe54d411c2cb9"
INITIAL_SUPPLY=1000000  # 1 million tokens

echo "📋 Configuration:"
echo "   RPC URL: $RPC_URL"
echo "   Initial Supply: $INITIAL_SUPPLY tokens"
echo ""

# Check if cast is available
if ! command -v cast &> /dev/null; then
    echo "❌ 'cast' command not found. Installing foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
fi

echo "📝 Compiling contract..."
solc --optimize --bin --abi SimpleToken.sol -o build/

if [ ! -f "build/SimpleToken.bin" ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

echo "✅ Contract compiled"
echo ""

echo "🚀 Deploying contract..."
BYTECODE=$(cat build/SimpleToken.bin)
CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(uint256)" $INITIAL_SUPPLY)

# Deploy using cast
DEPLOY_TX=$(cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY --create "${BYTECODE}${CONSTRUCTOR_ARGS}" --json)

if [ $? -eq 0 ]; then
    CONTRACT_ADDRESS=$(echo $DEPLOY_TX | jq -r '.contractAddress')
    echo ""
    echo "✅ Token deployed successfully!"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  CONTRACT ADDRESS"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "$CONTRACT_ADDRESS"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo "1. Save this address for the faucet configuration"
    echo "2. Update run-faucet.sh with this token address"
    echo "3. Restart the faucet"
    echo ""
else
    echo "❌ Deployment failed!"
    exit 1
fi

