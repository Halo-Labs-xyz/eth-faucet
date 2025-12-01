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

<div class="card h-100">
  <header class="card-header">
    <p class="card-header-title">
      <span class="icon mr-2">
        <i class="fa fa-user-secret has-text-danger" />
      </span>
      <span>PRIVATE_TX</span>
    </p>
  </header>
  <div class="card-content">
    {#if !wallet.connected}
      <div class="notification is-info is-light">
        <p class="is-size-7">> ERROR: CONNECTION_REQUIRED</p>
      </div>
    {:else}
      <div class="content">
        <div class="notification is-warning is-light mb-5">
          <p class="is-size-7">
            > WARNING: ZK_MODE_ACTIVE<br>
            > DESTINATION_ANONYMITY: ENABLED
          </p>
        </div>

        <div class="field">
          <label class="label">TARGET_ID</label>
          <div class="control has-icons-left">
            <input
              class="input"
              type="text"
              placeholder="0x..."
              bind:value={recipient}
              disabled={loading}
            />
            <span class="icon is-small is-left">
              <i class="fa fa-id-card"></i>
            </span>
          </div>
        </div>

        <div class="field">
          <label class="label">TX_VOLUME</label>
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
              <i class="fa fa-bolt"></i>
            </span>
          </div>
        </div>

        {#if status}
          <div class="notification is-success is-light">
            <p class="is-size-7 has-text-weight-medium">> {status}</p>
          </div>
        {/if}

        <button
          class="button is-danger is-fullwidth mt-5"
          on:click={sendPrivateTransfer}
          disabled={loading || !recipient || !amount}
          class:is-loading={loading}
        >
          <span class="icon">
            <i class="fa fa-share-square-o" />
          </span>
          <span>EXECUTE_TRANSFER</span>
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

