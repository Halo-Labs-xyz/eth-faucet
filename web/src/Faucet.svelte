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
    try {
      const res = await fetch('/api/info');
      if (res.ok) {
        faucetInfo = await res.json();
        mounted = true;
      } else {
        console.error('Failed to fetch faucet info:', res.statusText);
        toast({ message: 'Failed to load faucet info', type: 'is-danger' });
      }
    } catch (e) {
      console.error('Error fetching faucet info:', e);
      toast({ message: 'Error connecting to server', type: 'is-danger' });
    }
  });

  // @ts-ignore
  window.hcaptchaOnLoad = () => {
    hcaptchaLoaded = true;
  };

  let widgetID;
  $: if (mounted && hcaptchaLoaded) {
    // @ts-ignore
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
        // @ts-ignore
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
        // @ts-ignore
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
      /** @type {import('bulma-toast').ToastType} */
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

<div class="card h-100">
  <header class="card-header">
    <p class="card-header-title">
      <span class="icon mr-2">
        <i class="fa fa-bolt has-text-info" />
      </span>
      <span>FAUCET_PROTOCOL</span>
    </p>
  </header>
  <div class="card-content">
    <div class="content">
      <div class="notification is-info is-light mb-4">
        <p>
          > NETWORK: {faucetInfo.network}<br>
          > PAYOUT: {faucetInfo.payout} ETH + {faucetInfo.token_payout || '100'} {faucetInfo.symbol}
        </p>
      </div>

      <div id="hcaptcha" data-size="invisible" />

      <div class="field">
        <label class="label" for="target-address-input">TARGET_ADDRESS</label>
        <div class="control has-icons-left">
          <input
            id="target-address-input"
            bind:value={input}
            class="input"
            type="text"
            placeholder="0x..."
            disabled={loading}
          />
          <span class="icon is-small is-left">
            <i class="fa fa-terminal"></i>
          </span>
        </div>
        <p class="help has-text-grey-dark is-family-monospace">
          {#if wallet.connected}
            > SOURCE: WALLET_DETECTED
          {:else}
            > AWAITING_INPUT...
          {/if}
        </p>
      </div>

      <button
        class="button is-info is-fullwidth mt-5"
        on:click={handleRequest}
        disabled={loading || !input}
        class:is-loading={loading}
      >
        <span class="icon">
          <i class="fa fa-download" />
        </span>
        <span>EXECUTE_REQUEST</span>
      </button>
    </div>
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
  
  /* Overrides handled in App.svelte */
</style>
