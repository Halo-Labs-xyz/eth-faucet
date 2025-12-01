package chain

import (
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/shopspring/decimal"
)

func EtherToWei(amount float64) *big.Int {
	oneEther := decimal.NewFromFloat(1e18)
	result := decimal.NewFromFloat(amount).Mul(oneEther)
	wei, _ := new(big.Int).SetString(result.String(), 10)
	return wei
}

// TokenToWei converts a token amount to the smallest unit based on token decimals
// For example: TokenToWei(100, 6) for USDC (6 decimals) = 100 * 10^6
func TokenToWei(amount float64, decimals uint8) *big.Int {
	multiplier := decimal.NewFromInt(1)
	for i := uint8(0); i < decimals; i++ {
		multiplier = multiplier.Mul(decimal.NewFromInt(10))
	}
	result := decimal.NewFromFloat(amount).Mul(multiplier)
	wei, _ := new(big.Int).SetString(result.String(), 10)
	return wei
}

func Has0xPrefix(str string) bool {
	return len(str) >= 2 && str[0] == '0' && (str[1] == 'x' || str[1] == 'X')
}

func IsValidAddress(address string, checksummed bool) bool {
	if !common.IsHexAddress(address) {
		return false
	}
	return !checksummed || common.HexToAddress(address).Hex() == address
}
