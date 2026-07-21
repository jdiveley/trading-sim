# Trading Policy

This file is the authoritative ruleset for the autonomous trading agent. If any other
document (including the routine's own prompt) conflicts with this file, **this file wins**.
Update this file, not the routine prompt, when the rules need to change.

## Objective

Grow a $5,000 simulated (paper) portfolio using real market data and real research. This is
an experiment to evaluate whether the agent's research-driven decisions are good enough to
justify real capital later — it is not investment advice.

## Starting conditions

- Starting cash: $5,000.00 (see `data/ledger.json`).
- No other funding is ever added. No margin, no borrowing.

## Asset universe

- Individual US-listed equities (any liquid, exchange-listed common stock).
- Bonds are proxied via liquid bond ETFs (trade these exactly like a stock):
  `BND` (total bond market), `TLT` (long-term Treasuries), `SHY` (short-term Treasuries),
  `AGG` (aggregate bond).
- Commodities are proxied via liquid commodity ETFs (trade these exactly like a stock):
  `GLD` (gold), `SLV` (silver), `USO` (oil), `DBC` (broad commodity basket).
- No options, futures, crypto, or shorting. No margin/leverage.

## Mechanics

- Fractional shares are allowed (size positions in dollars, then convert to shares at the
  fetched price).
- $0 commission per trade.
- Fills happen at the latest available quote at the time of each cycle.
- Three trading cycles per day: 9:00am, 12:00pm, and 3:00pm CDT (14:00, 17:00, 20:00 UTC),
  every day. On weekends and holidays quotes generally aren't available, so those cycles are
  expected to no-op. If quotes cannot be fetched (market closed, endpoint down, no network),
  the cycle is a no-op: log the reason, change nothing else.
- Running three times a day does not mean trading three times a day — most cycles should
  still be HOLD. Re-researching and re-trading a position within the same day needs a genuine
  new catalyst (fresh news, a materially moved price), not just "it's the next check-in."

## Risk / position-sizing guidelines

- No single position should exceed ~30% of total portfolio equity *at the time of purchase*.
- Prefer a small number of high-conviction positions over churn. Every trade must cite a
  concrete reason from that day's research (a headline, a data point, a named trend) in its
  `rationale` field — no rationale, no trade.
- Once total equity exceeds roughly $1,000, aim to hold exposure across at least two of the
  three asset classes (equities, bond ETFs, commodity ETFs) rather than concentrating in one.
- Keep some cash buffer when reasonable, but idle cash earns $0 (no interest is simulated).
- It is always valid to do nothing (HOLD) in a given cycle.

## End condition ("losing the $5,000")

- Compute `total_equity = cash + sum(qty * current_price)` across all holdings every cycle.
- If `total_equity <= 25.00`, the simulation is **ENDED**: set `data/status.json` to
  `"state": "ENDED"` with a reason, write a final history/research-log entry, republish the
  dashboard with an ENDED banner, and stop trading permanently. Every future cycle must check
  this status first and no-op if already ended.
- There is no other stop condition (no time limit, no profit target, no drawdown circuit
  breaker beyond the floor above). This is intentional — the simulation runs until the money
  is effectively gone.

## Data sources

- Prices: Yahoo Finance's public quote endpoint (unofficial, no API key —
  `scripts/get_quotes.sh <TICKER>`, or directly:
  `https://query1.finance.yahoo.com/v8/finance/chart/<TICKER>?interval=1d&range=1d`, using
  `regularMarketPrice` or the last value in `indicators.quote[0].close`).
- News/research: WebSearch. Useful query patterns: `"<TICKER> stock news"`,
  `"<TICKER> outlook"`, `"stock market news today"`, `"bond market yields today"`,
  `"commodity prices news today"`.
- Never fabricate a price, headline, or outcome. If real data can't be obtained for
  something, say so in the research log and skip that action.

## Dashboard

The dashboard (published as a Claude Artifact from `dashboard.html`) must show: total equity
vs the $5,000 start, cash balance, a holdings table (ticker, qty, avg cost, current price,
market value, unrealized P/L%), an equity-over-time chart (from `data/history.json`), a
transaction history table (from `data/transactions.json`), a research/decision log (from
`data/research_log.json`), and a clear RUNNING/ENDED status banner (from `data/status.json`).
