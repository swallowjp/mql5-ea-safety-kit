# Contributing to MQL5 EA Safety Kit

Thank you for considering a contribution to this project.

This repository focuses on operational safety, transparent assumptions, reproducible testing, and auditable MQL5/MT5 components. It does not provide trading signals or guarantee profitability.

## Ways to contribute

You may contribute by:

* reporting bugs
* improving English or Japanese documentation
* proposing safety checks
* improving MQL5 compatibility
* adding test cases
* identifying unclear assumptions
* reviewing risk calculations
* suggesting improvements to deployment checklists

## Before submitting a change

Please check the following:

1. The change is related to EA safety, risk control, auditability, or operational documentation.
2. The change does not include proprietary trading signals.
3. The change does not claim or imply guaranteed profitability.
4. No broker credentials, account numbers, API keys, or private trading records are included.
5. Currency, units, time zones, and calculation assumptions are explicitly documented.
6. Balance, equity, margin, and free margin are not treated as interchangeable.
7. Broker server time, UTC, VPS time, and JST are clearly distinguished.
8. MQL5 code is kept simple and auditable.
9. User-visible changes are recorded in `CHANGELOG.md`.

## Issues

Before opening a new issue:

* check whether a similar issue already exists
* use a clear and specific title
* describe the expected behavior
* describe the actual behavior
* include the MetaTrader 5 build and operating environment when relevant
* remove all personal account information and credentials

## Pull requests

A pull request should:

* address one main topic
* explain what was changed and why
* identify any new assumptions
* include documentation updates when behavior changes
* avoid unrelated formatting changes
* pass the verification checklist in `AGENTS.md`

## MQL5 code requirements

MQL5 contributions should:

* respect symbol minimum, maximum, and volume-step constraints
* validate required data before performing risk calculations
* fail conservatively when essential information is unavailable
* distinguish balance-based and equity-based limits
* document account-currency conversion behavior
* avoid hidden dependencies on broker-specific symbol names
* avoid including proprietary entry or exit logic

## Documentation

Repository-wide documentation should normally be written in English.

Japanese documentation may be added for MT5 users in Japan. Technical names, MQL5 identifiers, currencies, units, and time zones should remain explicit.

## Financial disclaimer

This project is provided for software safety and educational purposes. It is not financial advice, investment advice, or a guarantee of trading performance.
