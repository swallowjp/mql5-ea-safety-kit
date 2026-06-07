# AGENTS.md

## Project overview

This repository provides open-source safety components, risk guards, and audit documentation for MQL5/MT5 Expert Advisors.

The project focuses on operational safety, reproducibility, and auditability. It is not a trading strategy and must not claim or guarantee profitability.

## Core principles

* Prefer simple and auditable implementations over complex abstractions.
* Do not add profitable-entry claims or guaranteed-performance claims.
* Do not include personal account numbers, broker credentials, API keys, private trading logs, or other secrets.
* Preserve compatibility with MQL5 and MetaTrader 5.
* Clearly distinguish account balance, equity, margin, and free margin.
* Every risk calculation must document its account currency, reference equity, time basis, and rounding method.
* Every currency conversion must state whether the rate is fixed, externally supplied, or derived from a trading symbol.
* Broker server time, VPS time, UTC, and JST must not be treated as interchangeable.
* Any modification to lot sizing, drawdown controls, account-currency conversion, or time handling requires corresponding documentation updates.
* The repository must remain useful without exposing proprietary entry or exit logic.

## Scope

Changes may include:

* daily and total drawdown guards
* lot-size and order-volume validation
* account-currency handling
* JPY/USD backtest conversion documentation
* broker server time and JST handling
* backtest-to-live discrepancy checks
* deployment and operational checklists
* example safety-only Expert Advisors

Changes must not include:

* proprietary trading signals
* claims of guaranteed profitability
* personal broker or prop-firm credentials
* private account history
* undocumented risk assumptions

## Verification checklist

Before proposing or merging a change:

1. Confirm that MQL5 code compiles in MetaEditor where possible.
2. Check that percentage calculations use an explicit denominator.
3. Check that balance and equity are not confused.
4. Check that lot sizes respect symbol minimum, maximum, and volume-step constraints.
5. Check that JPY/USD or other currency-conversion assumptions are documented.
6. Check that broker server time, UTC, VPS time, and JST are clearly distinguished.
7. Check that failure behavior is conservative when required data is unavailable.
8. Update README.md or the relevant documentation when behavior changes.
9. Update CHANGELOG.md for user-visible changes.
10. Do not expose secrets, account identifiers, or private trading data.

## Documentation style

* Use clear English for repository-wide documentation.
* Japanese documentation may be added for MT5 users in Japan.
* Define all abbreviations on first use.
* Include units, currencies, time zones, and calculation assumptions.
* Separate verified behavior from assumptions and planned features.
