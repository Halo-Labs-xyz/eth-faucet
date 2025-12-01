#!/bin/bash

echo "🚀 Starting Halo Privacy Faucet"
echo "================================="
echo ""

# Configuration
RPC_URL="http://64.34.84.209:34141"
TOKEN_ADDRESS="0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D"  # HybridPrivacyERC20
NETWORK_NAME="Halo Privacy Testnet"
TOKEN_SYMBOL="HALO"
ETH_AMOUNT="1"         # 1 ETH for gas
TOKEN_AMOUNT="100"     # 100 HALO tokens
HTTP_PORT="8080"
INTERVAL_MINUTES="1440" # 24 hours

# Check if eth-faucet binary exists
if [ ! -f "./eth-faucet" ]; then
    echo "❌ eth-faucet binary not found!"
    echo "   Please run ./deploy.sh first to build the project"
    exit 1
fi

# Check for private key
if [ -z "$PRIVATE_KEY" ] && [ -z "$FAUCET_PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY or FAUCET_PRIVATE_KEY environment variable not set"
    echo ""
    echo "Please set your private key:"
    echo "   export FAUCET_PRIVATE_KEY='your_private_key_here'"
    echo ""
    echo "Or run with:"
    echo "   FAUCET_PRIVATE_KEY='your_key' ./run-faucet.sh"
    echo ""
    exit 1
fi

# Support both PRIVATE_KEY and FAUCET_PRIVATE_KEY
PRIVATE_KEY="${FAUCET_PRIVATE_KEY:-$PRIVATE_KEY}"

echo "📋 Configuration:"
echo "   RPC URL: $RPC_URL"
echo "   Network: $NETWORK_NAME"
echo "   Token Contract: $TOKEN_ADDRESS"
echo "   Token Symbol: $TOKEN_SYMBOL"
echo "   ETH Payout: $ETH_AMOUNT ETH"
echo "   Token Payout: $TOKEN_AMOUNT $TOKEN_SYMBOL"
echo "   HTTP Port: $HTTP_PORT"
echo "   Rate Limit: Every $INTERVAL_MINUTES minutes"
echo ""
echo "🌐 Access the faucet at: http://localhost:$HTTP_PORT"
echo ""
echo "Starting faucet..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./eth-faucet \
    -httpport $HTTP_PORT \
    -wallet.provider $RPC_URL \
    -wallet.privkey $PRIVATE_KEY \
    -faucet.amount $ETH_AMOUNT \
    -faucet.tokenamount $TOKEN_AMOUNT \
    -faucet.tokenaddress $TOKEN_ADDRESS \
    -faucet.name "$NETWORK_NAME" \
    -faucet.symbol "$TOKEN_SYMBOL" \
    -faucet.minutes $INTERVAL_MINUTES

