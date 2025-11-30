#!/bin/bash

echo "🚀 Deploying Halo Privacy Faucet"
echo "================================="

# Check if we're in the right directory
if [ ! -f "main.go" ]; then
    echo "❌ Error: Please run this script from the eth-faucet directory"
    exit 1
fi

# Step 1: Install frontend dependencies
echo ""
echo "📦 Step 1/4: Installing frontend dependencies..."
cd web
if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
else
    echo "✅ Dependencies already installed"
fi

# Step 2: Build frontend
echo ""
echo "🔨 Step 2/4: Building frontend..."
npm run build

# Step 3: Build Go backend
echo ""
echo "🔨 Step 3/4: Building Go backend..."
cd ..
go build -o eth-faucet

# Step 4: Check build
if [ -f "eth-faucet" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📋 Configuration:"
    echo "   RPC URL: ${WEB3_PROVIDER:-not set}"
    echo "   Private Key: ${PRIVATE_KEY:+***set***}"
    echo ""
    echo "🎯 To run the faucet, use one of these commands:"
    echo ""
    echo "Option 1 - Using environment variables:"
    echo "   export WEB3_PROVIDER='http://64.34.84.209:34141'"
    echo "   export PRIVATE_KEY='your_private_key'"
    echo "   ./eth-faucet -httpport 8080"
    echo ""
    echo "Option 2 - Using command line flags:"
    echo "   ./eth-faucet -httpport 8080 \\"
    echo "     -wallet.provider http://64.34.84.209:34141 \\"
    echo "     -wallet.privkey YOUR_PRIVATE_KEY \\"
    echo "     -faucet.amount 1 \\"
    echo "     -faucet.tokenamount 100 \\"
    echo "     -faucet.tokenaddress 0x2210899f4Dd9944bF1b26836330aefEDD4050508 \\"
    echo "     -faucet.name 'Halo Privacy Testnet' \\"
    echo "     -faucet.symbol 'PRIV'"
    echo ""
else
    echo "❌ Build failed!"
    exit 1
fi

