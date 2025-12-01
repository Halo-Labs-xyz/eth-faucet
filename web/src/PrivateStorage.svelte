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

<div class="card h-100">
  <header class="card-header">
    <p class="card-header-title">
      <span class="icon mr-2">
        <i class="fa fa-lock has-text-link" />
      </span>
      <span>TEE_ENCRYPTION</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p class="is-size-7">> ERROR: CONNECTION_REQUIRED</p>
      </div>
    {:else}
      <div class="content">
        <div class="notification is-info is-light mb-5">
          <p class="is-size-7">
            > INITIATING_PROTOCOL: TEE_ENCRYPT<br>
            > STATUS: READY_FOR_INPUT
          </p>
        </div>

        <div class="field">
          <label class="label">ENCRYPTION_AMOUNT</label>
          <div class="control has-icons-left">
            <input
              class="input"
              type="number"
              placeholder="0.00"
              bind:value={amount}
              min="0"
              step="0.01"
              disabled={loading}
            />
            <span class="icon is-small is-left">
              <i class="fa fa-database"></i>
            </span>
          </div>
        </div>

        {#if status}
          <div class="notification is-success is-light">
            <p class="is-size-7 has-text-weight-medium">> {status}</p>
          </div>
        {/if}

        <button
          class="button is-link is-fullwidth mt-5"
          on:click={moveToPrivate}
          disabled={loading || !amount}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-shield" />
          </span>
          <span>INITIATE_SHIELDING</span>
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
  }
</style>

