# ETRAP NEAR Smart Contract

A NEAR Protocol smart contract for the Enterprise Transaction Receipt Anchoring Platform (ETRAP). This contract manages NFTs that represent batches of database transactions, providing blockchain-based proof of integrity.

## Features

- **NFT-based batch certificates**: Each NFT represents a batch of database transactions
- **Merkle tree verification**: Verify individual transactions belong to a batch
- **Efficient indexing**: Multiple indices for fast searches by database, time, table
- **Per-organization deployment**: Each organization gets their own contract instance
- **Minimal on-chain storage**: Detailed data stored in S3, only merkle roots on-chain

## Contract Overview

### 1. NFT Standard Compliance
- Fully implements **NEP-177** (NEAR's NFT standard).
- Each NFT represents a batch of database transactions.
- Includes standard NFT **transfer**, **enumeration**, and **metadata** functionality.

### 2. Per-Organization Design
- Contract is initialized with organization-specific metadata.
- Custom **name** and **symbol** for each organization.
- **Isolated data storage** per organization.

### 3. Batch Processing Architecture
- Each NFT contains a **Merkle root** for verification.
- **Minimal on-chain storage** (only essential data).
- References to **S3** for detailed transaction data.
- **Batch summaries** with operation counts and metadata.

### 4. Efficient Search Indices
- **By Database**: Quick lookup of all batches for a specific database.
- **By Month**: Time-based grouping for historical queries.
- **By Timestamp**: TreeMap for efficient range queries.
- **By Table**: Find batches affecting specific tables.
- **Recent Cache**: Last 100 batches for quick access.

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (1.72.0)
- [NEAR CLI](https://docs.near.org/tools/near-cli) 
- Node.js 18+ (for NEAR CLI)
- A NEAR testnet account

## Quick Start

1. **Clone and install dependencies**:
```bash
git clone <repository>
cd notary
cargo fetch
```

2. **Build the contract**:
```bash
chmod +x build.sh
./build.sh
```

3. **Deploy to testnet**:
```bash
# Set up environment
export NEAR_ENV=testnet

# Deploy (replace with your account)
near deploy yourorg.testnet out/etrap_contract.wasm

# Initialize
near call yourorg.testnet new '{
  "organization_id": "yourorg.testnet",
  "organization_name": "Your Organization",
  "etrap_treasury": "etrap-treasury.testnet",
  "etrap_fee_amount": 0.05
}' --accountId yourorg.testnet
```

## Contract Methods

### Write Methods (require gas)

- `mint_batch` - Create a new NFT for a transaction batch
- `set_paused` - Pause/unpause contract (owner only)
- `update_treasury` - Update fee collection address (owner only)

### View Methods (free)

- `get_recent_batches` - Get most recent batches
- `get_batches_by_database` - Search by database name
- `get_batches_by_time_range` - Search by timestamp range
- `get_batches_by_table` - Search by table name
- `get_batch_stats` - Get statistics

### Verification
- `verify_document_in_batch`**: Verifies a transaction belongs to a batch using Merkle proofs.
- `verify_document_in_batch` - Verify transaction with merkle proof


### 6. Data Structures
The contract uses optimized data structures matching the design specifications:
- **Batch summaries** stored on-chain with Merkle roots.
- **S3 references** for detailed data.
- **Operation counts** and **metadata** for analytics.

### 7. Admin Controls
- **Pausable contract** for emergency situations.
- **Treasury address management** for fee collection.
- **Settings** stored in lazy option for efficiency.

### 8. Event System
Emits structured events for off-chain indexers containing:
- Batch metadata.
- S3 location references.
- Database and table information.
- Merkle roots for verification.

## Key Design Decisions
- **Storage Optimization**: Uses NEAR's efficient storage patterns with proper key prefixing.
- **Gas Efficiency**: View methods are free; only minting requires gas.
- **Scalability**: Indices allow efficient queries even with millions of NFTs.
- **Security**: Private admin functions, validation checks, pausable design.


## Architecture

```
On-Chain (NEAR)         Off-Chain (S3)
│                       │
├─ NFT Metadata         ├─ Transaction Details
├─ Merkle Root          ├─ Full Merkle Tree
├─ Batch Summary        ├─ Individual Proofs
└─ S3 Reference         └─ Search Indices
```
## License

MIT

Copyright (c) 2025 Graziano Labs Corp. All rights reserved.


