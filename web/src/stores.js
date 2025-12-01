import { writable } from 'svelte/store';

export const walletStore = writable({
  provider: null,
  signer: null,
  contract: null,
  address: '',
  connected: false,
});

export const balanceStore = writable({
  eth: '0',
  publicTokens: '0',
  privateBalance: null,
  isPrivateMode: false,
  loading: false,
});

export const configStore = writable({
  faucetTokenAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D', // HybridPrivacyERC20
  privacyContractAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D', // Same contract
  teeUrl:
    'https://309216b1009d13f2ce79215e39c8bdd9974c6bd4-8080.dstack-pha-prod7.phala.network',
  rpcUrl: 'http://64.34.84.209:34141',
  chainId: 999999,
});

