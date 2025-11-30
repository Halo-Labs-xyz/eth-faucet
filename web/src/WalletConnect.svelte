<script>
  import { onMount } from 'svelte';
  import { ethers } from 'ethers';
  import { walletStore } from './stores.js';
  import { toast } from 'bulma-toast';

  const CONFIG = {
    rpcUrl: 'http://64.34.84.209:34141',
    chainId: 999999,
    chainName: 'Halo Privacy Testnet',
    contractAddress: '0x2210899f4Dd9944bF1b26836330aefEDD4050508',
  };

  const CONTRACT_ABI = [
    'function balanceOf(address) view returns (uint256)',
    'function getPrivateBalance(address) view returns (bytes)',
    'function hasPrivateBalance(address) view returns (bool)',
    'function depositToPrivate(bytes encryptedBalance, uint64 timestamp, bytes signature)',
    'function privateTransfer(address to, bytes encryptedAmount, bytes signature)',
  ];

  let connected = false;
  let connecting = false;
  let address = '';

  async function connectWallet() {
    if (!window.ethereum) {
      toast({ message: 'Please install MetaMask!', type: 'is-danger' });
      return;
    }

    connecting = true;
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

      const contract = new ethers.Contract(
        CONFIG.contractAddress,
        CONTRACT_ABI,
        signer,
      );

      walletStore.set({
        provider,
        signer,
        contract,
        address,
        connected: true,
      });

      connected = true;
      toast({
        message: '✅ Wallet connected successfully!',
        type: 'is-success',
      });
    } catch (error) {
      console.error('Connection error:', error);
      toast({ message: 'Failed to connect wallet', type: 'is-danger' });
    } finally {
      connecting = false;
    }
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

<div class="box has-background-white-bis">
  <div class="level is-mobile">
    <div class="level-left">
      <div class="level-item">
        {#if connected}
          <div>
            <p class="heading">Connected Wallet</p>
            <p class="title is-6">
              <span class="tag is-success is-medium">
                {shortenAddress(address)}
              </span>
            </p>
          </div>
        {:else}
          <div>
            <p class="heading">Wallet Status</p>
            <p class="title is-6">Not connected</p>
          </div>
        {/if}
      </div>
    </div>
    <div class="level-right">
      <div class="level-item">
        <button
          class="button is-primary"
          on:click={connectWallet}
          disabled={connected || connecting}
          class:is-loading={connecting}
        >
          {#if connected}
            ✅ Connected
          {:else if connecting}
            Connecting...
          {:else}
            Connect MetaMask
          {/if}
        </button>
      </div>
    </div>
  </div>
</div>

<style>
  .box {
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
</style>

