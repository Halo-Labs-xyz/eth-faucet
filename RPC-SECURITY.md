# 🔒 RPC Security Quick Reference

## Current Status: SECURED ✅

**Date Secured:** November 30, 2025
**RPC Port:** 34141
**Status:** BLOCKED from public internet

---

## What Was Done

1. ✅ Enabled UFW firewall
2. ✅ Allowed essential ports (SSH, HTTP, Faucet)
3. ✅ Added iptables rule to DOCKER-USER chain to block port 34141
4. ✅ Made rules persistent (survive reboots)

---

## Current Access

| Service | Port | Access | URL |
|---------|------|--------|-----|
| **RPC** | 34141 | 🔒 Localhost only | http://127.0.0.1:34141 |
| **Faucet** | 8080 | 🌐 Public | http://64.34.84.209:8080 |
| **SSH** | 22 | 🌐 Public | - |
| **HTTP** | 80 | 🌐 Public | - |
| **HTTPS** | 443 | 🌐 Public | - |

---

## Unblock RPC (Re-open to Public)

If you want to make the RPC public again:

```bash
# 1. Remove the iptables block
sudo iptables -D DOCKER-USER -p tcp --dport 34141 -j DROP

# 2. Save the change
sudo netfilter-persistent save

# 3. Verify
sudo iptables -L DOCKER-USER -n

# 4. Test from outside
curl -X POST http://64.34.84.209:34141 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}'
```

---

## Block RPC Again

To re-secure after opening:

```bash
# 1. Add the block rule
sudo iptables -I DOCKER-USER -p tcp --dport 34141 -j DROP

# 2. Save
sudo netfilter-persistent save

# 3. Verify blocked
sudo iptables -L DOCKER-USER -n
```

---

## Check Current Status

```bash
# View iptables rules
sudo iptables -L DOCKER-USER -n -v

# Check if port is blocked (should timeout if blocked)
timeout 5 curl http://64.34.84.209:34141

# Check localhost still works (should return block number)
curl -X POST http://127.0.0.1:34141 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}'
```

---

## Troubleshooting

### RPC not accessible from localhost

```bash
# Check if Docker container is running
sudo docker ps | grep 34141

# Check iptables rules
sudo iptables -L DOCKER-USER -n

# Restart Docker container if needed
sudo docker restart cdk-erigon-sequencer-001--0c9ae64d07d144e992bc76ca30acec98
```

### External access still working (shouldn't be!)

```bash
# Double-check iptables
sudo iptables -L DOCKER-USER -n -v | grep 34141

# Re-add the rule if missing
sudo iptables -I DOCKER-USER -p tcp --dport 34141 -j DROP
sudo netfilter-persistent save
```

### Firewall rules lost after reboot

```bash
# Restore saved rules
sudo netfilter-persistent reload

# Or manually re-apply
sudo iptables -I DOCKER-USER -p tcp --dport 34141 -j DROP
sudo netfilter-persistent save
```

---

## Why UFW Didn't Work

Docker manipulates iptables directly and bypasses UFW rules. To block Docker-exposed ports, you must:

1. Use the `DOCKER-USER` chain in iptables
2. Docker checks this chain before allowing connections
3. Our rule: `iptables -I DOCKER-USER -p tcp --dport 34141 -j DROP`

This is the **correct and only way** to block Docker ports.

---

## Security Best Practices

### For Public Testnet
- Keep RPC blocked by default
- Only open when needed for specific users
- Use rate limiting (nginx proxy)
- Monitor access logs

### For Private Development
- Keep RPC blocked (current setup) ✅
- Only accessible from server itself
- Team uses VPN or SSH tunneling
- No external access needed

---

## SSH Tunnel (Alternative Access Method)

If you need RPC access from your local machine without opening it publicly:

```bash
# On your local machine:
ssh -L 8545:127.0.0.1:34141 ubuntu@64.34.84.209

# Then access RPC locally at:
# http://localhost:8545
```

This creates a secure tunnel through SSH!

---

## Monitoring

### Check who was using it (before block)

```bash
# View recent connections to port 34141
sudo netstat -tn | grep :34141

# Check iptables packet counts
sudo iptables -L DOCKER-USER -n -v
```

### Watch for blocked attempts

```bash
# Real-time monitoring of dropped packets
sudo iptables -L DOCKER-USER -n -v --line-numbers
watch -n 1 'sudo iptables -L DOCKER-USER -n -v | grep 34141'
```

---

## Summary

**Current State:**
- 🔒 RPC blocked from internet
- ✅ Localhost access works
- ✅ Faucet still public
- ✅ Rules persist after reboot
- ✅ External users can no longer access your network

**To revert:** See "Unblock RPC" section above.

**Last updated:** November 30, 2025


