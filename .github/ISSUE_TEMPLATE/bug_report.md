---
name: Bug report
description: Report a reproducible problem in a safety component, documentation page, or operational checklist.
title: "[bug] "
labels: []
assignees: []
---

## Affected component

<!-- Example: MQL5/Include/LotSafety.mqh, MQL5/Scripts/TestLotSafety.mq5, README.md, operational checklist, documentation. -->

## Environment

- MetaTrader 5 build, if relevant:
- MetaEditor build, if relevant:
- Operating system or VPS environment, if relevant:
- Broker symbol, if relevant:
- Account currency, if relevant:
- Broker server time zone or observed server time, if relevant:

## Expected behavior

<!-- Describe the safety, validation, documentation, or checklist behavior you expected. Include units, currencies, percentages, denominators, and time basis where relevant. -->

## Actual behavior

<!-- Describe what happened instead. Clearly distinguish balance, equity, margin, and free margin if the issue involves account state. -->

## Steps to reproduce

1.
2.
3.

## Logs or screenshots

<!-- Paste short relevant log excerpts or attach screenshots. Remove account numbers, broker credentials, API keys, private trading records, and other secrets before posting. -->

## Order activity confirmation

- Was any order placed, modified, or closed while reproducing this issue? <!-- Yes / No / Not applicable -->
- If yes, was that order activity expected and intentionally triggered outside this repository's safety-only code? <!-- Explain without sharing private account identifiers. -->

## Safety impact

<!-- Explain whether the issue could affect lot sizing, drawdown controls, account-currency conversion, time handling, or auditability. -->

## Additional context

<!-- Add any other context that may help maintainers reproduce and review the issue. Do not include proprietary trading signals or private strategy logic. -->
