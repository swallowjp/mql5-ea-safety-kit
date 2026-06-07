# Roadmap

This roadmap describes the planned development of the MQL5 EA Safety Kit.

The project focuses on operational safety, transparent assumptions, reproducible testing, and reusable MQL5 components. It does not provide proprietary trading signals or guarantee profitability.

## Phase 1 — Repository foundation

* [x] Create the public repository.
* [x] Add the project overview and scope.
* [x] Add the MIT License.
* [x] Add repository instructions for coding agents.
* [x] Add the initial changelog.
* [x] Add contribution guidelines.
* [x] Add Japanese documentation for first-time MT5 EA users.

## Phase 2 — Core safety components

* [ ] Add a basic daily and total drawdown guard.
* [x] Add lot-size and order-volume validation.
* [x] Add symbol minimum, maximum, and volume-step checks.
* [x] Add conservative failure behavior when required data is unavailable.
* [ ] Add example usage in a safety-only Expert Advisor.

## Phase 3 — Currency and time handling

* [ ] Document account-currency assumptions.
* [ ] Add JPY/USD backtest conversion guidance.
* [ ] Distinguish fixed conversion rates from symbol-derived rates.
* [ ] Document broker server time, UTC, VPS time, and JST.
* [ ] Add examples of daily reset logic across different server time zones.

## Phase 4 — Audit and verification

* [ ] Add a backtest-to-live discrepancy checklist.
* [ ] Define a standard audit report format.
* [ ] Add sample backtest and live-operation records using synthetic data.
* [ ] Add regression checks for risk calculations.
* [ ] Add release verification procedures.

## Phase 5 — Community and maintenance

* [ ] Publish the first tagged release.
* [x] Add issue templates.
* [x] Add pull request templates.
* [ ] Collect feedback from MQL5 and MT5 users.
* [ ] Improve English and Japanese documentation.
* [ ] Maintain a public changelog for user-visible changes.

## Non-goals

This project will not:

* publish proprietary trading strategies
* promise or imply guaranteed profitability
* provide financial advice
* include private broker credentials or account history
* optimize systems solely to pass a specific prop-firm evaluation
