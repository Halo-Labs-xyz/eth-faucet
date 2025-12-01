package chain

import (
	"context"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum"
)

// ERC20 ABI for transfer and decimals functions
const erc20ABI = `[
	{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","type":"function"},
	{"constant":true,"inputs":[],"name":"decimals","type":"function","outputs":[{"name":"","type":"uint8"}]}
]`

type ERC20Transferer interface {
	TransferERC20(ctx context.Context, tokenAddress, to string, amount *big.Int) (common.Hash, error)
}

// GetTokenDecimals fetches the decimals value from an ERC20 token contract
func GetTokenDecimals(ctx context.Context, provider string, tokenAddress string) (uint8, error) {
	client, err := ethclient.Dial(provider)
	if err != nil {
		return 18, err // Default to 18 if we can't connect
	}
	defer client.Close()

	parsedABI, err := abi.JSON(strings.NewReader(erc20ABI))
	if err != nil {
		return 18, err
	}

	tokenAddr := common.HexToAddress(tokenAddress)
	callData, err := parsedABI.Pack("decimals")
	if err != nil {
		return 18, err
	}

	msg := ethereum.CallMsg{
		To:   &tokenAddr,
		Data: callData,
	}
	result, err := client.CallContract(ctx, msg, nil)
	if err != nil {
		return 18, err // Default to 18 if call fails
	}

	var decimals uint8
	err = parsedABI.UnpackIntoInterface(&decimals, "decimals", result)
	if err != nil {
		return 18, err
	}

	return decimals, nil
}

// TransferERC20 sends ERC20 tokens to the specified address using standard ERC20 transfer().
// Note: On Halo Network, tokens can support confidential transfers via precompiles,
// but this function only performs standard public transfers. Users can move tokens to
// private storage using the frontend interface which calls contract methods that
// interface with Halo's custom precompiles.
func (b *TxBuild) TransferERC20(ctx context.Context, tokenAddress, to string, amount *big.Int) (common.Hash, error) {
	// Parse the ERC20 ABI
	parsedABI, err := abi.JSON(strings.NewReader(erc20ABI))
	if err != nil {
		return common.Hash{}, err
	}

	// Encode the transfer function call
	toAddress := common.HexToAddress(to)
	data, err := parsedABI.Pack("transfer", toAddress, amount)
	if err != nil {
		return common.Hash{}, err
	}

	// Get nonce
	nonce := b.getAndIncrementNonce()

	// Estimate gas (ERC20 transfer typically uses ~50-65k gas)
	gasLimit := uint64(100000)

	tokenAddr := common.HexToAddress(tokenAddress)
	var unsignedTx *types.Transaction

	if b.supportsEIP1559 {
		unsignedTx, err = b.buildEIP1559TxWithData(ctx, &tokenAddr, big.NewInt(0), data, gasLimit, nonce)
	} else {
		unsignedTx, err = b.buildLegacyTxWithData(ctx, &tokenAddr, big.NewInt(0), data, gasLimit, nonce)
	}

	if err != nil {
		return common.Hash{}, err
	}

	signedTx, err := types.SignTx(unsignedTx, b.signer, b.privateKey)
	if err != nil {
		return common.Hash{}, err
	}

	if err = b.client.SendTransaction(ctx, signedTx); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "nonce") {
			b.refreshNonce(context.Background())
		}
		return common.Hash{}, err
	}

	return signedTx.Hash(), nil
}

func (b *TxBuild) buildEIP1559TxWithData(ctx context.Context, to *common.Address, value *big.Int, data []byte, gasLimit uint64, nonce uint64) (*types.Transaction, error) {
	header, err := b.client.HeaderByNumber(ctx, nil)
	if err != nil {
		return nil, err
	}

	gasTipCap, err := b.client.SuggestGasTipCap(ctx)
	if err != nil {
		return nil, err
	}

	// gasFeeCap = baseFee * 2 + gasTipCap
	gasFeeCap := new(big.Int).Mul(header.BaseFee, big.NewInt(2))
	gasFeeCap = new(big.Int).Add(gasFeeCap, gasTipCap)

	return types.NewTx(&types.DynamicFeeTx{
		ChainID:   b.signer.ChainID(),
		Nonce:     nonce,
		GasTipCap: gasTipCap,
		GasFeeCap: gasFeeCap,
		Gas:       gasLimit,
		To:        to,
		Value:     value,
		Data:      data,
	}), nil
}

func (b *TxBuild) buildLegacyTxWithData(ctx context.Context, to *common.Address, value *big.Int, data []byte, gasLimit uint64, nonce uint64) (*types.Transaction, error) {
	gasPrice, err := b.client.SuggestGasPrice(ctx)
	if err != nil {
		return nil, err
	}

	return types.NewTx(&types.LegacyTx{
		Nonce:    nonce,
		GasPrice: gasPrice,
		Gas:      gasLimit,
		To:       to,
		Value:    value,
		Data:     data,
	}), nil
}
