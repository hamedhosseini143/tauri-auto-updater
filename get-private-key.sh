#!/bin/bash

# Helper script to get the private key for GitHub Secrets
# Run this and copy the output to GitHub Secrets as TAURI_SIGNING_PRIVATE_KEY

echo "============================================"
echo "TAURI UPDATER - Private Key Content"
echo "============================================"
echo ""
echo "Copy the content below (including the BEGIN and END lines)"
echo "and add it as a GitHub Secret named: TAURI_SIGNING_PRIVATE_KEY"
echo ""
echo "============================================"
echo ""

cat ~/.tauri/auto_updater.key

echo ""
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Name: TAURI_SIGNING_PRIVATE_KEY"
echo "5. Value: Paste the content above"
echo "6. Click 'Add secret'"
echo ""
echo "Also add TAURI_SIGNING_PRIVATE_KEY_PASSWORD secret"
echo "(leave it empty if you didn't set a password)"
echo "============================================"