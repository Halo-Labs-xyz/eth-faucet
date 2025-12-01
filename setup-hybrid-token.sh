#!/bin/bash

echo "🔧 Setting up HybridPrivacyERC20 with Faucet"
echo "=============================================="
echo ""

# New token from deployment
NEW_TOKEN="0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D"
TOKEN_SYMBOL="HALO"
RPC_URL="http://127.0.0.1:34141"

# Get faucet wallet address
if [ -z "$FAUCET_PRIVATE_KEY" ]; then
    echo "❌ FAUCET_PRIVATE_KEY not set"
    echo ""
    echo "Please set the faucet wallet private key:"
    echo "   export FAUCET_PRIVATE_KEY='0x...'"
    echo ""
    exit 1
fi

echo "📋 Configuration:"
echo "   Token: $NEW_TOKEN"
echo "   Symbol: $TOKEN_SYMBOL"
echo "   RPC: $RPC_URL"
echo ""

# Get faucet address
FAUCET_ADDRESS=$(cast wallet address --private-key $FAUCET_PRIVATE_KEY)
echo "   Faucet Address: $FAUCET_ADDRESS"
echo ""

# Step 1: Check faucet ETH balance
echo "Step 1: Checking faucet ETH balance..."
ETH_BALANCE=$(cast balance $FAUCET_ADDRESS --rpc-url $RPC_URL)
echo "   ETH Balance: $ETH_BALANCE wei"

if [ "$ETH_BALANCE" = "0" ]; then
    echo "   ⚠️  Faucet needs ETH for gas!"
    echo ""
fi

# Step 2: Mint tokens to faucet (1 million tokens)
echo ""
echo "Step 2: Minting 1,000,000 HALO tokens to faucet..."
echo ""

# Token owner private key (from deployment)
OWNER_KEY="0xb3a12f125fd29fbbf7c942b2101c718a8478e817070092a9b60fe54d411c2cb9"

MINT_TX=$(cast send $NEW_TOKEN \
  "mint(address,uint256)" \
  $FAUCET_ADDRESS \
  1000000000000000000000000 \
  --private-key $OWNER_KEY \
  --rpc-url $RPC_URL \
  --legacy 2>&1)

if echo "$MINT_TX" | grep -q "blockNumber"; then
    echo "✅ Tokens minted successfully!"
    TX_HASH=$(echo "$MINT_TX" | grep "transactionHash" | awk '{print $2}')
    echo "   Transaction: $TX_HASH"
else
    echo "❌ Mint failed:"
    echo "$MINT_TX"
    exit 1
fi

# Step 3: Verify faucet token balance
echo ""
echo "Step 3: Verifying faucet token balance..."
TOKEN_BALANCE=$(cast call $NEW_TOKEN "balanceOf(address)" $FAUCET_ADDRESS --rpc-url $RPC_URL)
TOKEN_BALANCE_DEC=$(printf "%d" $TOKEN_BALANCE 2>/dev/null)
TOKEN_BALANCE_READABLE=$(echo "scale=2; $TOKEN_BALANCE_DEC / 1000000000000000000" | bc)
echo "   Token Balance: $TOKEN_BALANCE_READABLE HALO"

# Step 4: Update faucet configuration
echo ""
echo "Step 4: Updating faucet configuration..."

cat > run-faucet.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Halo Privacy Faucet"
echo "================================="
echo ""

# Configuration
RPC_URL="http://127.0.0.1:34141"
TOKEN_ADDRESS="0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D"
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
if [ -z "$FAUCET_PRIVATE_KEY" ]; then
    echo "❌ FAUCET_PRIVATE_KEY environment variable not set"
    echo ""
    echo "Please set your private key:"
    echo "   export FAUCET_PRIVATE_KEY='your_private_key_here'"
    echo ""
    echo "Or run with:"
    echo "   FAUCET_PRIVATE_KEY='your_key' ./run-faucet.sh"
    echo ""
    exit 1
fi

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
    -wallet.privkey $FAUCET_PRIVATE_KEY \
    -faucet.amount $ETH_AMOUNT \
    -faucet.tokenamount $TOKEN_AMOUNT \
    -faucet.tokenaddress $TOKEN_ADDRESS \
    -faucet.name "$NETWORK_NAME" \
    -faucet.symbol "$TOKEN_SYMBOL" \
    -faucet.minutes $INTERVAL_MINUTES
EOF

chmod +x run-faucet.sh
echo "✅ run-faucet.sh updated"

# Step 5: Update frontend configuration
echo ""
echo "Step 5: Updating frontend configuration..."

cat > web/src/para-config.js << EOF
// Auto-generated configuration for HybridPrivacyERC20
export const CONFIG = {
  rpcUrl: 'http://127.0.0.1:34141',
  publicRpcUrl: 'http://64.34.84.209:34141', // Public access
  chainId: 999999,
  chainName: 'Halo Privacy Testnet',
  tokenAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D',
  tokenSymbol: 'HALO',
  teeUrl: 'https://309216b1009d13f2ce79215e39c8bdd9974c6bd4-8080.dstack-pha-prod7.phala.network',
};
EOF

echo "✅ web/src/para-config.js created"

# Update WalletConnect.svelte
echo ""
echo "📝 Note: Update WalletConnect.svelte manually:"
echo "   File: web/src/WalletConnect.svelte"
echo "   Change faucetTokenAddress to: 0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D"
echo ""

echo ""
echo "=============================================="
echo "✅ Setup Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Update frontend config:"
echo "   cd web/src"
echo "   # Edit WalletConnect.svelte line 11:"
echo "   faucetTokenAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D'"
echo ""
echo "2. Rebuild frontend:"
echo "   cd web"
echo "   npm run build"
echo ""
echo "3. Start faucet:"
echo "   export FAUCET_PRIVATE_KEY='$FAUCET_PRIVATE_KEY'"
echo "   ./run-faucet.sh"
echo ""
echo "🎉 Users will be able to:"
echo "   ✅ Request ETH + HALO tokens (public balance)"
echo "   ✅ Move tokens to private mode (depositToPrivate)"
echo "   ✅ Send private transfers (privateTransfer)"
echo ""

