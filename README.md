# Paper Trading Simulator

An autonomous, real-market paper-trading experiment. Starting from $5,000 in simulated cash,
an autonomous agent researches real stocks, bond ETFs, and commodity ETFs using live prices
and real news, then decides to buy, sell, or hold — once per US trading weekday. Every trade
is fake money, but every price and every piece of research behind it is real.

The simulation runs until the portfolio is effectively wiped out (see the end condition in
[`TRADING_POLICY.md`](./TRADING_POLICY.md)), at which point it stops permanently. The purpose
is to evaluate, after the fact, whether the agent's decisions were good enough to justify
real capital.

## How it works

- **Rules**: [`TRADING_POLICY.md`](./TRADING_POLICY.md) is the authoritative ruleset — asset
  universe, position sizing, risk limits, data sources, end condition.
- **State**: everything lives in [`data/`](./data) as plain JSON, updated once per cycle and
  committed to this repo:
  - `status.json` — RUNNING / ENDED flag and reason.
  - `ledger.json` — current cash + holdings (the live snapshot).
  - `transactions.json` — append-only trade log with a rationale for every trade.
  - `history.json` — append-only daily net-asset-value snapshots (drives the equity chart).
  - `research_log.json` — append-only dated market notes and per-ticker research summaries.
- **Automation**: a scheduled cloud agent (a Claude Code "routine") fires three times daily
  (9am / noon / 3pm CDT), reads the files above, fetches live quotes
  ([`scripts/get_quotes.sh`](./scripts/get_quotes.sh), backed by Yahoo Finance's public quote
  endpoint), does real research via web search, decides trades per the policy, updates the
  data files, regenerates the dashboard, and commits/pushes back to this repo.
- **Dashboard**: a published Claude Artifact rendered from `dashboard.html`, rebuilt from the
  `data/` files on every cycle — shows current equity vs. the $5,000 start, holdings, full
  trade history, the research log, and an equity-over-time chart.

## Status

Live dashboard: https://claude.ai/code/artifact/be815ca0-0271-47ea-86d3-3e482f34e91c

## Disclaimer

This is an educational simulation using unofficial/best-effort data sources. Nothing here is
investment advice.
