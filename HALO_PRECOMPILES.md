# Halo Network Precompiles & Confidential Transfers

## Overview

ERC20 tokens deployed on Halo Network can interface with custom precompiles to enable confidential transfers. The faucet distributes tokens using standard ERC20 `transfer()` calls, and users can then move tokens to private storage using the frontend interface.

## How It Works

### 1. Standard ERC20 Transfer (Faucet)

The faucet backend performs standard ERC20 transfers:
- Uses the standard `transfer(address, uint256)` function
- Tokens are sent to users' public balances
- No precompile interaction required at this stage

### 2. Confidential Transfer (User Interface)

Users can move tokens to private storage using the frontend, which:
- Calls TEE (Trusted Execution Environment) service for encryption
- Uses contract methods that interface with Halo precompiles:
  - `depositToPrivate(bytes encryptedBalance, uint64 timestamp, bytes signature)`
  - `privateTransfer(address to, bytes encryptedAmount, bytes signature)`

## Token Contract Requirements

For ERC20 tokens to support confidential transfers on Halo Network, they must:

1. **Implement Standard ERC20 Interface**
   - `transfer(address, uint256)` - Used by faucet
   - `balanceOf(address)` - Public balance queries

2. **Implement Confidential Transfer Methods**
   - `depositToPrivate(bytes encryptedBalance, uint64 timestamp, bytes signature)` - Move public tokens to private storage
   - `privateTransfer(address to, bytes encryptedAmount, bytes signature)` - Transfer encrypted tokens
   - `getPrivateBalance(address)` - Query private encrypted balance
   - `hasPrivateBalance(address)` - Check if address has private balance

3. **Interface with Halo Precompiles**
   - The contract methods must call Halo's custom precompiles
   - Precompiles handle the encryption/decryption and zero-knowledge verification
   - Precompile addresses are typically fixed by the Halo Network protocol

## Current Implementation

### Backend (Go)
- ✅ Standard ERC20 `transfer()` for faucet distribution
- ✅ Auto-detects token decimals (supports USDC 6 decimals, standard 18 decimals, etc.)
- ⚠️ Does NOT interact with precompiles (users handle this via frontend)

### Frontend (Svelte)
- ✅ Wallet connection and balance queries
- ✅ Standard token transfers
- ✅ Private storage via `depositToPrivate()` with TEE encryption
- ✅ Confidential transfers via `privateTransfer()` with TEE encryption
- ✅ Integration with Halo precompiles through contract methods

## Token Deployment

When deploying a new ERC20 token for Halo Network:

1. **Deploy Standard ERC20** with:
   - Standard `transfer()`, `balanceOf()`, etc.
   - Support for the confidential transfer methods listed above

2. **Ensure Precompile Integration**
   - Contract must call Halo precompiles in `depositToPrivate()` and `privateTransfer()`
   - Precompile addresses are network-specific

3. **Configure Faucet**
   - Set `-faucet.tokenaddress` to your deployed contract
   - Set `-faucet.tokendecimals` (or let it auto-detect)
   - Fund the faucet wallet with tokens

## Example: USDC on Halo Network

```bash
# Deploy USDC contract with precompile support
# (Contract must implement both standard ERC20 and confidential methods)

# Configure faucet
./eth-faucet \
    -wallet.provider http://64.34.84.209:34141 \
    -wallet.privkey YOUR_KEY \
    -faucet.tokenaddress 0xYourUSDCContract \
    -faucet.tokendecimals 6 \
    -faucet.tokenamount 100 \
    -faucet.symbol "USDC"
```

Users will:
1. Receive USDC via standard `transfer()` from faucet
2. Use frontend to move USDC to private storage (calls precompiles)
3. Perform confidential transfers (calls precompiles)

## Notes

- **Faucet only does public transfers**: The backend faucet does NOT interact with precompiles directly
- **Users handle privacy**: Users move tokens to private storage via the frontend
- **Precompile addresses**: These are fixed by Halo Network and accessed through contract calls
- **TEE Service**: The frontend uses an external TEE service for encryption before calling contract methods

## References

- Token contract example: `SimpleToken.sol` (basic ERC20, add precompile methods for production)
- Frontend contract ABI: See `web/src/WalletConnect.svelte` for required methods
- TEE integration: See `web/src/PrivateStorage.svelte` and `web/src/PrivateTransfer.svelte`

