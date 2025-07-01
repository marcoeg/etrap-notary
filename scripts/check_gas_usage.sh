#!/bin/bash
"""
================================================================================
ETRAP NEAR Smart Contract - Gas Usage Checker
================================================================================

This script analyzes gas usage for ETRAP smart contract transactions,
particularly mint_batch operations which are the most gas-intensive.

What this script does:
- Shows typical gas costs for different contract operations
- Analyzes specific transactions when provided with transaction ID
- Calculates NEAR costs based on current gas prices
- Provides optimization recommendations

Usage: ./check_gas_usage.sh [transaction_id]

Arguments:
  transaction_id - Optional NEAR transaction ID to analyze

Examples:
  # Show typical gas costs
  ./check_gas_usage.sh
  
  # Analyze specific transaction
  ./check_gas_usage.sh 8VtaZjRBVZhSNKMSa6yk4d8B6W8iBZm8hHk9YLnAePHU
"""

# Script to check gas usage for mint_batch transactions

echo "Checking recent mint_batch transactions gas usage..."
echo ""

# Get recent transactions (you'll need to parse the output)
# This is a simplified example - you may need to adjust based on NEAR CLI version

# For a specific transaction ID:
if [ ! -z "$1" ]; then
    echo "Checking transaction: $1"
    echo ""
    
    # Get transaction details
    TX_OUTPUT=$(near tx-status $1 etrap.testnet 2>&1)
    
    # Check if transaction was found
    if echo "$TX_OUTPUT" | grep -q "error"; then
        echo "Error fetching transaction. Make sure the transaction ID is correct."
        echo "$TX_OUTPUT"
        exit 1
    fi
    
    echo "$TX_OUTPUT"
    echo ""
    echo "=== GAS COST SUMMARY ==="
    
    # Try to extract gas burnt with different patterns
    GAS_BURNT=$(echo "$TX_OUTPUT" | grep -E '"gas_burnt":|gas_burnt:' | sed 's/[^0-9]//g' | head -1)
    
    # If not found, try alternative patterns
    if [ -z "$GAS_BURNT" ]; then
        GAS_BURNT=$(echo "$TX_OUTPUT" | grep -A1 "gas_burnt" | tail -1 | sed 's/[^0-9]//g')
    fi
    
    if [ ! -z "$GAS_BURNT" ] && [ "$GAS_BURNT" -gt 0 ]; then
        # Convert to TGas (with awk for decimal)
        TGAS=$(awk "BEGIN {printf \"%.2f\", $GAS_BURNT / 1000000000000}")
        
        echo "Gas burnt: $GAS_BURNT Gas (~$TGAS TGas)"
        
        # Standard gas price
        ESTIMATED_COST=$(awk "BEGIN {printf \"%.6f\", $TGAS * 0.0001}")
        echo "Estimated NEAR cost: ~$ESTIMATED_COST NEAR (at 0.0001 NEAR/TGas)"
        
        # Try to find tokens_burnt
        TOKENS_BURNT=$(echo "$TX_OUTPUT" | grep -E '"tokens_burnt":|tokens_burnt:' | sed 's/[^0-9]//g' | head -1)
        
        if [ ! -z "$TOKENS_BURNT" ] && [ ${#TOKENS_BURNT} -gt 0 ]; then
            # Convert from yoctoNEAR to NEAR (24 zeros)
            NEAR_COST=$(awk "BEGIN {printf \"%.6f\", $TOKENS_BURNT / 1000000000000000000000000}")
            echo "Actual NEAR cost: $NEAR_COST NEAR"
            
            # Calculate effective gas price
            if (( $(awk "BEGIN {print ($TGAS > 0)}") )); then
                GAS_PRICE=$(awk "BEGIN {printf \"%.8f\", $NEAR_COST / $TGAS}")
                echo "Effective gas price: $GAS_PRICE NEAR/TGas"
            fi
        fi
        
        echo ""
        echo "Note: Current network gas price is typically 0.0001 NEAR/TGas"
    else
        echo "Could not extract gas information from transaction output."
        echo "Please check the transaction output above for details."
    fi
    
    exit 0
fi

# General gas costs for mint_batch:
echo "Typical gas costs for mint_batch:"
echo "- Base cost: ~3-5 TGas"
echo "- Storage allocation: ~10-15 TGas"
echo "- Event emission: ~1-2 TGas"
echo "- Index updates: ~5-10 TGas"
echo ""
echo "Total expected: ~20-35 TGas (0.002-0.0035 NEAR at standard gas prices)"
echo ""
echo "Note: Actual gas depends on:"
echo "- Number of tables in batch"
echo "- Length of strings (database name, table names)"
echo "- Current storage costs"
echo ""
echo "To check a specific transaction:"
echo "./check_gas_usage.sh [TRANSACTION_ID]"