# 🚀 Quick Start - Halo Privacy Faucet

## ✅ Build Complete!

Your faucet is ready to run. The binary is located at: `/home/ubuntu/halo/eth-faucet/eth-faucet`

## Running the Faucet

### Option 1: Using the run script (Recommended)

```bash
cd /home/ubuntu/halo/eth-faucet

# Set your private key
export PRIVATE_KEY='your_private_key_here'

# Run the faucet
./run-faucet.sh
```

### Option 2: Manual command

```bash
cd /home/ubuntu/halo/eth-faucet

./eth-faucet \
    -httpport 8080 \
    -wallet.provider http://64.34.84.209:34141 \
    -wallet.privkey YOUR_PRIVATE_KEY \
    -faucet.amount 1 \
    -faucet.tokenamount 100 \
    -faucet.tokenaddress 0x2210899f4Dd9944bF1b26836330aefEDD4050508 \
    -faucet.name "Halo Privacy Testnet" \
    -faucet.symbol "PRIV" \
    -faucet.minutes 1440
```

## What You'll Get

The faucet will distribute:
- **1 ETH** - For gas fees on transactions
- **100 PRIV tokens** - For privacy operations

## Access the Interface

Once running, open your browser to:
```
http://localhost:8080
```

Or if running on a server:
```
http://YOUR_SERVER_IP:8080
```

## Interface Features

### 1. 💧 Faucet
- Request testnet ETH and PRIV tokens
- Rate limited to once per 24 hours per address/IP

### 2. 💰 Balances
- View ETH balance (for gas)
- View public PRIV token balance
- View encrypted private balance
- Refresh with one click

### 3. 🔒 Move to Private Storage
- Encrypt tokens using TEE
- Store encrypted balances on-chain
- Hide token amounts from public view

### 4. 📤 Private Transfers
- Send encrypted token amounts
- Complete privacy - amounts hidden
- TEE-verified signatures

## Requirements for Faucet Account

The private key you provide must have:
1. ✅ ETH balance (for gas + distribution)
2. ✅ PRIV token balance (for distribution)

## Testing the Faucet

1. **Connect MetaMask**
   - Click "Connect MetaMask"
   - Approve network switch to Halo Privacy Testnet

2. **Request Tokens**
   - Click "Request ETH + Tokens"
   - Wait for confirmation (2 transactions)

3. **Check Balances**
   - Your balances should update automatically
   - Click refresh to manually update

4. **Try Privacy Features**
   - Move some tokens to private storage
   - Try a private transfer to another address

## Troubleshooting

### "Failed to send ETH transaction"
- Check that faucet account has sufficient ETH balance
- Verify RPC URL is accessible

### "Failed to send token transaction"  
- Check that faucet account has sufficient PRIV tokens
- Verify token contract address is correct

### "Please switch to Halo Privacy Testnet"
- MetaMask will prompt to add the network
- Approve the network addition

### Port already in use
```bash
# Change the port
./eth-faucet -httpport 8081 ...
```

## Monitoring

To see faucet logs in real-time:
```bash
# The faucet logs to stdout/stderr
# You'll see:
# - Connection info
# - Transaction hashes
# - Errors and warnings
```

## Stopping the Faucet

Press `Ctrl+C` in the terminal where the faucet is running.

## Next Steps

1. Set up the faucet account with ETH and tokens
2. Run the faucet using one of the methods above
3. Access http://localhost:8080 in your browser
4. Test all features: faucet, balances, private storage, transfers

## Need Help?

Check:
- Terminal logs for detailed error messages
- Browser console (F12) for frontend errors
- Verify all configuration parameters
- Ensure blockchain RPC is accessible

---

**Built successfully! Ready to distribute privacy tokens! 🎉**

