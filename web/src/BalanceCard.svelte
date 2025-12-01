<script>
  import { onMount } from 'svelte';
  import { ethers } from 'ethers';
  import { walletStore, balanceStore } from './stores.js';
  import { toast } from 'bulma-toast';

  let wallet;
  let balances;
  let loading = false;

  walletStore.subscribe((value) => {
    wallet = value;
    if (value.connected) {
      loadBalances();
    }
  });

  balanceStore.subscribe((value) => {
    balances = value;
  });

  async function loadBalances() {
    if (!wallet.connected || !wallet.contract) return;

    loading = true;
    balanceStore.update((b) => ({ ...b, loading: true }));

    try {
      // Get ETH balance
      const ethBal = await wallet.provider.getBalance(wallet.address);
      const ethFormatted = ethers.utils.formatEther(ethBal);

      // Get public token balance
      const publicBal = await wallet.faucetToken.balanceOf(wallet.address);
      const publicBalFormatted = ethers.utils.formatEther(publicBal);

      // Get private balance
      let privateBalance = null;
      let isPrivate = false;
      try {
        // Check if user is in private mode (HybridPrivacyERC20)
        isPrivate = await wallet.faucetToken.isPrivateMode(wallet.address);
        if (isPrivate) {
          const privateBal = await wallet.faucetToken.getPrivateBalance(
            wallet.address,
          );
          if (privateBal && privateBal !== '0x' && privateBal.length > 0) {
            privateBalance = privateBal;
          }
        }
      } catch (e) {
        console.log('No private balance set:', e.message);
      }

      balanceStore.set({
        eth: parseFloat(ethFormatted).toFixed(4),
        publicTokens: parseFloat(publicBalFormatted).toFixed(2),
        privateBalance: privateBalance,
        isPrivateMode: isPrivate,
        loading: false,
      });

      toast({ message: '✅ Balances updated', type: 'is-success' });
    } catch (error) {
      console.error('Error loading balances:', error);
      toast({ message: 'Failed to load balances', type: 'is-danger' });
      balanceStore.update((b) => ({ ...b, loading: false }));
    } finally {
      loading = false;
    }
  }

  function formatPrivateBalance(pb) {
    if (!pb) return 'Not set';
    return pb.substring(0, 20) + '... (encrypted)';
  }
</script>

<div class="card h-100">
  <header class="card-header">
    <p class="card-header-title">
      <span class="icon mr-2">
        <i class="fa fa-hdd-o has-text-primary" />
      </span>
      <span>ASSET_STORAGE</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p class="is-size-7">> ERROR: CONNECTION_REQUIRED</p>
      </div>
    {:else}
      <div class="content">
        <div class="balance-item mb-4">
          <p class="heading is-family-monospace has-text-grey-light mb-1">ETH_BALANCE</p>
          <p class="title is-4 has-text-white is-family-monospace">{balances?.eth || '0'} <span class="is-size-6 has-text-grey">ETH</span></p>
        </div>

        <div class="balance-item mb-4">
          <p class="heading is-family-monospace has-text-grey-light mb-1">PUBLIC_TOKENS</p>
          <p class="title is-4 has-text-white is-family-monospace">{balances?.publicTokens || '0'} <span class="is-size-6 has-text-grey">HALO</span></p>
        </div>

        <div class="balance-item mb-5">
          <p class="heading is-family-monospace has-text-grey-light mb-1">
            PRIVATE_BALANCE
            {#if balances?.isPrivateMode}
              <span class="tag is-success is-small ml-2">ACTIVE</span>
            {/if}
          </p>
          <div class="is-family-monospace has-text-primary is-size-7 text-truncate">
            {formatPrivateBalance(balances?.privateBalance)}
          </div>
        </div>

        <button
          class="button is-primary is-fullwidth mt-auto"
          on:click={loadBalances}
          disabled={loading}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-refresh" />
          </span>
          <span>SYNC_DATA</span>
        </button>
      </div>
    {/if}
  </div>
</div>

<style>
  .h-100 {
    height: 100%;
    display: flex;
    flex-direction: column;
  }
  
  .card-content {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .content {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .mt-auto {
    margin-top: auto;
  }
  
  .text-truncate {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    background: rgba(0, 255, 255, 0.05);
    border: 1px dashed #333;
    padding: 0.5rem;
    color: #00d1b2;
  }
</style>

