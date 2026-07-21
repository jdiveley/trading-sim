#!/usr/bin/env bash
# Fetch a real-time-ish quote for one ticker from Yahoo Finance's unofficial chart endpoint.
# Usage: ./get_quotes.sh TICKER
# Prints a small JSON object: {"ticker":"AAPL","price":123.45,"currency":"USD"}
# Exits nonzero (and prints nothing) if the quote can't be obtained — callers must treat
# that as "no data available", never fall back to a guessed price.
set -euo pipefail

TICKER="${1:?usage: get_quotes.sh TICKER}"

RESPONSE=$(curl -s -f -A "Mozilla/5.0 (compatible; trading-sim/1.0)" \
  "https://query1.finance.yahoo.com/v8/finance/chart/${TICKER}?interval=1d&range=1d") || exit 1

echo "$RESPONSE" | python3 -c '
import json, sys
data = json.load(sys.stdin)
try:
    result = data["chart"]["result"][0]
    meta = result["meta"]
    price = meta.get("regularMarketPrice")
    if price is None:
        closes = result["indicators"]["quote"][0]["close"]
        price = next(c for c in reversed(closes) if c is not None)
    print(json.dumps({"ticker": meta.get("symbol"), "price": round(float(price), 4), "currency": meta.get("currency")}))
except Exception:
    sys.exit(1)
'
