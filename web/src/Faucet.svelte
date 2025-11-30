<script>
  import { onMount } from 'svelte';
  import { getAddress } from '@ethersproject/address';
  import { CloudflareProvider } from '@ethersproject/providers';
  import { walletStore } from './stores.js';
  import { toast } from 'bulma-toast';

  let wallet;
  let input = null;
  let faucetInfo = {
    account: '0x0000000000000000000000000000000000000000',
    network: 'testnet',
    payout: 1,
    symbol: 'ETH',
    hcaptcha_sitekey: '',
  };

  let mounted = false;
  let hcaptchaLoaded = false;
  let loading = false;

  walletStore.subscribe((value) => {
    wallet = value;
    if (value.connected && !input) {
      input = value.address;
    }
  });

  onMount(async () => {
    const res = await fetch('/api/info');
    faucetInfo = await res.json();
    mounted = true;
  });

  window.hcaptchaOnLoad = () => {
    hcaptchaLoaded = true;
  };

  let widgetID;
  $: if (mounted && hcaptchaLoaded) {
    widgetID = window.hcaptcha.render('hcaptcha', {
      sitekey: faucetInfo.hcaptcha_sitekey,
    });
  }

  async function handleRequest() {
    let address = input;
    if (address === null || address === '') {
      toast({ message: 'Address required', type: 'is-warning' });
      return;
    }

    if (address.endsWith('.eth')) {
      try {
        const provider = new CloudflareProvider();
        address = await provider.resolveName(address);
        if (!address) {
          toast({ message: 'Invalid ENS name', type: 'is-warning' });
          return;
        }
      } catch (error) {
        toast({ message: error.reason, type: 'is-warning' });
        return;
      }
    }

    try {
      address = getAddress(address);
    } catch (error) {
      toast({ message: 'Invalid address', type: 'is-warning' });
      return;
    }

    loading = true;
    try {
      let headers = {
        'Content-Type': 'application/json',
      };

      if (hcaptchaLoaded) {
        const { response } = await window.hcaptcha.execute(widgetID, {
          async: true,
        });
        headers['h-captcha-response'] = response;
      }

      const res = await fetch('/api/claim', {
        method: 'POST',
        headers,
        body: JSON.stringify({
          address,
        }),
      });

      let { msg } = await res.json();
      let type = res.ok ? 'is-success' : 'is-warning';
      toast({ message: msg, type });

      if (res.ok && wallet.connected) {
        setTimeout(() => location.reload(), 2000);
      }
    } catch (err) {
      console.error(err);
      toast({ message: 'Request failed', type: 'is-danger' });
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  {#if mounted && faucetInfo.hcaptcha_sitekey}
    <script
      src="https://hcaptcha.com/1/api.js?onload=hcaptchaOnLoad&render=explicit"
      async
      defer
    ></script>
  {/if}
</svelte:head>

<div class="card">
  <header class="card-header has-background-info">
    <p class="card-header-title has-text-white">
      <span class="icon">
        <i class="fa fa-tint" />
      </span>
      <span>Testnet Faucet</span>
    </p>
  </header>
  <div class="card-content">
    <div class="content">
      <div class="notification is-info is-light">
        <p class="is-size-7">
          <strong>Network:</strong>
          {faucetInfo.network}
          <br />
          <strong>ETH Payout:</strong>
          {faucetInfo.payout} ETH (for gas fees)
          <br />
          <strong>Token Payout:</strong>
          {faucetInfo.token_payout || '100'}
          {faucetInfo.symbol} tokens
          <br />
          <strong>Token Contract:</strong>
          <span style="font-size: 0.75em; font-family: monospace;">
            {faucetInfo.token_address || 'Not configured'}
          </span>
          <br />
          <strong>Faucet Address:</strong>
          <span style="font-size: 0.75em; font-family: monospace;">
            {faucetInfo.account}
          </span>
        </p>
      </div>

      <div class="notification is-warning is-light">
        <p class="is-size-7">
          Request testnet ETH (for gas) and {faucetInfo.symbol} tokens (for
          private transfers). You can request once every 24 hours.
        </p>
      </div>

      <div id="hcaptcha" data-size="invisible" />

      <div class="field">
        <label class="label">Your Address</label>
        <div class="control">
          <input
            bind:value={input}
            class="input"
            type="text"
            placeholder="Enter your address or ENS name"
            disabled={loading}
          />
        </div>
        <p class="help">
          {#if wallet.connected}
            Using connected wallet address
          {:else}
            Or connect your wallet to auto-fill
          {/if}
        </p>
      </div>

      <button
        class="button is-info is-fullwidth"
        on:click={handleRequest}
        disabled={loading || !input}
        class:is-loading={loading}
      >
        <span class="icon">
          <i class="fa fa-money" />
        </span>
        <span>Request ETH + Tokens</span>
      </button>
    </div>
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
