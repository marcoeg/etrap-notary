# ETRAP Smart Contract API Documentation

This document provides a comprehensive reference for all methods available in the ETRAP NEAR smart contract.

## Table of Contents

- [Contract Initialization](#contract-initialization)
- [Core Methods](#core-methods)
  - [Minting](#minting)
  - [Verification](#verification)
  - [Merkle Tree Operations](#merkle-tree-operations)
- [Query Methods](#query-methods)
  - [Batch Queries](#batch-queries)
  - [Statistics](#statistics)
- [NFT Standard Methods](#nft-standard-methods)
  - [Core NFT Functions](#core-nft-functions)
  - [NFT Enumeration](#nft-enumeration)
  - [NFT Metadata](#nft-metadata)
- [Admin Methods](#admin-methods)
- [Data Structures](#data-structures)

## Contract Initialization

### `new`

Initializes a new ETRAP contract instance for an organization.

**Type**: `#[init]` method

**Parameters**:
- `organization_id`: `AccountId` - The NEAR account ID of the organization
- `organization_name`: `String` - Human-readable name of the organization
- `etrap_treasury`: `AccountId` - NEAR account to receive ETRAP fees
- `etrap_fee_amount`: `f64` - Fee amount in NEAR (e.g., 0.01 for 0.01 NEAR)

**Example**:
```bash
near call $CONTRACT_ID new '{
  "organization_id": "myorg.testnet",
  "organization_name": "My Organization",
  "etrap_treasury": "etrap-treasury.testnet",
  "etrap_fee_amount": 0.01
}' --accountId $CONTRACT_ID
```

## Core Methods

### Minting

#### `mint_batch`

Creates a new NFT representing a batch of database transactions.

**Type**: `#[payable]` method (requires attached deposit for storage)

**Parameters**:
- `token_id`: `TokenId` - Unique identifier for the NFT (typically batch ID)
- `receiver_id`: `AccountId` - Account that will own the NFT
- `token_metadata`: `TokenMetadata` - NFT metadata (see [TokenMetadata](#tokenmetadata) structure)
- `batch_summary`: `BatchSummary` - Summary of the transaction batch (see [BatchSummary](#batchsummary) structure)

**Returns**: `Token` - The minted NFT token

**Required Deposit**: Storage cost (estimated ~4KB) + ETRAP fee (configured during initialization)

**Example**:
```bash
near call $CONTRACT_ID mint_batch '{
  "token_id": "batch_20240115_001",
  "receiver_id": "myorg.testnet",
  "token_metadata": {
    "title": "Batch 2024-01-15 #001",
    "description": "Transaction batch from production database",
    "media": null,
    "media_hash": null,
    "copies": 1,
    "issued_at": "1705344000000",
    "expires_at": null,
    "starts_at": null,
    "updated_at": null,
    "extra": null,
    "reference": "https://s3.amazonaws.com/mybucket/batch_20240115_001/metadata.json",
    "reference_hash": null
  },
  "batch_summary": {
    "database_name": "production_db",
    "table_names": ["users", "orders", "products"],
    "timestamp": 1705344000000,
    "tx_count": 1500,
    "merkle_root": "a1b2c3d4e5f6...",
    "s3_bucket": "mybucket",
    "s3_key": "batch_20240115_001/",
    "size_bytes": 524288,
    "operation_counts": {
      "inserts": 500,
      "updates": 800,
      "deletes": 200
    }
  }
}' --accountId myorg.testnet --deposit 0.01
```

### Verification

#### `verify_document_in_batch`

Verifies that a specific document/transaction belongs to a batch using Merkle proof.

**Type**: View method (free, no gas required)

**Parameters**:
- `token_id`: `TokenId` - The batch NFT token ID
- `document_hash`: `String` - Hash of the document to verify
- `merkle_proof`: `Vec<String>` - Array of hashes forming the Merkle proof path
- `leaf_index`: `u32` - Position of the document in the Merkle tree (0-based)

**Returns**: `bool` - `true` if verification succeeds, `false` otherwise

**Example**:
```bash
near view $CONTRACT_ID verify_document_in_batch '{
  "token_id": "batch_20240115_001",
  "document_hash": "7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730",
  "merkle_proof": [
    "c3e0e8a5e8a5c3e0e8a5e8a5c3e0e8a5e8a5c3e0e8a5e8a5c3e0e8a5e8a5",
    "d4f1f9b6f9b6d4f1f9b6f9b6d4f1f9b6f9b6d4f1f9b6f9b6d4f1f9b6f9b6"
  ],
  "leaf_index": 42
}'
```

### Merkle Tree Operations

#### `compute_merkle_root`

Computes the Merkle root for a set of transaction hashes.

**Type**: View method (free, no gas required)

**Parameters**:
- `transaction_hashes`: `Vec<String>` - Array of transaction hashes
- `use_sha256`: `bool` - Whether to use SHA256 hashing (true) or simple concatenation (false)

**Returns**: `String` - The computed Merkle root

**Example**:
```bash
near view $CONTRACT_ID compute_merkle_root '{
  "transaction_hashes": [
    "hash1",
    "hash2",
    "hash3",
    "hash4"
  ],
  "use_sha256": true
}'
```

#### `generate_merkle_proof`

Generates a Merkle proof for a specific transaction in a set.

**Type**: View method (free, no gas required)

**Parameters**:
- `transactions`: `Vec<String>` - Array of all transaction hashes
- `tx_index`: `u32` - Index of the transaction to generate proof for
- `use_sha256`: `bool` - Whether to use SHA256 hashing

**Returns**: `Vec<String>` - Array of hashes forming the Merkle proof

**Example**:
```bash
near view $CONTRACT_ID generate_merkle_proof '{
  "transactions": ["tx1", "tx2", "tx3", "tx4"],
  "tx_index": 1,
  "use_sha256": true
}'
```

## Query Methods

### Batch Queries

#### `get_recent_batches`

Retrieves the most recently minted batches.

**Type**: View method (free, no gas required)

**Parameters**:
- `limit`: `Option<u64>` - Maximum number of batches to return (default: 20, max: 100)

**Returns**: `Vec<BatchInfo>` - Array of batch information

**Example**:
```bash
near view $CONTRACT_ID get_recent_batches '{"limit": 10}'
```

#### `get_batches_by_database`

Retrieves batches for a specific database with pagination.

**Type**: View method (free, no gas required)

**Parameters**:
- `database`: `String` - Name of the database
- `from_index`: `Option<u64>` - Starting index for pagination (default: 0)
- `limit`: `Option<u64>` - Maximum results per page (default: 50, max: 100)

**Returns**: `BatchSearchResult` containing:
- `batches`: `Vec<BatchInfo>` - Array of batch information
- `total_count`: `u64` - Total number of batches for this database
- `has_more`: `bool` - Whether more results are available

**Example**:
```bash
near view $CONTRACT_ID get_batches_by_database '{
  "database": "production_db",
  "from_index": 0,
  "limit": 25
}'
```

#### `get_batches_by_time_range`

Retrieves batches within a specific time range.

**Type**: View method (free, no gas required)

**Parameters**:
- `start_timestamp`: `u64` - Start timestamp in milliseconds
- `end_timestamp`: `u64` - End timestamp in milliseconds
- `database`: `Option<String>` - Optional database filter
- `limit`: `Option<u64>` - Maximum results (default: 100, max: 1000)

**Returns**: `Vec<BatchInfo>` - Array of batch information

**Example**:
```bash
near view $CONTRACT_ID get_batches_by_time_range '{
  "start_timestamp": 1705276800000,
  "end_timestamp": 1705363200000,
  "database": "production_db",
  "limit": 50
}'
```

#### `get_batches_by_table`

Retrieves batches that include a specific table.

**Type**: View method (free, no gas required)

**Parameters**:
- `table_name`: `String` - Name of the table
- `limit`: `Option<u64>` - Maximum results (default: 50, max: 100)

**Returns**: `Vec<BatchInfo>` - Array of batch information

**Example**:
```bash
near view $CONTRACT_ID get_batches_by_table '{
  "table_name": "users",
  "limit": 20
}'
```

#### `get_batch_summary`

Retrieves the summary for a specific batch.

**Type**: View method (free, no gas required)

**Parameters**:
- `token_id`: `TokenId` - The batch NFT token ID

**Returns**: `Option<BatchSummary>` - Batch summary if found, null otherwise

**Example**:
```bash
near view $CONTRACT_ID get_batch_summary '{"token_id": "batch_20240115_001"}'
```

### Statistics

#### `get_batch_stats`

Retrieves statistics for a specific batch or global statistics.

**Type**: View method (free, no gas required)

**Parameters**:
- `token_id`: `Option<TokenId>` - Specific batch ID or null for global stats

**Returns**: JSON object with statistics

**Example (specific batch)**:
```bash
near view $CONTRACT_ID get_batch_stats '{"token_id": "batch_20240115_001"}'
# Returns:
# {
#   "token_id": "batch_20240115_001",
#   "database": "production_db",
#   "transaction_count": 1500,
#   "merkle_root": "a1b2c3d4...",
#   "timestamp": 1705344000000,
#   "operations": {
#     "inserts": 500,
#     "updates": 800,
#     "deletes": 200
#   }
# }
```

**Example (global stats)**:
```bash
near view $CONTRACT_ID get_batch_stats '{}'
# Returns:
# {
#   "total_batches": 1234,
#   "total_databases": 5,
#   "databases": ["production_db", "staging_db", "analytics_db", ...]
# }
```

#### `get_databases`

Retrieves a list of all databases that have batches.

**Type**: View method (free, no gas required)

**Returns**: `Vec<String>` - Array of database names

**Example**:
```bash
near view $CONTRACT_ID get_databases
```

## NFT Standard Methods

### Core NFT Functions

#### `nft_transfer`

Transfers an NFT to another account.

**Type**: `#[payable]` method (requires 1 yoctoNEAR for security)

**Parameters**:
- `receiver_id`: `AccountId` - Account to receive the NFT
- `token_id`: `TokenId` - NFT to transfer
- `approval_id`: `Option<u64>` - Optional approval ID for approved transfers
- `memo`: `Option<String>` - Optional memo for the transfer

**Example**:
```bash
near call $CONTRACT_ID nft_transfer '{
  "receiver_id": "alice.testnet",
  "token_id": "batch_20240115_001",
  "memo": "Transfer for audit purposes"
}' --accountId bob.testnet --depositYocto 1
```

#### `nft_transfer_call`

Transfers an NFT and calls a method on the receiver contract.

**Type**: `#[payable]` method

**Parameters**:
- `receiver_id`: `AccountId` - Contract to receive the NFT
- `token_id`: `TokenId` - NFT to transfer
- `approval_id`: `Option<u64>` - Optional approval ID
- `memo`: `Option<String>` - Optional memo
- `msg`: `String` - Message to pass to receiver contract

**Returns**: `PromiseOrValue<bool>` - Whether the receiver kept the token

#### `nft_token`

Retrieves information about a specific NFT.

**Type**: View method (free, no gas required)

**Parameters**:
- `token_id`: `TokenId` - The NFT token ID

**Returns**: `Option<Token>` - Token information if found

**Example**:
```bash
near view $CONTRACT_ID nft_token '{"token_id": "batch_20240115_001"}'
```

### NFT Enumeration

#### `nft_total_supply`

Gets the total number of NFTs minted.

**Type**: View method (free, no gas required)

**Returns**: `U128` - Total supply as a string

**Example**:
```bash
near view $CONTRACT_ID nft_total_supply
```

#### `nft_tokens`

Lists NFTs with pagination.

**Type**: View method (free, no gas required)

**Parameters**:
- `from_index`: `Option<U128>` - Starting index (default: 0)
- `limit`: `Option<u64>` - Maximum results (default: unlimited)

**Returns**: `Vec<Token>` - Array of tokens

**Example**:
```bash
near view $CONTRACT_ID nft_tokens '{"from_index": "0", "limit": 10}'
```

#### `nft_supply_for_owner`

Gets the number of NFTs owned by an account.

**Type**: View method (free, no gas required)

**Parameters**:
- `account_id`: `AccountId` - The account to check

**Returns**: `U128` - Number of tokens owned

**Example**:
```bash
near view $CONTRACT_ID nft_supply_for_owner '{"account_id": "alice.testnet"}'
```

#### `nft_tokens_for_owner`

Lists NFTs owned by an account.

**Type**: View method (free, no gas required)

**Parameters**:
- `account_id`: `AccountId` - The account to query
- `from_index`: `Option<U128>` - Starting index
- `limit`: `Option<u64>` - Maximum results

**Returns**: `Vec<Token>` - Array of tokens

**Example**:
```bash
near view $CONTRACT_ID nft_tokens_for_owner '{
  "account_id": "alice.testnet",
  "from_index": "0",
  "limit": 20
}'
```

### NFT Metadata

#### `nft_metadata`

Retrieves the contract's NFT metadata.

**Type**: View method (free, no gas required)

**Returns**: `NFTContractMetadata` - Contract metadata

**Example**:
```bash
near view $CONTRACT_ID nft_metadata
```

## Admin Methods

### `set_paused`

Pauses or unpauses the contract (prevents new mints when paused).

**Type**: `#[private]` method (only callable by contract account)

**Parameters**:
- `paused`: `bool` - Whether to pause the contract

**Example**:
```bash
near call $CONTRACT_ID set_paused '{"paused": true}' --accountId $CONTRACT_ID
```

### `update_treasury`

Updates the ETRAP treasury account that receives fees.

**Type**: `#[private]` method (only callable by contract account)

**Parameters**:
- `new_treasury`: `AccountId` - New treasury account

**Example**:
```bash
near call $CONTRACT_ID update_treasury '{"new_treasury": "new-treasury.testnet"}' --accountId $CONTRACT_ID
```

### `get_settings`

Retrieves the current contract settings.

**Type**: View method (free, no gas required)

**Returns**: JSON object with settings:
- `etrap_treasury`: Current treasury account
- `fee_amount`: Fee amount in yoctoNEAR
- `paused`: Whether contract is paused

**Example**:
```bash
near view $CONTRACT_ID get_settings
```

## Data Structures

### BatchSummary

```rust
{
  "database_name": String,      // Name of the database
  "table_names": Vec<String>,   // List of affected tables
  "timestamp": u64,             // Unix timestamp in milliseconds
  "tx_count": u32,              // Total number of transactions
  "merkle_root": String,        // Merkle root of all transactions
  "s3_bucket": String,          // S3 bucket containing details
  "s3_key": String,             // S3 key prefix for batch data
  "size_bytes": u64,            // Total size of batch data
  "operation_counts": {         // Breakdown by operation type
    "inserts": u32,
    "updates": u32,
    "deletes": u32
  }
}
```

### TokenMetadata

Standard NEP-177 token metadata:

```rust
{
  "title": Option<String>,           // Title of the NFT
  "description": Option<String>,     // Description
  "media": Option<String>,           // URL to associated media
  "media_hash": Option<String>,      // Base64-encoded sha256 hash of media
  "copies": Option<u64>,             // Number of copies (always 1 for ETRAP)
  "issued_at": Option<String>,       // ISO 8601 datetime
  "expires_at": Option<String>,      // ISO 8601 datetime
  "starts_at": Option<String>,       // ISO 8601 datetime
  "updated_at": Option<String>,      // ISO 8601 datetime
  "extra": Option<String>,           // Additional metadata
  "reference": Option<String>,       // URL to off-chain metadata
  "reference_hash": Option<String>   // Base64-encoded sha256 hash
}
```

### BatchInfo

```rust
{
  "token_id": TokenId,          // The NFT token ID
  "owner_id": AccountId,        // Current owner
  "metadata": TokenMetadata,    // NFT metadata
  "batch_summary": BatchSummary // Batch details
}
```

### BatchSearchResult

```rust
{
  "batches": Vec<BatchInfo>,    // Array of batch information
  "total_count": u64,           // Total matching batches
  "has_more": bool              // Whether more pages exist
}
```

## Gas and Storage Costs

- **Minting**: Storage deposit (estimated ~4KB) + ETRAP fee (configured during initialization)
- **View methods**: Free (no gas required)
- **Transfers**: 1 yoctoNEAR security deposit
- **Admin methods**: Standard transaction fees

## Error Handling

Common errors:
- `"Already initialized"` - Contract is already initialized
- `"Contract is paused"` - Minting is disabled
- `"Token already exists"` - Token ID is already used
- `"Insufficient deposit for storage"` - Not enough NEAR attached
- `"Token not found"` - Invalid token ID
- `"Batch not found"` - Invalid batch ID

## Usage Examples

### Repository Scripts Integration

The notary repository includes several helpful scripts for development and testing:

**Build and deploy workflow:**
```bash
# 1. Build the contract
./build.sh

# 2. Deploy (replace myorg.testnet with your account)
near deploy myorg.testnet out/etrap_contract.wasm

# 3. Initialize (replace with your details)
near call myorg.testnet new '{
  "organization_id": "myorg.testnet",
  "organization_name": "My Organization",
  "etrap_treasury": "etrap-treasury.testnet",
  "etrap_fee_amount": 0.01
}' --accountId myorg.testnet

# 4. Check settings
./scripts/check_settings.sh
```

**Testing and monitoring:**
```bash
# Monitor gas usage
./scripts/check_gas_usage.sh [transaction_id]

# Test SHA256 verification
./scripts/test_sha256.sh

# View fee calculation info
./scripts/test_fee_calculation.sh
```

**Example commands (from etrap_deploy.sh):**
```bash
# View recent batches
near view $CONTRACT_ID get_recent_batches '{"limit": 10}'

# Search by database
near view $CONTRACT_ID get_batches_by_database '{"database": "production_db"}'

# Search by time range
near view $CONTRACT_ID get_batches_by_time_range '{
  "start_timestamp": 1749561600000,
  "end_timestamp": 1749604800000
}'
```

### Complete Minting Flow

```bash
# 1. Prepare batch data and compute merkle root
MERKLE_ROOT=$(near view $CONTRACT_ID compute_merkle_root '{
  "transaction_hashes": ["tx1", "tx2", "tx3"],
  "use_sha256": true
}')

# 2. Mint the batch NFT
near call $CONTRACT_ID mint_batch '{
  "token_id": "batch_20240115_001",
  "receiver_id": "myorg.testnet",
  "token_metadata": {
    "title": "Database Batch 2024-01-15",
    "issued_at": "1705344000000"
  },
  "batch_summary": {
    "database_name": "production",
    "table_names": ["users", "orders"],
    "timestamp": 1705344000000,
    "tx_count": 3,
    "merkle_root": "'$MERKLE_ROOT'",
    "s3_bucket": "my-etrap-bucket",
    "s3_key": "batches/2024/01/15/001/",
    "size_bytes": 12345,
    "operation_counts": {
      "inserts": 1,
      "updates": 1,
      "deletes": 1
    }
  }
}' --accountId myorg.testnet --deposit 0.01

# 3. Verify a transaction in the batch
near view $CONTRACT_ID verify_document_in_batch '{
  "token_id": "batch_20240115_001",
  "document_hash": "tx2",
  "merkle_proof": ["tx1", "hash_of_tx3"],
  "leaf_index": 1
}'
```

### Querying Batches

```bash
# Get recent batches
near view $CONTRACT_ID get_recent_batches '{"limit": 5}'

# Search by database
near view $CONTRACT_ID get_batches_by_database '{
  "database": "production",
  "from_index": 0,
  "limit": 10
}'

# Search by time range (last 24 hours)
YESTERDAY=$(($(date +%s) * 1000 - 86400000))
NOW=$(($(date +%s) * 1000))
near view $CONTRACT_ID get_batches_by_time_range '{
  "start_timestamp": '$YESTERDAY',
  "end_timestamp": '$NOW',
  "limit": 100
}'
```