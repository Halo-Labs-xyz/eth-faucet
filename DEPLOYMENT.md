# 🚀 Deployment Guide - Halo Privacy Faucet

## Quick Answer: Vercel Deployment

**You cannot deploy the full faucet to Vercel** because:
- Vercel only supports serverless functions (Node.js, Python, Go functions)
- This faucet needs a **persistent Go server** (not serverless)
- The faucet maintains state (rate limiting, nonce management)

## Recommended Deployment Options

### Option 1: VPS Deployment (Easiest) ⭐

Deploy to a VPS like DigitalOcean, AWS EC2, or your current server.

**Steps:**

1. **Copy files to server**
```bash
# On your local machine
scp -r eth-faucet/ user@your-server:/home/user/
```

2. **Build on server**
```bash
ssh user@your-server
cd /home/user/eth-faucet
./deploy.sh
```

3. **Set up systemd service** (runs automatically)
```bash
sudo nano /etc/systemd/system/halo-faucet.service
```

Add:
```ini
[Unit]
Description=Halo Privacy Faucet
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/halo/eth-faucet
Environment="PRIVATE_KEY=your_private_key_here"
ExecStart=/home/ubuntu/halo/eth-faucet/eth-faucet -httpport 8080 -wallet.provider http://64.34.84.209:34141 -wallet.privkey $PRIVATE_KEY -faucet.amount 1 -faucet.tokenamount 100 -faucet.tokenaddress 0x2210899f4Dd9944bF1b26836330aefEDD4050508 -faucet.name "Halo Privacy Testnet" -faucet.symbol "PRIV"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

4. **Start the service**
```bash
sudo systemctl daemon-reload
sudo systemctl enable halo-faucet
sudo systemctl start halo-faucet
sudo systemctl status halo-faucet
```

5. **Set up nginx reverse proxy**
```bash
sudo apt install nginx
sudo nano /etc/nginx/sites-available/faucet
```

Add:
```nginx
server {
    listen 80;
    server_name faucet.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable:
```bash
sudo ln -s /etc/nginx/sites-available/faucet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

6. **Add SSL with Let's Encrypt**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d faucet.yourdomain.com
```

---

### Option 2: Docker Deployment (Portable)

Deploy to any Docker-compatible platform.

**Platforms that work:**
- Fly.io (easiest)
- Railway.app
- Render.com
- DigitalOcean App Platform
- AWS ECS/Fargate

**Using the existing Dockerfile:**

1. **Build Docker image**
```bash
cd eth-faucet
docker build -t halo-faucet .
```

2. **Run locally**
```bash
docker run -d \
  -p 8080:8080 \
  -e WEB3_PROVIDER=http://64.34.84.209:34141 \
  -e PRIVATE_KEY=your_private_key \
  --name halo-faucet \
  halo-faucet
```

3. **Deploy to Fly.io** (Example)
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Create fly.toml
cat > fly.toml <<EOF
app = "halo-faucet"

[build]
  dockerfile = "Dockerfile"

[env]
  WEB3_PROVIDER = "http://64.34.84.209:34141"
  TOKEN_ADDRESS = "0x2210899f4Dd9944bF1b26836330aefEDD4050508"

[[services]]
  http_checks = []
  internal_port = 8080
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
EOF

# Set secret
flyctl secrets set PRIVATE_KEY=your_private_key

# Deploy
flyctl deploy
```

---

### Option 3: Split Deployment (Frontend on Vercel)

Deploy frontend to Vercel, backend elsewhere.

**This requires modifications:**

1. **Update API calls** in Svelte components to point to backend URL
2. **Deploy backend** to VPS/Docker (Option 1 or 2)
3. **Deploy frontend** to Vercel:

```bash
cd web
vercel --prod
```

**Modify frontend to use external API:**
- Update `src/stores.js` to include backend URL
- Update all API calls to use `BACKEND_URL/api/...`
- Handle CORS on backend

---

## Funding the Faucet Address

### Step 1: Get your faucet address

```bash
cd /home/ubuntu/halo/eth-faucet

# Install ethers if needed
npm install ethers

# Get the address
node get-faucet-address.js YOUR_PRIVATE_KEY
```

This will show you the Ethereum address that will distribute tokens.

### Step 2: Fund the address

Send to the displayed address:
- **ETH**: At least 10 ETH (for gas + distributions)
  - Each user gets: 1 ETH
  - Gas for token transfers: ~0.001-0.01 ETH per request
  - 10 ETH = ~100 users

- **PRIV Tokens**: At least 10,000 tokens
  - Each user gets: 100 PRIV
  - 10,000 PRIV = 100 users

### Step 3: Verify balance

```bash
# Check ETH balance
cast balance FAUCET_ADDRESS --rpc-url http://64.34.84.209:34141

# Check token balance
cast call 0x2210899f4Dd9944bF1b26836330aefEDD4050508 \
  "balanceOf(address)(uint256)" \
  FAUCET_ADDRESS \
  --rpc-url http://64.34.84.209:34141
```

---

## Recommended Setup for Production

1. **VPS with systemd** (auto-restart on crashes)
2. **Nginx reverse proxy** (SSL, caching, security)
3. **Let's Encrypt SSL** (HTTPS)
4. **Firewall rules** (only allow 80, 443, SSH)
5. **Monitoring** (uptime checks, logs)
6. **Backups** (configuration files)

---

## Quick Deploy for Testing (Current Server)

You can test the faucet right now on your current server:

```bash
cd /home/ubuntu/halo/eth-faucet

# 1. Get faucet address
node get-faucet-address.js YOUR_PRIVATE_KEY

# 2. Fund that address with ETH and PRIV tokens

# 3. Start faucet
export PRIVATE_KEY='your_private_key'
./run-faucet.sh
```

Access at: `http://YOUR_SERVER_IP:8080`

---

## Security Notes

- Never commit private keys to git
- Use environment variables for secrets
- Run behind nginx with SSL in production
- Enable firewall (ufw/iptables)
- Monitor faucet balance regularly
- Set up log rotation
- Use rate limiting at nginx level too

---

## Summary

**For quick testing:** Use current server with `./run-faucet.sh`
**For production:** Use VPS + systemd + nginx + SSL
**Cannot use:** Vercel (Go backend needs persistent server)

**Next steps:**
1. Get your faucet address with `get-faucet-address.js`
2. Fund it with ETH and PRIV tokens
3. Run the faucet
4. Test the interface
5. Set up production deployment if satisfied

