#!/bin/bash
"""
================================================================================
ETRAP NEAR Smart Contract - Settings Checker
================================================================================

This script checks the current configuration settings of an ETRAP smart contract.

What this script shows:
- Current treasury address for fee collection
- Fee amount configuration
- Contract pause status
- Organization information

Usage: ./check_settings.sh [contract_id]

Arguments:
  contract_id - Optional contract account (defaults to etrap.testnet)

Examples:
  # Check etrap.testnet settings
  ./check_settings.sh
  
  # Check specific contract
  ./check_settings.sh myorg.testnet
"""

CONTRACT_ID=${1:-etrap.testnet}

echo "Checking settings for contract: $CONTRACT_ID"
echo "================================================"

near view $CONTRACT_ID get_settings '{}' 
