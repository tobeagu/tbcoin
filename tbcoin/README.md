# tbcoin

A simple fungible token smart contract implemented in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview) and managed with [Clarinet](https://docs.hiro.so/clarinet).

> **Note**: This project is for learning and local development. It has not been audited and should not be used as-is in production.

## Project layout

This Clarinet project was created with `clarinet new tbcoin` and has the following structure:

- `Clarinet.toml` – Clarinet project configuration
- `contracts/` – Clarity smart contracts
  - `tbcoin.clar` – tbcoin fungible token contract
- `tests/` – TypeScript tests (Clarinet JS SDK / Vitest)
- `settings/` – Network configuration files (Devnet, Testnet, Mainnet)
- `tsconfig.json`, `vitest.config.ts`, `package.json` – TypeScript & test tooling

## tbcoin contract

`contracts/tbcoin.clar` implements a minimal fungible token suitable for simulation and testnets.

### State

- `balances` (map)
  - Key: `{ account: principal }`
  - Value: `{ balance: uint }`
  - Tracks the tbcoin balance for each principal.
- `total-supply` (data-var, `uint`)
  - Total number of tbcoin tokens that have been minted.

### Errors

- `ERR_ZERO_AMOUNT` – `(err u1)` when attempting to mint or transfer a zero amount.
- `ERR_INSUFFICIENT_BALANCE` – `(err u2)` when a transfer would overdraft the sender.

### Public functions

#### `mint` – permissionless mint for testing

```clarity
(define-public (mint (recipient principal) (amount uint)) ...)
```

- Mints `amount` tbcoin to `recipient`.
- Fails with `ERR_ZERO_AMOUNT` if `amount` is `u0`.
- Updates `balances` and `total-supply`.
- Returns `(ok true)` on success.

> For production use, you would typically restrict minting to an admin or smart contract logic instead of allowing anyone to mint.

#### `transfer` – move tokens between accounts

```clarity
(define-public (transfer (amount uint) (sender principal) (recipient principal)) ...)
```

- Transfers `amount` tbcoin from `sender` to `recipient`.
- Fails with `ERR_ZERO_AMOUNT` if `amount` is `u0`.
- Fails with `ERR_INSUFFICIENT_BALANCE` if `sender` does not have at least `amount` tbcoin.
- On success, debits `sender`, credits `recipient`, and returns `(ok true)`.

> The function expects the caller to pass the correct `sender` principal. In a real-world token, you would normally enforce that `sender` equals `tx-sender`.

### Read-only functions

#### `get-balance`

```clarity
(define-read-only (get-balance (owner principal)) ...)
```

- Returns `(ok <balance>)` for `owner`.
- Returns `u0` for accounts with no prior balance.

#### `get-total-supply`

```clarity
(define-read-only (get-total-supply) ...)
```

- Returns `(ok <total-supply>)`.

## Development

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed and available on your `PATH`.
- Node.js (for running TypeScript tests) if you want to use the generated test setup.

### Running checks

From the Clarinet project directory:

```bash
cd tbcoin
clarinet check
```

This command:

- Parses and type-checks all contracts in `contracts/`.
- Reports any syntax or type errors.

### Testing (optional)

If you’d like to run the generated TypeScript tests:

```bash
cd tbcoin
npm install
npm test
```

## Example Clarinet console session

You can interact with the contract in a local REPL using the Clarinet console:

```bash
cd tbcoin
clarinet console
```

Inside the console, you can:

```clarity
;; Mint 100 tbcoin to a principal (replace with your devnet address)
(contract-call? .tbcoin mint 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA u100)

;; Check balance
(contract-call? .tbcoin get-balance 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)

;; Transfer 50 tbcoin to another principal
(contract-call? .tbcoin transfer u50 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA 'ST2C2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHB)
```

Adjust principals and amounts as needed for your local environment.
