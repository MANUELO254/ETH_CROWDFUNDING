-include .env

build:; forge build
deploy-sepolia:
	@echo "Deploying to Sepolia..."
	forge script script/DeployFundMe.s.sol:DeployFundMe --broadcast --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $ETHERSCAN_API_kEY -vvvv