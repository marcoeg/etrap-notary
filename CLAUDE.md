# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the ETRAP (Enterprise Transaction Receipt Anchoring Platform) NEAR smart contract. It's a Rust-based NEAR Protocol smart contract that manages NFTs representing batches of database transactions. Each NFT serves as a blockchain-based proof of integrity certificate.

## Common Development Commands

### Building
```bash
./build.sh
```
Or manually:
```bash
rustup target add wasm32-unknown-unknown
RUSTFLAGS='-C link-arg=-s' cargo build --target wasm32-unknown-unknown --release
cp target/wasm32-unknown-unknown/release/*.wasm out/etrap_contract.wasm
```

### Testing
```bash
cargo test
```

### Code Quality
```bash
cargo fmt      # Format code
cargo clippy   # Lint and check for issues
```

### Deployment
```bash
# Set environment
export NEAR_ENV=testnet

# Deploy contract
near deploy --accountId <account>.testnet --wasmFile out/etrap_contract.wasm

# Initialize
near call <account>.testnet new '{
  "organization_id": "<account>.testnet",
  "organization_name": "Organization Name",
  "etrap_treasury": "etrap-treasury.testnet"
}' --accountId <account>.testnet
```

## Architecture

The contract (src/lib.rs) implements:

1. **NFT Standard (NEP-177)**: Full compliance with NEAR's NFT standard
2. **Per-Organization Design**: Each organization gets their own contract instance
3. **Efficient Storage**: Minimal on-chain data with S3 references for details
4. **Multiple Indices**: Fast searches by database, time, table, and recent batches
5. **Merkle Tree Verification**: Each NFT contains merkle root for transaction verification

### Key Data Structures
- `BatchSummary`: On-chain summary with merkle root and metadata
- `TokenMetadata`: NFT metadata including S3 references
- Multiple storage indices using NEAR's efficient storage patterns

### Core Methods
- `mint_batch`: Creates NFT for transaction batch (requires gas)
- `get_recent_batches`, `get_batches_by_database`, etc.: View methods (free)
- `verify_document_in_batch`: Merkle proof verification
- Admin controls: `set_paused`, `update_treasury`

## Important Context

1. The contract is designed for multi-tenant use - each organization deploys their own instance
2. Actual transaction data is stored in S3; only merkle roots are on-chain
3. The contract maintains multiple indices for efficient queries even with millions of NFTs
4. Fee collection is handled with a configurable treasury address (25% fee)
5. The etrap_deploy.sh script contains extensive examples of contract interactions