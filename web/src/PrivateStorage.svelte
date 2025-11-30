<script>
  import { ethers } from 'ethers';
  import { walletStore, balanceStore, configStore } from './stores.js';
  import { toast } from 'bulma-toast';

  let wallet;
  let config;
  let amount = '';
  let loading = false;
  let status = '';

  walletStore.subscribe((value) => {
    wallet = value;
  });

  configStore.subscribe((value) => {
    config = value;
  });

  async function moveToPrivate() {
    if (!wallet.connected) {
      toast({ message: 'Please connect your wallet', type: 'is-warning' });
      return;
    }

    if (!amount || parseFloat(amount) <= 0) {
      toast({ message: 'Please enter a valid amount', type: 'is-warning' });
      return;
    }

    loading = true;
    try {
      status = 'Step 1/3: Getting encryption from TEE...';

      const teeResponse = await fetch(`${config.teeUrl}/initialize`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          token: config.contractAddress,
          user: wallet.address,
          amount: parseFloat(amount).toFixed(1),
        }),
      });

      const teeData = await teeResponse.json();

      if (!teeData.encrypted_balance || !teeData.signature) {
        throw new Error('TEE failed to encrypt');
      }

      status = 'Step 2/3: Sending transaction...';

      const tx = await wallet.contract.depositToPrivate(
        '0x' + teeData.encrypted_balance,
        teeData.timestamp,
        '0x' + teeData.signature,
      );

      status = 'Step 3/3: Waiting for confirmation...';
      const receipt = await tx.wait();

      toast({
        message: `✅ ${amount} tokens moved to private storage!`,
        type: 'is-success',
      });

      amount = '';
      status = '';

      // Refresh balances
      setTimeout(() => {
        balanceStore.update((b) => ({ ...b, loading: true }));
        location.reload(); // Simple way to refresh
      }, 1000);
    } catch (error) {
      console.error('Error:', error);
      toast({
        message: 'Failed to move to private: ' + error.message,
        type: 'is-danger',
      });
      status = '';
    } finally {
      loading = false;
    }
  }
</script>

<div class="card">
  <header class="card-header has-background-link">
    <p class="card-header-title has-text-white">
      <span class="icon">
        <i class="fa fa-lock" />
      </span>
      <span>Move to Private Storage</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p>Please connect your wallet to use private storage</p>
      </div>
    {:else}
      <div class="content">
        <div class="notification is-info is-light">
          <p class="is-size-7">
            Encrypt your tokens using TEE (Trusted Execution Environment) and
            store them privately on-chain.
          </p>
        </div>

        <div class="field">
          <label class="label">Amount to Move Private</label>
          <div class="control">
            <input
              class="input"
              type="number"
              placeholder="e.g., 100"
              bind:value={amount}
              min="0"
              step="0.01"
              disabled={loading}
            />
          </div>
        </div>

        {#if status}
          <div class="notification is-info is-light">
            <p class="is-size-7">{status}</p>
          </div>
        {/if}

        <button
          class="button is-link is-fullwidth"
          on:click={moveToPrivate}
          disabled={loading || !amount}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-shield" />
          </span>
          <span>Move to Private Storage</span>
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

