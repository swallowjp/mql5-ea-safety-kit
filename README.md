# mql5-ea-safety-kit

Open-source safety, risk-guard, and audit toolkit for MQL5/MT5 Expert Advisors.

This project is not a profitable trading strategy and does not provide financial advice.
It provides reusable safety components and operational checklists for traders who build or run MT5 Expert Advisors, especially under strict drawdown rules such as prop-firm evaluations.

## Why this project exists

Many EA failures are not caused by entry logic, but by operational mistakes:

- wrong lot size
- wrong account currency assumptions
- broker server time vs local time mismatch
- JPY account vs USD-denominated backtest mismatch
- daily loss and total drawdown rule violations
- weekend hold risk
- low-liquidity execution risk
- missing live-trading checklist

This repository provides auditable MQL5 components, documentation, and checklists to reduce those errors.
