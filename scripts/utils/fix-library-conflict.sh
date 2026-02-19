#!/bin/bash

# Script to investigate and fix library.zagent.ps nginx conflict
# Run this on your VPS

echo "🔍 Investigating library.zagent.ps conflict..."
echo ""

echo "=== Checking library.zagent.ps config ==="
cat /etc/nginx/sites-available/library.zagent.ps
echo ""

echo "=== Checking all configs for library.zagent.ps ==="
grep -n "library.zagent.ps" /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* 2>/dev/null
echo ""

echo "=== Checking for duplicate listen directives ==="
grep -n "listen.*80" /etc/nginx/sites-enabled/* 2>/dev/null
echo ""

echo "💡 To fix, you may need to:"
echo "   1. Check if library.zagent.ps is defined in multiple configs"
echo "   2. Check if there's a default server block catching it"
echo "   3. Remove duplicate server_name entries"

