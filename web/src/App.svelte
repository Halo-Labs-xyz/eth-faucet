<script>
  import 'animate.css';
  import 'bulma/css/bulma.css';
  import { setDefaults as setToast } from 'bulma-toast';
  import WalletConnect from './WalletConnect.svelte';
  import Faucet from './Faucet.svelte';
  import BalanceCard from './BalanceCard.svelte';
  import PrivateStorage from './PrivateStorage.svelte';
  import PrivateTransfer from './PrivateTransfer.svelte';
  import MoonlightBackground from './MoonlightBackground.svelte';

  setToast({
    message: '', // Hack to satisfy TS type requirement
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
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <title>Halo Privacy Network</title>
</svelte:head>

<div class="app-container">
  <MoonlightBackground />
  <div class="scanlines"></div>
  <section class="hero is-medium">
  <div class="hero-body">
      <div class="container has-text-centered">
        <h1 class="title is-1 has-text-white mb-2 glitch-text" data-text="HALO PRIVACY">
          HALO NETWORK FAUCET
      </h1>
        <p class="subtitle is-6 has-text-primary is-family-monospace is-uppercase tracking-widest">
      </p>
    </div>
  </div>
</section>

  <section class="section main-content">
  <div class="container">
      <div class="columns is-centered mb-6">
        <div class="column is-8-desktop is-10-tablet">
    <WalletConnect />
        </div>
      </div>

      <div class="columns is-multiline">
        <div class="column is-half-desktop">
          <Faucet />
        </div>

        <div class="column is-half-desktop">
        <BalanceCard />
      </div>

        <div class="column is-half-desktop">
        <PrivateStorage />
        </div>

        <div class="column is-half-desktop">
          <PrivateTransfer />
        </div>
      </div>

      <div class="how-it-works mt-6">
        <div class="columns">
          <div class="column is-4">
            <div class="step-card">
              <div class="step-number">01</div>
              <h3 class="title is-5 has-text-white is-family-monospace">ACQUIRE</h3>
              <p class="is-size-7 has-text-grey-light">Request testnet assets via Faucet protocol.</p>
            </div>
          </div>
          <div class="column is-4">
            <div class="step-card">
              <div class="step-number">02</div>
              <h3 class="title is-5 has-text-white is-family-monospace">ENCRYPT</h3>
              <p class="is-size-7 has-text-grey-light">Initiate TEE encryption sequence for asset shielding.</p>
            </div>
          </div>
          <div class="column is-4">
            <div class="step-card">
              <div class="step-number">03</div>
              <h3 class="title is-5 has-text-white is-family-monospace">TRANSMIT</h3>
              <p class="is-size-7 has-text-grey-light">Execute private transfer. Zero-knowledge verification.</p>
            </div>
          </div>
        </div>
    </div>
  </div>
</section>

<footer class="footer">
    <div class="content has-text-centered has-text-grey-dark">
      <p class="is-family-monospace is-size-7">
        <span class="has-text-primary">SYSTEM STATUS:</span> OPERATIONAL <span class="mx-2">|</span> VERSION: 1.2.0-BETA
    </p>
  </div>
</footer>
</div>

<style>
  :global(body) {
    font-family: 'Inter', sans-serif;
    background-color: transparent;
    color: #e0e0e0;
    min-height: 100vh;
    overflow-x: hidden;
  }

  .app-container {
    /* Background handled by MoonlightBackground component */
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    position: relative;
  }

  .scanlines {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(
      0deg,
      rgba(0, 0, 0, 0.15),
      rgba(0, 0, 0, 0.15) 1px,
      transparent 1px,
      transparent 2px
    );
    pointer-events: none;
    z-index: 999;
  }

  .hero-body {
    padding-bottom: 2rem;
    padding-top: 4rem;
  }

  .glitch-text {
    font-family: 'Share Tech Mono', monospace;
    position: relative;
    color: #fff;
    letter-spacing: 0.1em;
    text-shadow: 2px 2px 0px rgba(0, 255, 255, 0.3), -2px -2px 0px rgba(255, 0, 100, 0.3);
  }
  
  .is-family-monospace {
    font-family: 'Share Tech Mono', monospace !important;
  }
  
  .tracking-widest {
    letter-spacing: 0.2em;
  }

  .footer {
    background-color: transparent;
    padding: 3rem 1.5rem;
  }

  .step-card {
    background: rgba(10, 10, 10, 0.8);
    border: 1px solid #333;
    padding: 1.5rem;
    height: 100%;
    position: relative;
    transition: all 0.3s ease;
  }
  
  .step-card::before {
    content: '';
    position: absolute;
    top: -1px;
    left: -1px;
    width: 10px;
    height: 10px;
    border-top: 2px solid #00d1b2;
    border-left: 2px solid #00d1b2;
    transition: all 0.3s ease;
  }
  
  .step-card::after {
    content: '';
    position: absolute;
    bottom: -1px;
    right: -1px;
    width: 10px;
    height: 10px;
    border-bottom: 2px solid #00d1b2;
    border-right: 2px solid #00d1b2;
    transition: all 0.3s ease;
  }

  .step-card:hover {
    background: rgba(20, 20, 20, 0.9);
    box-shadow: 0 0 15px rgba(0, 209, 178, 0.2);
    border-color: #00d1b2;
  }
  
  .step-number {
    font-family: 'Share Tech Mono', monospace;
    font-size: 3rem;
    opacity: 0.1;
    position: absolute;
    top: 0.5rem;
    right: 1rem;
    font-weight: bold;
  }

  /* Global overrides for HUD style */
  :global(.card) {
    background-color: rgba(5, 5, 5, 0.8) !important;
    backdrop-filter: blur(4px);
    border: 1px solid #333;
    border-radius: 0 !important; /* Sharp corners */
    box-shadow: none !important;
    position: relative;
  }
  
  /* Corner accents for cards */
  :global(.card::before) {
    content: '';
    position: absolute;
    top: -1px;
    left: -1px;
    width: 20px;
    height: 20px;
    border-top: 2px solid #444;
    border-left: 2px solid #444;
    z-index: 10;
  }
  
  :global(.card::after) {
    content: '';
    position: absolute;
    bottom: -1px;
    right: -1px;
    width: 20px;
    height: 20px;
    border-bottom: 2px solid #444;
    border-right: 2px solid #444;
    z-index: 10;
  }

  :global(.card-header) {
    background: transparent !important;
    border-bottom: 1px solid #222 !important;
    box-shadow: none !important;
  }

  :global(.card-header-title) {
    color: #00d1b2 !important;
    font-family: 'Share Tech Mono', monospace;
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  :global(.label) {
    color: #888 !important;
    font-family: 'Share Tech Mono', monospace;
    font-size: 0.8rem;
    text-transform: uppercase;
  }

  :global(.input) {
    background-color: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid #333 !important;
    color: #00d1b2 !important;
    border-radius: 0 !important;
    font-family: 'Share Tech Mono', monospace;
    box-shadow: none !important;
  }

  :global(.input:focus) {
    border-color: #00d1b2 !important;
    box-shadow: 0 0 5px rgba(0, 209, 178, 0.3) !important;
  }

  :global(.input::placeholder) {
    color: #444 !important;
  }
  
  :global(.content h1, .content h2, .content h3, .content h4, .content h5, .content h6) {
    color: #e0e0e0 !important;
    font-family: 'Share Tech Mono', monospace;
  }

  :global(.notification.is-light),
  :global(.notification.is-info.is-light),
  :global(.notification.is-warning.is-light),
  :global(.notification.is-success.is-light) {
    background-color: rgba(0, 20, 20, 0.5) !important;
    color: #00d1b2 !important;
    border-left: 2px solid #00d1b2;
    border-radius: 0 !important;
    font-family: 'Share Tech Mono', monospace;
    font-size: 0.8rem;
  }

  :global(.button) {
    border-radius: 0 !important;
    font-family: 'Share Tech Mono', monospace;
    text-transform: uppercase;
    letter-spacing: 1px;
    border: 1px solid transparent !important;
    transition: all 0.2s;
  }
  
  :global(.button.is-primary), :global(.button.is-info), :global(.button.is-success), :global(.button.is-link), :global(.button.is-danger) {
    background-color: transparent !important;
    border: 1px solid currentColor !important;
  }
  
  :global(.button:hover) {
    background-color: currentColor !important;
    color: #000 !important;
    box-shadow: 0 0 10px currentColor;
  }
  
  :global(.button.is-loading::after) {
    border-color: transparent transparent #fff #fff !important;
  }

  :global(.box) {
    background-color: rgba(5, 5, 5, 0.9) !important;
    color: #e0e0e0 !important;
    border: 1px solid #333;
    border-radius: 0 !important;
  }
  
  :global(.tag) {
    border-radius: 0 !important;
    font-family: 'Share Tech Mono', monospace;
  }
</style>
