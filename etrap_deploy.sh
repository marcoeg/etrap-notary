#!/bin/bash

# ETRAP NEAR Smart Contract - CLI Commands for Testnet Deployment and Testing

#########################
# 1. SETUP & BUILD
#########################

# Install dependencies
npm install

# Set environment to testnet
export NEAR_ENV=testnet

# Create test accounts (you'll need to fund these with testnet NEAR)
# Option 1: Use NEAR CLI
near create-account etrap.testnet --useFaucet

# Option 2: Use wallet UI
# Visit: https://wallet.testnet.near.org to create accounts
# You'll need:
# - Organization account: etrap.testnet  
# - ETRAP treasury account: etrap-treasury.testnet

# Build the contract
chmod +x build.sh
./build.sh

# Or build manually
rustup target add wasm32-unknown-unknown
RUSTFLAGS='-C link-arg=-s' cargo build --target wasm32-unknown-unknown --release
cp target/wasm32-unknown-unknown/release/etrap_near_contract.wasm ./out/etrap_contract.wasm

#########################
# 2. DEPLOY CONTRACT
#########################

# Deploy the contract to the organization's account
near deploy etrap.testnet out/etrap_contract.wasm

# Initialize the contract
near call etrap.testnet new \
  '{"organization_id": "etrap.testnet", "organization_name": "etrap", "etrap_treasury": "etrap-treasury.testnet"}' \
  --accountId etrap.testnet

#########################
# 3. MINT NFT BATCHES
#########################

# Mint Batch 1: Financial Trading Transactions (Morning batch)
near call etrap.testnet mint_batch '{
  "token_id": "BATCH-2025-06-12-001",
  "receiver_id": "etrap.testnet",
  "token_metadata": {
    "title": "Financial Transactions Batch 2025-06-12-001",
    "description": "Integrity certificate for 10,000 trading transactions from 2025-06-12 morning session",
    "media": "https://etrap-assets.s3.amazonaws.com/merkle-visualizations/batch-2025-06-12-001.svg",
    "media_hash": "YmFzZTY0X2VuY29kZWRfaGFzaF8x",
    "copies": 1,
    "issued_at": "1749561600000",
    "expires_at": null,
    "starts_at": "1749561600000",
    "updated_at": null,
    "extra": "{\"merkle_root\":\"0x7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730\",\"leaf_count\":10000,\"hash_algorithm\":\"sha256\",\"batch_id\":\"BATCH-2025-06-12-001\",\"organization_id\":\"etrap.testnet\",\"database_name\":\"trading_db\",\"batch_summary\":{\"start_timestamp\":1749561600000,\"end_timestamp\":1749572400000,\"total_transactions\":10000,\"operations_summary\":{\"inserts\":8500,\"updates\":1300,\"deletes\":200}},\"s3_bucket\":\"etrap-etrap\",\"s3_prefix\":\"trading_db/BATCH-2025-06-12-001\",\"anchoring_data\":{\"block_height\":142857000,\"tx_hash\":\"4reLvkAWfqk5fsqio1KLudk3JrFuwTvnpwLn5JVbGGwG\",\"gas_used\":\"30000000000000\",\"etrap_fee\":\"0.00075\"}}",
    "reference": "https://etrap-etrap.s3.amazonaws.com/trading_db/BATCH-2025-06-12-001/batch-data.json",
    "reference_hash": "cmVmZXJlbmNlX2hhc2hfMQ=="
  },
  "batch_summary": {
    "database_name": "trading_db",
    "table_names": ["trades", "orders", "executions"],
    "timestamp": 1749561600000,
    "tx_count": 10000,
    "merkle_root": "0x7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730",
    "s3_bucket": "etrap-etrap",
    "s3_key": "trading_db/BATCH-2025-06-12-001/batch-data.json",
    "size_bytes": 5242880,
    "operation_counts": {
      "inserts": 8500,
      "updates": 1300,
      "deletes": 200
    }
  }
}' --accountId etrap.testnet --deposit 0.1

# Mint Batch 2: Customer Account Updates (Afternoon batch)
near call etrap.testnet mint_batch '{
  "token_id": "BATCH-2025-06-12-002",
  "receiver_id": "etrap.testnet",
  "token_metadata": {
    "title": "Customer Account Batch 2025-06-12-002",
    "description": "Integrity certificate for 5,000 customer account updates from 2025-06-12 afternoon",
    "media": "https://etrap-assets.s3.amazonaws.com/merkle-visualizations/batch-2025-06-12-002.svg",
    "media_hash": "YmFzZTY0X2VuY29kZWRfaGFzaF8y",
    "copies": 1,
    "issued_at": "1749583200000",
    "expires_at": null,
    "starts_at": "1749583200000",
    "updated_at": null,
    "extra": "{\"merkle_root\":\"0x892f97c4b6deed1c7a8e5f3b4e2d8a6c9f1e3b7d5a9c2e6f8b4d7a3e9c5f1b8d\",\"leaf_count\":5000,\"hash_algorithm\":\"sha256\",\"batch_id\":\"BATCH-2025-06-12-002\",\"organization_id\":\"etrap.testnet\",\"database_name\":\"customer_db\",\"batch_summary\":{\"start_timestamp\":1749572400000,\"end_timestamp\":1749583200000,\"total_transactions\":5000,\"operations_summary\":{\"inserts\":1200,\"updates\":3500,\"deletes\":300}},\"s3_bucket\":\"etrap-etrap\",\"s3_prefix\":\"customer_db/BATCH-2025-06-12-002\",\"anchoring_data\":{\"block_height\":142858500,\"tx_hash\":\"5seMwlBXgrl6gtqjp2LMved4KsFvxUwoqxMo6KWcHHxH\",\"gas_used\":\"25000000000000\",\"etrap_fee\":\"0.00063\"}}",
    "reference": "https://etrap-etrap.s3.amazonaws.com/customer_db/BATCH-2025-06-12-002/batch-data.json",
    "reference_hash": "cmVmZXJlbmNlX2hhc2hfMg=="
  },
  "batch_summary": {
    "database_name": "customer_db",
    "table_names": ["accounts", "profiles", "preferences"],
    "timestamp": 1749583200000,
    "tx_count": 5000,
    "merkle_root": "0x892f97c4b6deed1c7a8e5f3b4e2d8a6c9f1e3b7d5a9c2e6f8b4d7a3e9c5f1b8d",
    "s3_bucket": "etrap-etrap",
    "s3_key": "customer_db/BATCH-2025-06-12-002/batch-data.json",
    "size_bytes": 2621440,
    "operation_counts": {
      "inserts": 1200,
      "updates": 3500,
      "deletes": 300
    }
  }
}' --accountId etrap.testnet --deposit 0.1

# Mint Batch 3: Compliance Audit Logs (Evening batch)
near call etrap.testnet mint_batch '{
  "token_id": "BATCH-2025-06-12-003",
  "receiver_id": "etrap.testnet",
  "token_metadata": {
    "title": "Compliance Audit Batch 2025-06-12-003",
    "description": "Integrity certificate for 2,500 compliance audit logs from 2025-06-12 evening",
    "media": "https://etrap-assets.s3.amazonaws.com/merkle-visualizations/batch-2025-06-12-003.svg",
    "media_hash": "YmFzZTY0X2VuY29kZWRfaGFzaF8z",
    "copies": 1,
    "issued_at": "1749604800000",
    "expires_at": null,
    "starts_at": "1749604800000",
    "updated_at": null,
    "extra": "{\"merkle_root\":\"0xa3b7c9d2e4f6a8b1c3d5e7f9b2d4e6f8c1e3f5a7b9d2e4f6c8e1f3a5b7c9d1e3\",\"leaf_count\":2500,\"hash_algorithm\":\"sha256\",\"batch_id\":\"BATCH-2025-06-12-003\",\"organization_id\":\"etrap.testnet\",\"database_name\":\"compliance_db\",\"batch_summary\":{\"start_timestamp\":1749583200000,\"end_timestamp\":1749604800000,\"total_transactions\":2500,\"operations_summary\":{\"inserts\":2000,\"updates\":400,\"deletes\":100}},\"s3_bucket\":\"etrap-etrap\",\"s3_prefix\":\"compliance_db/BATCH-2025-06-12-003\",\"anchoring_data\":{\"block_height\":142860000,\"tx_hash\":\"6tfNxmCYhsm7hurkq3MNwfe5LtGwyVxprRNp7LXdIIyI\",\"gas_used\":\"20000000000000\",\"etrap_fee\":\"0.00050\"}}",
    "reference": "https://etrap-etrap.s3.amazonaws.com/compliance_db/BATCH-2025-06-12-003/batch-data.json",
    "reference_hash": "cmVmZXJlbmNlX2hhc2hfMw=="
  },
  "batch_summary": {
    "database_name": "compliance_db",
    "table_names": ["audit_logs", "access_logs", "regulatory_reports"],
    "timestamp": 1749604800000,
    "tx_count": 2500,
    "merkle_root": "0xa3b7c9d2e4f6a8b1c3d5e7f9b2d4e6f8c1e3f5a7b9d2e4f6c8e1f3a5b7c9d1e3",
    "s3_bucket": "etrap-etrap",
    "s3_key": "compliance_db/BATCH-2025-06-12-003/batch-data.json",
    "size_bytes": 1310720,
    "operation_counts": {
      "inserts": 2000,
      "updates": 400,
      "deletes": 100
    }
  }
}' --accountId etrap.testnet --deposit 0.1

#########################
# 4. VIEW & SEARCH NFTs
#########################

# Get recent batches (returns last 20 by default)
near view etrap.testnet get_recent_batches '{}'

# Get recent batches with custom limit
near view etrap.testnet get_recent_batches '{"limit": 10}'

# Search batches by database
near view etrap.testnet get_batches_by_database '{"database": "trading_db"}'

# Search batches by database with pagination
near view etrap.testnet get_batches_by_database '{"database": "customer_db", "from_index": 0, "limit": 50}'

# Search batches by time range (timestamps in milliseconds)
near view etrap.testnet get_batches_by_time_range '{
  "start_timestamp": 1749561600000,
  "end_timestamp": 1749604800000
}'

# Search batches by time range for specific database
near view etrap.testnet get_batches_by_time_range '{
  "start_timestamp": 1749561600000,
  "end_timestamp": 1749604800000,
  "database": "trading_db",
  "limit": 100
}'

# Search batches by table
near view etrap.testnet get_batches_by_table '{"table_name": "trades", "limit": 20}'

# Get list of all databases
near view etrap.testnet get_databases '{}'

# Get batch statistics (global)
near view etrap.testnet get_batch_stats '{}'

# Get batch statistics for specific token
near view etrap.testnet get_batch_stats '{"token_id": "BATCH-2025-06-12-001"}'

# Get batch summary for specific token
near view etrap.testnet get_batch_summary '{"token_id": "BATCH-2025-06-12-001"}'

# View specific NFT details
near view etrap.testnet nft_token '{"token_id": "BATCH-2025-06-12-001"}'

# Get total supply of NFTs
near view etrap.testnet nft_total_supply '{}'

# Get NFTs owned by account
near view etrap.testnet nft_tokens_for_owner '{"account_id": "etrap.testnet", "limit": 100}'

#########################
# 5. VERIFY TRANSACTIONS
#########################

# Verify a transaction belongs to a batch (mock merkle proof)
near view etrap.testnet verify_document_in_batch '{
  "token_id": "BATCH-2025-06-12-001",
  "document_hash": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
  "merkle_proof": [
    "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
    "0x567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234",
    "0xcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab"
  ],
  "leaf_index": 42
}'

#########################
# 6. ADDITIONAL TEST DATA
#########################

# Create more test batches for different dates/databases

# Healthcare database batch
near call etrap.testnet mint_batch '{
  "token_id": "BATCH-2025-06-11-001",
  "receiver_id": "etrap.testnet",
  "token_metadata": {
    "title": "Healthcare Records Batch 2025-06-11-001",
    "description": "Integrity certificate for 3,000 healthcare record accesses",
    "media": "https://etrap-assets.s3.amazonaws.com/merkle-visualizations/batch-2025-06-11-001.svg",
    "media_hash": "YmFzZTY0X2VuY29kZWRfaGFzaF80",
    "copies": 1,
    "issued_at": "1749475200000",
    "expires_at": null,
    "starts_at": "1749475200000",
    "updated_at": null,
    "extra": "{\"merkle_root\":\"0xb4c8d1e2f3a4b5c6d7e8f9a1b2c3d4e5f6a7b8c9d1e2f3a4b5c6d7e8f9a1b2c3\",\"leaf_count\":3000,\"hash_algorithm\":\"sha256\",\"batch_id\":\"BATCH-2025-06-11-001\",\"organization_id\":\"etrap.testnet\",\"database_name\":\"healthcare_db\",\"batch_summary\":{\"start_timestamp\":1749475200000,\"end_timestamp\":1749486000000,\"total_transactions\":3000,\"operations_summary\":{\"inserts\":500,\"updates\":2300,\"deletes\":200}},\"s3_bucket\":\"etrap-etrap\",\"s3_prefix\":\"healthcare_db/BATCH-2025-06-11-001\",\"anchoring_data\":{\"block_height\":142850000,\"tx_hash\":\"7ugOymDZitm8ivslr4NOwgf6MuHxysWqsSOq8MYeJJzJ\",\"gas_used\":\"22000000000000\",\"etrap_fee\":\"0.00055\"}}",
    "reference": "https://etrap-etrap.s3.amazonaws.com/healthcare_db/BATCH-2025-06-11-001/batch-data.json",
    "reference_hash": "cmVmZXJlbmNlX2hhc2hfNA=="
  },
  "batch_summary": {
    "database_name": "healthcare_db",
    "table_names": ["patient_records", "access_logs", "prescriptions"],
    "timestamp": 1749475200000,
    "tx_count": 3000,
    "merkle_root": "0xb4c8d1e2f3a4b5c6d7e8f9a1b2c3d4e5f6a7b8c9d1e2f3a4b5c6d7e8f9a1b2c3",
    "s3_bucket": "etrap-etrap",
    "s3_key": "healthcare_db/BATCH-2025-06-11-001/batch-data.json",
    "size_bytes": 1572864,
    "operation_counts": {
      "inserts": 500,
      "updates": 2300,
      "deletes": 200
    }
  }
}' --accountId etrap.testnet --deposit 0.1

#########################
# 7. ADMIN FUNCTIONS (Only contract owner)
#########################

# Pause the contract (emergency)
near call etrap.testnet set_paused '{"paused": true}' --accountId etrap.testnet

# Unpause the contract
near call etrap.testnet set_paused '{"paused": false}' --accountId etrap.testnet

# Update treasury address
near call etrap.testnet update_treasury '{"new_treasury": "new-etrap-treasury.testnet"}' --accountId etrap.testnet

#########################
# 8. USEFUL QUERIES FOR TESTING
#########################

# Check contract metadata
near view etrap.testnet nft_metadata '{}'

# Complex time range query (last 24 hours of data)
CURRENT_TIME=$(date +%s)000
YESTERDAY=$((CURRENT_TIME - 86400000))
near view etrap.testnet get_batches_by_time_range "{\"start_timestamp\": $YESTERDAY, \"end_timestamp\": $CURRENT_TIME}"

# Export all batch data to JSON file
near view etrap.testnet get_recent_batches '{"limit": 100}' > batches_export.json

# Monitor gas usage for optimization
near view etrap.testnet get_batch_stats '{}' | jq '.total_batches'

echo "ETRAP Contract deployment and testing complete!"