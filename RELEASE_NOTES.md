# Release notes — v0.1.0

`v0.1.0` is the first public-release preparation package for `mql5-ea-safety-kit`.

The release is intended for human review before a GitHub Release is created manually. It packages the current safety-only MQL5 components, deterministic diagnostic scripts, and project documentation without adding trading strategy logic or changing MQL5 runtime behavior.

## Project purpose

This repository provides open-source safety, risk-guard, and audit documentation for MetaTrader 5 (MT5) Expert Advisors (EAs) written in MQL5. It is designed to help EA developers and reviewers make operational assumptions visible, especially around order volume, account-value drawdown limits, manual verification records, and reproducible setup steps.

The project is not financial advice, not a profitable trading strategy, and not a prop-firm pass guarantee. It does not include entry signals, exit signals, order placement, order modification, or order-closing logic.

## Included modules

### `LotSafety`

`MQL5/Include/LotSafety.mqh` validates and normalizes a requested lot volume for a requested symbol using MetaTrader 5 symbol volume properties. It checks the symbol minimum, maximum, and volume step, fails closed when required symbol data is unavailable or invalid, and normalizes valid in-range requests downward to the permitted step. It does not use account balance, equity, margin, free margin, account currency, or time-zone data.

### `DrawdownGuard`

`MQL5/Include/DrawdownGuard.mqh` evaluates daily and total drawdown status from caller-supplied account-value inputs. It compares current equity with daily starting equity and account starting equity using maximum daily and total loss amounts supplied by the caller. It performs no currency conversion and does not define a daily reset time; callers must keep units consistent and explicitly document whether their reset basis is broker server time, Virtual Private Server (VPS) time, Coordinated Universal Time (UTC), Japan Standard Time (JST), or another basis.

## Diagnostic scripts

`MQL5/Scripts/TestLotSafety.mq5` prints current-chart-symbol lot-safety diagnostics and deterministic synthetic normalization checks with hard-coded expected values.

`MQL5/Scripts/TestDrawdownGuard.mq5` prints deterministic synthetic drawdown guard checks with hard-coded expected pass and block outcomes.

Both diagnostic scripts are safety-check scripts only. They do not place, modify, or close real or simulated orders.

## Documentation included

`v0.1.0` release preparation includes:

* `README.md` with project scope, module behavior, calculation assumptions, and diagnostic-script usage.
* `CHANGELOG.md` with release-oriented `v0.1.0` notes.
* `ROADMAP.md` with first public release preparation marked complete.
* `CONTRIBUTING.md` with safety and verification expectations for contributors.
* `AGENTS.md` with repository-specific safety, documentation, and verification instructions.
* `.github/` issue and pull request templates for structured maintenance records.
* `docs/ja/mt5-first-time-setup.md`, a Japanese setup guide for first-time MT5 EA users.

## Manual verification status

The repository contains documentation for manual MetaEditor and MT5 checks and deterministic diagnostic scripts intended to be compiled and run in a user's own MetaTrader 5 environment.

No new MQL5 runtime behavior was added for this release-preparation change. This release note does not claim third-party adoption, production deployment, user counts, stars, or universal broker compatibility.

## Limitations

* MQL5 compilation must be confirmed in MetaEditor on the user's target MT5 build where possible.
* Broker symbol volume specifications can differ by broker, account type, and symbol.
* `LotSafety` does not calculate position risk from price distance, stop loss, account currency, margin, or free margin.
* `DrawdownGuard` does not convert currencies, retrieve account values, define daily reset timing, or implement a specific prop-firm rule set.
* Diagnostic scripts do not prove that losses will be prevented, profits will occur, or any external evaluation will be passed.
* Backtest-to-live discrepancy guidance, account-currency conversion guidance, and detailed broker-server-time examples remain roadmap items.

## Non-goals

This release does not:

* provide proprietary trading strategies;
* provide entry or exit signals;
* place, modify, or close orders;
* guarantee profitability or loss prevention;
* provide financial advice;
* claim production deployment or third-party adoption;
* include private broker credentials, account numbers, API keys, or private trading logs; or
* optimize systems solely to pass a specific prop-firm evaluation.
