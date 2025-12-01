<script>
  import { onMount } from 'svelte';
  import { ethers } from 'ethers';
  import { walletStore } from './stores.js';
  import { toast } from 'bulma-toast';

  const CONFIG = {
    rpcUrl: 'http://64.34.84.209:34141',
    chainId: 999999,
    chainName: 'Halo Privacy Testnet',
    faucetTokenAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D',  // HybridPrivacyERC20
    privacyContractAddress: '0x309208f2f88E3bd1A372E1c557D9Dbc9f664Ed0D',  // Same contract
  };

  // HybridPrivacyERC20 ABI - supports both public and private transfers
  const HYBRID_TOKEN_ABI = [
    'function balanceOf(address) view returns (uint256)',
    'function transfer(address to, uint256 amount) returns (bool)',
    'function approve(address spender, uint256 amount) returns (bool)',
    'function allowance(address owner, address spender) view returns (uint256)',
    'function isPrivateMode(address) view returns (bool)',
    'function getPrivateBalance(address) view returns (bytes)',
    'function depositToPrivate(bytes encryptedBalance, uint64 timestamp, bytes signature) returns (bool)',
    'function withdrawToPublic(uint256 amount, bytes newEncryptedBalance, uint64 timestamp, bytes signature) returns (bool)',
    'function privateTransfer(address to, bytes senderNewBalance, uint64 senderTimestamp, bytes senderSignature, bytes recipientNewBalance, uint64 recipientTimestamp, bytes recipientSignature) returns (bool)',
    'function name() view returns (string)',
    'function symbol() view returns (string)',
    'function totalSupply() view returns (uint256)',
  ];

  let connected = false;
  let connecting = false;
  let address = '';
  let walletType = 'none'; // 'metamask', 'para', or 'none'
  let showWalletOptions = false;

  async function connectMetaMask() {
    if (!window.ethereum) {
      toast({ 
        message: 'MetaMask not installed. Try Para Wallet instead!', 
        type: 'is-warning' 
      });
      return;
    }

    connecting = true;
    walletType = 'metamask';
    showWalletOptions = false;
    
    try {
      await window.ethereum.request({ method: 'eth_requestAccounts' });

      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      address = await signer.getAddress();

      // Try to switch/add network
      try {
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: `0x${CONFIG.chainId.toString(16)}` }],
        });
      } catch (switchError) {
        if (switchError.code === 4902) {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [
              {
                chainId: `0x${CONFIG.chainId.toString(16)}`,
                chainName: CONFIG.chainName,
                rpcUrls: [CONFIG.rpcUrl],
                nativeCurrency: {
                  name: 'ETH',
                  symbol: 'ETH',
                  decimals: 18,
                },
              },
            ],
          });
        }
      }

      // HybridPrivacyERC20 - single contract for both public and private functionality
      const faucetToken = new ethers.Contract(
        CONFIG.faucetTokenAddress,
        HYBRID_TOKEN_ABI,
        signer,
      );

      // For backwards compatibility, contract points to the same faucetToken
      // (old code used separate contracts for public/private)
      const contract = faucetToken;

      walletStore.set({
        provider,
        signer,
        contract,
        faucetToken,
        address,
        connected: true,
        walletType: 'metamask',
      });

      connected = true;
      toast({
        message: '✅ MetaMask connected successfully!',
        type: 'is-success',
      });
    } catch (error) {
      console.error('MetaMask connection error:', error);
      toast({ message: 'Failed to connect MetaMask', type: 'is-danger' });
      walletType = 'none';
    } finally {
      connecting = false;
    }
  }

  function connectPara() {
    showWalletOptions = false;
    toast({
      message: 'Para wallet integration coming soon. Please use MetaMask!',
      type: 'is-info',
      duration: 4000
    });
  }

  function toggleWalletOptions() {
    showWalletOptions = !showWalletOptions;
  }

  function shortenAddress(addr) {
    if (!addr) return '';
    return `${addr.substring(0, 8)}...${addr.substring(38)}`;
  }

  onMount(() => {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', () => {
        location.reload();
      });
      window.ethereum.on('chainChanged', () => {
        location.reload();
      });
    }
  });
</script>

<div class="box">
  <div class="level is-mobile">
    <div class="level-left">
      <div class="level-item">
        {#if connected}
          <div>
            <p class="heading is-family-monospace has-text-grey-light">LINK STATUS: ACTIVE</p>
            <p class="title is-6 has-text-primary is-family-monospace">
              {#if walletType === 'metamask'}
                [🦊 {shortenAddress(address)}]
              {:else if walletType === 'para'}
                [🔷 {shortenAddress(address)}]
              {:else}
                [{shortenAddress(address)}]
              {/if}
            </p>
          </div>
        {:else}
          <div>
            <p class="heading is-family-monospace has-text-grey-light">LINK STATUS: DISCONNECTED</p>
            <p class="title is-6 has-text-danger is-family-monospace">NO SIGNAL</p>
          </div>
        {/if}
      </div>
    </div>
    <div class="level-right">
      <div class="level-item">
        {#if !connected}
          <div class="dropdown" class:is-active={showWalletOptions}>
            <div class="dropdown-trigger">
              <button
                class="button is-primary is-small"
                on:click={toggleWalletOptions}
                disabled={connecting}
                class:is-loading={connecting}
              >
                <span class="icon is-small mr-1">
                  <i class="fa fa-plug" />
                </span>
                <span>INIT_CONNECTION</span>
                <span class="icon is-small">
                  <i class="fa fa-angle-down" />
                </span>
              </button>
            </div>
            <div class="dropdown-menu" role="menu">
              <div class="dropdown-content">
                <a class="dropdown-item is-family-monospace" on:click={connectMetaMask}>
                  <span class="icon">
                    <i class="fa fa-firefox" />
                  </span>
                  <span>METAMASK</span>
                </a>
                <a class="dropdown-item is-family-monospace" on:click={connectPara}>
                  <span class="icon">
                    <i class="fa fa-wallet" />
                  </span>
                  <span>PARA WALLET</span>
                </a>
              </div>
            </div>
          </div>
        {:else}
          <button class="button is-success is-small" disabled>
            <span class="icon is-small mr-1"><i class="fa fa-wifi"></i></span>
            <span>CONNECTED</span>
          </button>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
  /* Styles are handled globally in App.svelte */
</style>

