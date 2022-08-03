# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

NAME := "Dokigotchi"
SYMBOL := "DOKI"
URI := "https://dokigotchi.com/api/meta?id="
PRICE := 100000000000000000
MERKLE := $(shell node scripts/genMerkleRoot.js)
WL_START_UTC := $(shell date -ju -f "%Y-%m-%d %H:%M" "2022-08-08 13:00" +'%s')
PUBLIC_START_UTC := $(shell date -ju -f "%Y-%m-%d %H:%M" "2022-08-10 13:00" +'%s')
ABI_ENCODE := $(shell cast abi-encode "constructor(string memory,string memory,string memory,uint256,bytes32,uint256,uint256,address,address,address)" $(NAME) $(SYMBOL) $(URI) $(PRICE) $(MERKLE) $(WL_START_UTC) $(PUBLIC_START_UTC) $(OWNER) $(ARTISTS) $(DEVS) | tail -c +3)
COMPILER := "0.8.14+commit.80d49f37"

gas:
	forge test --gas-report
	
snapshot:
	forge snapshot

coverage:
	forge coverage --report lcov

deploy: gas
	forge create Dokigotchi --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) --constructor-args $(NAME) $(SYMBOL) $(URI) $(PRICE) $(MERKLE) $(WL_START_UTC) $(PUBLIC_START_UTC) $(OWNER) $(ARTISTS) $(DEVS) --verify --optimize

verify:
	forge verify-contract --chain-id 1 --constructor-args $(ABI_ENCODE) --compiler-version $(COMPILER) $(CONTRACT) src/Dokigotchi.sol:Dokigotchi $(ETHERSCAN_KEY) --watch

mint:
	cast send --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) --value=0.1ether $(CONTRACT) "publicMint(uint256)" 1

honorary:
	cast send --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) $(CONTRACT) "honorariesMint(address)" $(OWNER)

wl:
	cast send --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) --value=0.1ether $(CONTRACT) "whitelistMint(bytes32[])" "[0x0000000000000000000000009c71847df07bb1dd889d03705c5e7f06687dbf83,0xd224f55fbcf5d7b5f11d883d493832389c6aeb1dee7dc063087261dd95568038,0x394208b44ab484d030ab1e4bd033ccf0b84a70970b662e705f547eadeb098369,0xcf32da9d78f573128119db055a392e5454cd8424aaffe06d7632b6a6afd35406,0x671c4302606bf7fac5e838d6d907d1d2086906e1457aca32f3ea5ad37b35f605,0x166eca24b19169ce1db43059bbd521ad60faf2ee5046c94cc603dedf578e5e34]"

ownerOf:
	cast call --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) $(CONTRACT) "ownerOf(uint256)" 0

delayPublicStart:
	cast call --rpc-url=$(RPC_URL) --private-key=$(PRIVATE_KEY) $(CONTRACT) "setPublicStartTime(uint256)" "$(shell date +%s)"
