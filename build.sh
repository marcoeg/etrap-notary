#!/bin/bash
"""
================================================================================
ETRAP NEAR Smart Contract - Build Script
================================================================================

This script builds the ETRAP NEAR smart contract from Rust source code to
WebAssembly (WASM) for deployment on the NEAR blockchain.

What this script does:
- Ensures the wasm32-unknown-unknown target is installed
- Builds the contract with optimized release settings
- Creates output directory and copies the WASM file
- Shows contract size information
- Optionally runs wasm-opt for further optimization

Usage: ./build.sh

No parameters required - this is a self-contained build process.

Output: out/etrap_contract.wasm (ready for deployment)
"""

# ETRAP Smart Contract Build Script

set -e

echo "Building ETRAP NEAR Smart Contract..."

# Ensure we have the wasm target
rustup target add wasm32-unknown-unknown

# Build the contract
RUSTFLAGS='-C link-arg=-s' cargo build --target wasm32-unknown-unknown --release

# Create output directory
mkdir -p out

# Copy the wasm file
cp target/wasm32-unknown-unknown/release/*.wasm out/etrap_contract.wasm

# Get the file size
SIZE=$(ls -lh out/etrap_contract.wasm | awk '{print $5}')

echo "✅ Build complete!"
echo "📦 Contract size: $SIZE"
echo "📍 Output: out/etrap_contract.wasm"

# Optional: Run wasm-opt if available (reduces size further)
if command -v wasm-opt &> /dev/null; then
    echo "Running wasm-opt optimization..."
    wasm-opt -Oz out/etrap_contract.wasm -o out/etrap_contract_optimized.wasm
    SIZE_OPT=$(ls -lh out/etrap_contract_optimized.wasm | awk '{print $5}')
    echo "📦 Optimized size: $SIZE_OPT"
fi