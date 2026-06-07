# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project intends to use semantic versioning for public releases.

## [Unreleased]

### Added

* Added `MQL5/Include/DrawdownGuard.mqh` for basic daily and total drawdown evaluation using caller-supplied account-value units without order operations.
* Added `MQL5/Scripts/TestDrawdownGuard.mq5` with deterministic synthetic drawdown guard diagnostics and hard-coded expected results.
* Documented DrawdownGuard usage, assumptions, failure behavior, and limitations in `README.md` and the Japanese first-time MT5 setup guide.

* Added a Japanese first-time MT5 EA user setup guide for installing, compiling, running, and reading the `LotSafety` diagnostic script without placing, modifying, or closing orders.

* Added GitHub bug report, feature request, and pull request templates to standardize safety and auditability review records.

* Added independent synthetic lot-normalization diagnostics with hard-coded expected normalized volumes for multiple volume-step specifications.

* Added `MQL5/Include/LotSafety.mqh` for symbol-aware lot validation and conservative downward volume-step normalization.
* Added `MQL5/Scripts/TestLotSafety.mq5` to print current-chart-symbol lot-safety boundary diagnostics without placing orders.
* Documented lot-safety usage, assumptions, and MetaEditor verification requirements in `README.md`.

* Initial public repository structure.
* Project overview and safety objectives in `README.md`.
* MIT License.
* Repository maintenance and verification instructions in `AGENTS.md`.

### Planned

* Account-currency handling documentation.
* JPY/USD backtest conversion guidance.
* Broker server time, UTC, VPS time, and JST documentation.
* Backtest-to-live discrepancy checklist.
* Example safety-only Expert Advisor.
