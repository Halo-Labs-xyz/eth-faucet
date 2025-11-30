#!/usr/bin/env node

/**
 * Get the Ethereum address from a private key
 * Usage: node get-faucet-address.js YOUR_PRIVATE_KEY
 */

const { ethers } = require('ethers');

const privateKey = process.argv[2];

if (!privateKey) {
    console.log('Usage: node get-faucet-address.js YOUR_PRIVATE_KEY');
    console.log('');
    console.log('This will show you the address that will distribute tokens.');
    console.log('You need to send ETH and PRIV tokens to this address.');
    process.exit(1);
}

try {
    // Remove 0x prefix if present
    const cleanKey = privateKey.startsWith('0x') ? privateKey.slice(2) : privateKey;
    
    // Create wallet from private key
    const wallet = new ethers.Wallet('0x' + cleanKey);
    
    console.log('');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('  FAUCET ADDRESS (Fund this address)');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    console.log('Address:', wallet.address);
    console.log('');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    console.log('Send to this address:');
    console.log('  • ETH (for gas + distribution): at least 10 ETH recommended');
    console.log('  • PRIV tokens (for distribution): at least 10,000 tokens');
    console.log('');
    console.log('The faucet will distribute:');
    console.log('  • 1 ETH per request (for gas fees)');
    console.log('  • 100 PRIV tokens per request');
    console.log('');
    console.log('With 10 ETH + 10,000 PRIV, you can serve ~100 users');
    console.log('');
} catch (error) {
    console.error('Error:', error.message);
    console.log('');
    console.log('Make sure your private key is valid (64 hex characters)');
    process.exit(1);
}

