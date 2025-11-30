<script>
  import { ethers } from 'ethers';
  import { getAddress } from '@ethersproject/address';
  import { walletStore, balanceStore, configStore } from './stores.js';
  import { toast } from 'bulma-toast';

  let wallet;
  let config;
  let recipient = '';
  let amount = '';
  let loading = false;
  let status = '';

  walletStore.subscribe((value) => {
    wallet = value;
  });

  configStore.subscribe((value) => {
    config = value;
  });

  async function sendPrivateTransfer() {
    if (!wallet.connected) {
      toast({ message: 'Please connect your wallet', type: 'is-warning' });
      return;
    }

    try {
      const validAddress = getAddress(recipient);
    } catch (error) {
      toast({ message: 'Invalid recipient address', type: 'is-warning' });
      return;
    }

    if (!amount || parseFloat(amount) <= 0) {
      toast({ message: 'Please enter a valid amount', type: 'is-warning' });
      return;
    }

    loading = true;
    try {
      status = 'Step 1/3: Getting TEE encryption...';

      const teeResponse = await fetch(`${config.teeUrl}/initialize`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          token: config.contractAddress,
          user: recipient,
          amount: parseFloat(amount).toFixed(1),
        }),
      });

      const teeData = await teeResponse.json();

      if (!teeData.encrypted_balance || !teeData.signature) {
        throw new Error('TEE failed to encrypt');
      }

      status = 'Step 2/3: Sending transaction...';

      const tx = await wallet.contract.privateTransfer(
        recipient,
        '0x' + teeData.encrypted_balance,
        '0x' + teeData.signature,
      );

      status = 'Step 3/3: Waiting for confirmation...';
      const receipt = await tx.wait();

      const shortRecipient = `${recipient.substring(0, 8)}...${recipient.substring(38)}`;
      toast({
        message: `✅ ${amount} tokens sent privately to ${shortRecipient}!`,
        type: 'is-success',
        duration: 5000,
      });

      recipient = '';
      amount = '';
      status = '';

      // Refresh balances
      setTimeout(() => {
        location.reload();
      }, 1000);
    } catch (error) {
      console.error('Error:', error);
      toast({
        message: 'Failed to send private transfer: ' + error.message,
        type: 'is-danger',
      });
      status = '';
    } finally {
      loading = false;
    }
  }
</script>

<div class="card">
  <header class="card-header has-background-danger">
    <p class="card-header-title has-text-white">
      <span class="icon">
        <i class="fa fa-paper-plane" />
      </span>
      <span>Private Transfer</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p>Please connect your wallet to send private transfers</p>
      </div>
    {:else}
      <div class="content">
        <div class="notification is-info is-light">
          <p class="is-size-7">
            Send privately encrypted tokens to another address. The amount is
            hidden from public view.
          </p>
        </div>

        <div class="field">
          <label class="label">Recipient Address</label>
          <div class="control">
            <input
              class="input"
              type="text"
              placeholder="0x..."
              bind:value={recipient}
              disabled={loading}
            />
          </div>
        </div>

        <div class="field">
          <label class="label">Amount</label>
          <div class="control">
            <input
              class="input"
              type="number"
              placeholder="e.g., 50"
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
          class="button is-danger is-fullwidth"
          on:click={sendPrivateTransfer}
          disabled={loading || !recipient || !amount}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-send" />
          </span>
          <span>Send Private Transfer</span>
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

