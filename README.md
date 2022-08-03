# Dokigotchi

This repository contains the smart contracts for [Dokigotchi](https://dokigotchi.com).

## About
Dokigotchi is a virtual pet project.

Adopt your own Doki egg! Watch it hatch, then keep it happy to earn its trust and love. There are tons of cute and evil Dokis!

Take it for walks, feed them, pet them... you name it.
How you take care of your pet is up to you!

## Dependencies

#### Foundry
https://github.com/foundry-rs/foundry

#### Make
https://www.gnu.org/software/make/

#### Yarn (optional)
https://yarnpkg.com/

#### Slither (optional)
https://github.com/crytic/slither

## Quick start!

1. Copy the `.env.example` file to `.env` and fill in the details (INFURA_ID, ... , ETHERSCAN_KEY)
2. Update foundry and install dependencies 
  > `$ foundryup`
3. Install node dependencies
  > `$ yarn`
4. Run tests
  > `$ forge test`
  >
  > `$ forge coverage`
  >
  > `$ slither src/Dokigotchi.sol`
5. Edit the [whitelist](data/wl.json)
6. Configure [Makefile](Makefile) variables
7. Deploy!! (testnet is recommended)
  > `$ make deploy`

## Questions?
help (at) dokigotchi (dot) com

## License
[MIT License](LICENSE) - Copyright (c) 2022 [Dokigotchi](https://dokigotchi.com)