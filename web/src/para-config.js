// Para Wallet Configuration
// Get your API key from: https://docs.getpara.com/

import ParaWeb, { Environment } from "@getpara/web-sdk";

export const PARA_CONFIG = {
  // Para API key
  apiKey: 'beta_75d2c567ed284979eb985074170927ae',
  
  // Para environment (BETA or PRODUCTION)
  environment: Environment.BETA,
  
  // Chain configuration for Halo
  chainConfig: {
    chainId: 999999,
    chainName: 'Halo Privacy Testnet',
    rpcUrl: 'http://64.34.84.209:34141',
    currency: {
      name: 'ETH',
      symbol: 'ETH',
      decimals: 18
    }
  }
};

// Initialize Para SDK instance
let paraInstance = null;

export function getPara() {
  if (!paraInstance) {
    paraInstance = new ParaWeb(PARA_CONFIG.environment, PARA_CONFIG.apiKey);
  }
  return paraInstance;
}

// Export for easy updates
export function updateParaApiKey(newKey) {
  PARA_CONFIG.apiKey = newKey;
}

