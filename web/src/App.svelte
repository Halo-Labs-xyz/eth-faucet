<script>
  import 'animate.css';
  import 'bulma/css/bulma.css';
  import { setDefaults as setToast } from 'bulma-toast';
  import WalletConnect from './WalletConnect.svelte';
  import Faucet from './Faucet.svelte';
  import BalanceCard from './BalanceCard.svelte';
  import PrivateStorage from './PrivateStorage.svelte';
  import PrivateTransfer from './PrivateTransfer.svelte';

  setToast({
    position: 'bottom-center',
    dismissible: true,
    pauseOnHover: true,
    closeOnClick: false,
    animate: { in: 'fadeIn', out: 'fadeOut' },
    duration: 4000,
  });
</script>

<svelte:head>
  <link
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
    rel="stylesheet"
  />
  <title>Halo Privacy Network</title>
</svelte:head>

<section class="hero is-primary is-bold">
  <div class="hero-body">
    <div class="container">
      <h1 class="title is-1">
        <span class="icon is-large">
          <i class="fa fa-shield" />
        </span>
        Halo Privacy Network
      </h1>
      <p class="subtitle is-4">
        Get testnet tokens • Move to private storage • Send private transfers
      </p>
    </div>
  </div>
</section>

<section class="section">
  <div class="container">
    <WalletConnect />

    <div class="columns is-multiline mt-4">
      <div class="column is-half">
        <Faucet />
      </div>

      <div class="column is-half">
        <BalanceCard />
      </div>

      <div class="column is-half">
        <PrivateStorage />
      </div>

      <div class="column is-half">
        <PrivateTransfer />
      </div>
    </div>
  </div>
</section>

<footer class="footer">
  <div class="content has-text-centered">
    <p>
      <strong>Halo Privacy Network</strong> - Privacy-preserving token
      transfers with TEE
    </p>
    <p class="is-size-7">
      Powered by Trusted Execution Environment (TEE) and homomorphic encryption
    </p>
  </div>
</footer>

<style>
  :global(body) {
    background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);
    min-height: 100vh;
  }

  .section {
    padding: 2rem 1.5rem;
  }

  .footer {
    background-color: #f5f5f5;
    margin-top: 3rem;
  }
</style>
