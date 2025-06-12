#!/bin/bash

# Test script for minting NFT with SHA256 merkle root

echo "Minting test batch with SHA256 merkle root..."

near call etrap.testnet mint_batch "$(cat <<'EOF'
{
  "token_id": "BATCH-TEST-SHA256-001",
  "receiver_id": "etrap.testnet",
  "token_metadata": {
    "title": "Test SHA256 Merkle Batch",
    "description": "Testing SHA256 merkle tree verification",
    "media": null,
    "media_hash": null,
    "copies": 1,
    "issued_at": "1734000000000",
    "expires_at": null,
    "starts_at": "1734000000000",
    "updated_at": null,
    "extra": "{\"merkle_root\":\"d8648cbc02b4e08b84ee4b55dd01030b2f2ed48699cb7b76d015ca13efd55f24\",\"leaf_count\":4,\"hash_algorithm\":\"sha256\",\"batch_id\":\"BATCH-TEST-SHA256-001\",\"organization_id\":\"etrap.testnet\",\"database_name\":\"test_db\"}",
    "reference": null,
    "reference_hash": null
  },
  "batch_summary": {
    "database_name": "test_db",
    "table_names": ["payments"],
    "timestamp": 1734000000000,
    "tx_count": 4,
    "merkle_root": "d8648cbc02b4e08b84ee4b55dd01030b2f2ed48699cb7b76d015ca13efd55f24",
    "s3_bucket": "etrap-test",
    "s3_key": "test_db/BATCH-TEST-SHA256-001/batch-data.json",
    "size_bytes": 1024,
    "operation_counts": {
      "inserts": 4,
      "updates": 0,
      "deletes": 0
    }
  }
}
EOF
)" --accountId etrap.testnet --deposit 0.1

echo ""
echo "Done! Now you can verify with:"
echo ""
echo 'near view etrap.testnet verify_document_in_batch '\''{"token_id":"BATCH-TEST-SHA256-001","document_hash":"tx2_customer_payment_67890","merkle_proof":["d779e9231adef3949d1fa4aac69c1a89fbb972a6feb0097bd9e20faac3dc16a9","454e4d0abb96f9ce64d76467a0c63efd188386b77cc08212d67100f7521570e5"],"leaf_index":1}'\'''