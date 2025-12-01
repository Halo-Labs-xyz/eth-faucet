package server

type Config struct {
	network         string
	symbol          string
	httpPort        int
	interval        int
	payout          float64
	tokenPayout     float64
	tokenAddress    string
	tokenDecimals   uint8
	provider        string
	proxyCount      int
	hcaptchaSiteKey string
	hcaptchaSecret  string
}

func NewConfig(network, symbol string, httpPort, interval, proxyCount int, payout, tokenPayout float64, tokenAddress string, tokenDecimals uint8, provider, hcaptchaSiteKey, hcaptchaSecret string) *Config {
	return &Config{
		network:         network,
		symbol:          symbol,
		httpPort:        httpPort,
		interval:        interval,
		payout:          payout,
		tokenPayout:     tokenPayout,
		tokenAddress:    tokenAddress,
		tokenDecimals:   tokenDecimals,
		provider:        provider,
		proxyCount:      proxyCount,
		hcaptchaSiteKey: hcaptchaSiteKey,
		hcaptchaSecret:  hcaptchaSecret,
	}
}
