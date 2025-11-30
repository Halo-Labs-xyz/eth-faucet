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
      const publicBal = await wallet.contract.balanceOf(wallet.address);
      const publicBalFormatted = ethers.utils.formatEther(publicBal);

      // Get private balance
      let privateBalance = null;
      try {
        const hasPrivate = await wallet.contract.hasPrivateBalance(
          wallet.address,
        );
        if (hasPrivate) {
          const privateBal = await wallet.contract.getPrivateBalance(
            wallet.address,
          );
          if (privateBal && privateBal !== '0x') {
            privateBalance = privateBal;
          }
        }
      } catch (e) {
        console.log('No private balance set');
      }

      balanceStore.set({
        eth: parseFloat(ethFormatted).toFixed(4),
        publicTokens: parseFloat(publicBalFormatted).toFixed(2),
        privateBalance: privateBalance,
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

<div class="card">
  <header class="card-header has-background-primary">
    <p class="card-header-title has-text-white">
      <span class="icon">
        <i class="fa fa-wallet" />
      </span>
      <span>Balances</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p>Please connect your wallet to view balances</p>
      </div>
    {:else}
      <div class="content">
        <div class="level is-mobile mb-3">
          <div class="level-left">
            <div class="level-item">
              <div>
                <p class="heading">ETH Balance</p>
                <p class="title is-5">{balances?.eth || '0'} ETH</p>
              </div>
            </div>
          </div>
        </div>

        <div class="level is-mobile mb-3">
          <div class="level-left">
            <div class="level-item">
              <div>
                <p class="heading">Public Tokens</p>
                <p class="title is-5">{balances?.publicTokens || '0'}</p>
              </div>
            </div>
          </div>
        </div>

        <div class="level is-mobile mb-3">
          <div class="level-left">
            <div class="level-item">
              <div>
                <p class="heading">Private Balance</p>
                <p class="title is-6 has-text-grey">
                  {formatPrivateBalance(balances?.privateBalance)}
                </p>
              </div>
            </div>
          </div>
        </div>

        <button
          class="button is-success is-fullwidth"
          on:click={loadBalances}
          disabled={loading}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-refresh" />
          </span>
          <span>Refresh Balances</span>
        </button>
      </div>
    {/if}
  </div>
</div>

<style>
  .card {
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .card-header {
    border-radius: 12px 12px 0 0;
  }
</style>

