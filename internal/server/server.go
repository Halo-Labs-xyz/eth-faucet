package server

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	log "github.com/sirupsen/logrus"
	"github.com/urfave/negroni/v3"

	"github.com/chainflag/eth-faucet/internal/chain"
	"github.com/chainflag/eth-faucet/web"
)

type Server struct {
	chain.TxBuilder
	cfg *Config
}

func NewServer(builder chain.TxBuilder, cfg *Config) *Server {
	return &Server{
		TxBuilder: builder,
		cfg:       cfg,
	}
}

func (s *Server) setupRouter() *http.ServeMux {
	router := http.NewServeMux()

	// API handlers first
	limiter := NewLimiter(s.cfg.proxyCount, time.Duration(s.cfg.interval)*time.Minute)
	hcaptcha := NewCaptcha(s.cfg.hcaptchaSiteKey, s.cfg.hcaptchaSecret)
	router.Handle("/api/claim", negroni.New(limiter, hcaptcha, negroni.Wrap(s.handleClaim())))
	router.Handle("/api/info", s.handleInfo())

	// Static file serving as catch-all
	router.Handle("/", http.FileServer(web.Dist()))

	return router
}

func (s *Server) Run() {
	n := negroni.New(negroni.NewRecovery(), negroni.NewLogger())
	n.UseHandler(s.setupRouter())
	log.Infof("Starting http server %d", s.cfg.httpPort)
	log.Fatal(http.ListenAndServe(":"+strconv.Itoa(s.cfg.httpPort), n))
}

func (s *Server) handleClaim() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "POST" {
			http.NotFound(w, r)
			return
		}

		// The error always be nil since it has already been handled in limiter
		address, _ := readAddress(r)
		ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
		defer cancel()

		var messages []string

		// Send ETH
		txHash, err := s.Transfer(ctx, address, chain.EtherToWei(s.cfg.payout))
		if err != nil {
			log.WithError(err).Error("Failed to send ETH transaction")
			renderJSON(w, claimResponse{Message: "Failed to send ETH: " + err.Error()}, http.StatusInternalServerError)
			return
		}
		log.WithFields(log.Fields{
			"txHash":  txHash,
			"address": address,
			"amount":  s.cfg.payout,
		}).Info("ETH sent successfully")
		messages = append(messages, fmt.Sprintf("ETH: %s", txHash.Hex()))

		// Send ERC20 tokens if configured
		if s.cfg.tokenAddress != "" && s.cfg.tokenPayout > 0 {
			time.Sleep(100 * time.Millisecond) // Small delay to avoid nonce issues
			tokenTxHash, err := s.TransferERC20(ctx, s.cfg.tokenAddress, address, chain.EtherToWei(s.cfg.tokenPayout))
			if err != nil {
				log.WithError(err).Error("Failed to send token transaction")
				// Don't fail the entire request if token transfer fails
				messages = append(messages, fmt.Sprintf("Token transfer failed: %s", err.Error()))
			} else {
				log.WithFields(log.Fields{
					"txHash":  tokenTxHash,
					"address": address,
					"amount":  s.cfg.tokenPayout,
					"token":   s.cfg.tokenAddress,
				}).Info("Tokens sent successfully")
				messages = append(messages, fmt.Sprintf("Tokens: %s", tokenTxHash.Hex()))
			}
		}

		resp := claimResponse{Message: fmt.Sprintf("✅ Success! Txs: %s", strings.Join(messages, " | "))}
		renderJSON(w, resp, http.StatusOK)
	}
}

func (s *Server) handleInfo() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" {
			http.NotFound(w, r)
			return
		}
		renderJSON(w, infoResponse{
			Account:         s.Sender().String(),
			Network:         s.cfg.network,
			Symbol:          s.cfg.symbol,
			Payout:          strconv.FormatFloat(s.cfg.payout, 'f', -1, 64),
			TokenPayout:     strconv.FormatFloat(s.cfg.tokenPayout, 'f', -1, 64),
			TokenAddress:    s.cfg.tokenAddress,
			HcaptchaSiteKey: s.cfg.hcaptchaSiteKey,
		}, http.StatusOK)
	}
}
