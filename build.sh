#!/bin/bash
# Build script for Flowdit Power BI Custom Connector
# Produces a .mez file for Power BI Desktop installation
# Usage: bash build.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy required assets
cp "$SCRIPT_DIR"/*.png "$BUILD_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR"/*.pqm "$BUILD_DIR/" 2>/dev/null || true

# Copy connector .pq as .m
cp "$SCRIPT_DIR/flowditConnector.pq" "$BUILD_DIR/flowditConnector.m"

# Compress into .zip then rename to .mez
cd "$BUILD_DIR"
zip -q -r "flowditConnector.zip" ./*
mv "flowditConnector.zip" "flowditConnector.mez"

echo ""
echo -e "\033[32mBuild complete: $BUILD_DIR/flowditConnector.mez\033[0m"
echo ""
echo -e "\033[36mTo install:\033[0m"
echo "  1. Copy flowditConnector.mez to: [Documents]/Power BI Desktop/Custom Connectors/"
echo "  2. In Power BI Desktop: Options > Security > Data Extensions > enable custom connectors"
echo "  3. Restart Power BI Desktop"
echo "  4. Get Data > flowditConnector"
