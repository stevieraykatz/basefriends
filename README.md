![Screenshot 2024-09-03 at 3 06 04 PM](https://github.com/user-attachments/assets/1d8087ea-46bf-477f-ad6e-af211912ba58)

## Basefriends

**Basefriends allow a Basename holder to establish an on-chain identity graph**

*Follow your friends*

*Get followed by your friends*

*See who you follow and who follows you*

## Deploymenets

*Testnet:* https://sepolia.basescan.org/address/0x128AA5d8DaD4148a8eB1F5aeBdA0e0a62510b87e

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
cp .env.template .env
// populate your PRIVATE_KEY
$ forge script script/Deploy.s.sol --rpc-url <your_rpc_url>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
