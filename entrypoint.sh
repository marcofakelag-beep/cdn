#!/bin/bash

# XITEXE PROXY V9 - Entrypoint Script

set -e

echo "🔥 XITEXE PROXY V9"
echo "📦 Starting server..."

# Install dependencies if needed
npm install

# Start the application
npx serve -l 8080