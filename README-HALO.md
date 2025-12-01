# Halo Privacy Faucet

A web application for distributing testnet ETH and PRIV tokens on the Halo Privacy Network.

## Features

- 🌊 **Dual Token Faucet**: Distributes both ETH (for gas) and PRIV tokens (for privacy operations)
- 🔒 **Privacy Operations**: Built-in UI for private token storage and transfers
- 💼 **Wallet Integration**: Seamless MetaMask connection
- ⏱️ **Rate Limiting**: Prevents abuse with IP and address-based rate limiting
- 🎨 **Modern UI**: Beautiful Svelte-based interface

## Quick Start

### 1. Build the Application

```bash
./deploy.sh
```

This will:
- Install frontend dependencies
- Build the Svelte web app
- Compile the Go backend

### 2. Run the Faucet

```bash
export PRIVATE_KEY='your_private_key_here'
./run-faucet.sh
```

Or in one line:
```bash
PRIVATE_KEY='your_key' ./run-faucet.sh
```

### 3. Access the Interface

Open your browser to: **http://localhost:8080**

## Configuration

The faucet is pre-configured for Halo Privacy Testnet:

| Setting | Value |
|---------|-------|
| **RPC URL** | http://64.34.84.209:34141 |
| **Chain ID** | 999999 |
| **Token Contract** | 0x2210899f4Dd9944bF1b26836330aefEDD4050508 |
| **ETH Payout** | 1 ETH per request |
| **Token Payout** | 100 PRIV per request |
| **Rate Limit** | Once every 24 hours per address/IP |

### Custom Configuration

You can customize the faucet by editing `run-faucet.sh` or using command line flags:

```bash
./eth-faucet \
    -httpport 8080 \
    -wallet.provider YOUR_RPC_URL \
    -wallet.privkey YOUR_PRIVATE_KEY \
    -faucet.amount 1 \
    -faucet.tokenamount 100 \
    -faucet.tokenaddress 0x2210899f4Dd9944bF1b26836330aefEDD4050508 \
    -faucet.name "Halo Privacy Testnet" \
    -faucet.symbol "PRIV" \
    -faucet.minutes 1440
```

### Available Flags

| Flag | Description | Default |
|------|-------------|---------|
| `-httpport` | HTTP server port | 8080 |
| `-wallet.provider` | RPC endpoint | - |
| `-wallet.privkey` | Private key (hex) | - |
| `-faucet.amount` | ETH amount per request | 1 |
| `-faucet.tokenamount` | Token amount per request | 100 |
| `-faucet.tokenaddress` | ERC20 token contract address | - |
| `-faucet.name` | Network display name | testnet |
| `-faucet.symbol` | Token symbol | PRIV |
| `-faucet.minutes` | Minutes between requests | 1440 (24h) |

## Using the Interface

### 1. Connect Wallet
- Click "Connect MetaMask"
- Approve the connection
- The interface will automatically add/switch to Halo Privacy Testnet

### 2. Request Tokens
- Click "Request ETH + Tokens" in the Faucet card
- You'll receive:
  - 1 ETH (for transaction gas fees)
  - 100 PRIV tokens (for private transfers)
- Wait 24 hours before requesting again

### 3. Check Balances
- View your ETH balance (for gas)
- View your public PRIV tokens
- View your private encrypted balance
- Click "Refresh Balances" to update

### 4. Move to Private Storage
- Enter the amount of tokens to encrypt
- Click "Move to Private Storage"
- Your tokens will be encrypted using TEE (Trusted Execution Environment)
- The encrypted balance is stored on-chain

### 5. Private Transfers
- Enter recipient address
- Enter transfer amount
- Click "Send Private Transfer"
- The amount is encrypted and hidden from public view

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Web Interface (Svelte)               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │  Faucet  │ │ Balances │ │ Private  │ │ Transfer │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────────────┐
│                    ▼                                     │
│             Go Backend (eth-faucet)                      │
│  ┌────────────────────────────────────────────┐         │
│  │  • ETH Transfer                            │         │
│  │  • ERC20 Token Transfer                    │         │
│  │  • Rate Limiting                           │         │
│  │  • CAPTCHA Support                         │         │
│  └────────────────────────────────────────────┘         │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────────────┐
│                    ▼                                     │
│         Halo Privacy Testnet (Blockchain)               │
│  ┌────────────────────────────────────────────┐         │
│  │  Privacy Contract (0x2210...0508)          │         │
│  │  • Public Balances                         │         │
│  │  • Private Encrypted Balances (TEE)        │         │
│  │  • Homomorphic Operations                  │         │
│  └────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────┘
```

## Privacy Features

The faucet includes a complete privacy token interface:

1. **TEE Integration**: Uses Trusted Execution Environment for encryption
2. **Private Balances**: Token amounts are encrypted on-chain
3. **Private Transfers**: Transfer amounts are hidden from public view
4. **Homomorphic Operations**: Balance updates without decryption

## Requirements

- **Backend**: Go 1.17 or later
- **Frontend**: Node.js and npm
- **Wallet**: MetaMask browser extension
- **Tokens**: Faucet account must have both ETH and PRIV tokens

## Troubleshooting

### Build Fails
- Ensure Go and Node.js are installed
- Run `go mod tidy` if Go dependencies are missing
- Delete `web/node_modules` and run `deploy.sh` again

### Faucet Won't Start
- Check that PRIVATE_KEY is set
- Verify RPC URL is accessible
- Ensure the faucet account has sufficient ETH and tokens

### Token Transfer Fails
- Verify the token contract address is correct
- Ensure faucet account has approved/owns tokens
- Check that the token contract implements ERC20 `transfer()`

### Rate Limit Error
- Wait 24 hours between requests
- Try from a different IP address
- Contact the faucet administrator

## Security Notes

- Never commit or share your private key
- Use environment variables for sensitive data
- Run the faucet behind a reverse proxy (nginx/caddy) in production
- Enable CAPTCHA for public deployments
- Monitor faucet balance regularly

## Support

For issues or questions:
1. Check the logs for error messages
2. Verify your configuration
3. Ensure all dependencies are installed
4. Check that the blockchain RPC is accessible

## License

MIT License - See LICENSE file for details





