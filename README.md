# mql5-ea-safety-kit

Open-source safety, risk-guard, and audit toolkit for MQL5/MT5 Expert Advisors.

This repository provides reusable MQL5/MT5 safety and audit helpers for safer Expert Advisor (EA) development, review, and operational-checklist workflows. It is not a trading strategy, does not provide financial advice, and does not include entry signals, exit signals, order placement, order modification, or order-closing logic.

The diagnostic scripts are designed for deterministic safety checks and log output only. They do not place, modify, or close real or simulated orders.

The first published GitHub Release is [`v0.1.0`](https://github.com/swallowjp/mql5-ea-safety-kit/releases/tag/v0.1.0). For repository release notes, see [`RELEASE_NOTES.md`](RELEASE_NOTES.md).

Maintenance and reporting documents:

- [`docs/maintenance-with-codex.md`](docs/maintenance-with-codex.md) documents the issue-driven Codex-assisted maintenance workflow, human pull request review, manual MetaEditor and MetaTrader 5 verification boundaries, documentation-only review, and release management.
- [`SECURITY.md`](SECURITY.md) explains how to report safety or security concerns without exposing account credentials, broker login data, API keys, personal information, proprietary EA code, or private trading logs.

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

## MQL5 components

### Account drawdown guard

`MQL5/Include/DrawdownGuard.mqh` evaluates whether current equity remains inside caller-supplied daily and total drawdown limits. It is a safety-only account-value helper and contains no entry signal, exit signal, order placement, order modification, or order-closing logic.

The reusable `DrawdownGuardEvaluate` function accepts:

- current equity
- daily starting equity
- account starting equity
- maximum allowed daily loss amount
- maximum allowed total loss amount

It records whether trading is still allowed, whether the daily or total limit is breached, current daily and total loss amounts, remaining daily and total loss allowance, and a human-readable reason string. A limit is treated as breached when the loss amount is exactly at or above the configured amount.

Units and calculation assumptions:

- Unit: account-value units supplied by the caller; values are currency-agnostic and are not necessarily JPY, USD, or any other specific currency.
- Currency consistency: no currency conversion is performed. The caller is responsible for passing all equity and limit values in one consistent account currency or account-value unit.
- Account values: daily loss uses `daily_starting_equity - current_equity`; total loss uses `account_starting_equity - current_equity`. Balance, margin, and free margin are not used by this module.
- Time basis: the module does not define a daily reset time. The caller must decide and document whether daily starting equity is based on broker server time, Virtual Private Server (VPS) time, Coordinated Universal Time (UTC), Japan Standard Time (JST), or another explicit basis.
- Rounding method: no rounding is applied. Raw `double` values are compared with `DRAWDOWN_GUARD_EPSILON` only for insignificant binary floating-point noise around equality boundaries.

The module fails closed when required values are non-finite, negative where inappropriate, or internally inconsistent for this basic loss-only guard. In particular, it blocks if current equity is above the supplied daily or account starting equity because that input set would create a negative loss amount.

Basic usage inside an Expert Advisor or script:

```mql5
#include <DrawdownGuard.mqh>

DrawdownGuardResult dd_result;
if(!DrawdownGuardEvaluate(current_equity,
                          daily_starting_equity,
                          account_starting_equity,
                          max_daily_loss_amount,
                          max_total_loss_amount,
                          dd_result))
{
   Print("Drawdown guard blocked: ", dd_result.reason);
   return;
}

Print("Drawdown guard passed: ", dd_result.reason);
```

`DrawdownGuard` only evaluates and reports status. Users must decide how their own Expert Advisor reacts to `trading_allowed == false`; this repository does not provide a prop-firm rule implementation, trading strategy, or financial advice.

### Symbol-aware lot safety

`MQL5/Include/LotSafety.mqh` validates and normalizes a requested order volume for a requested symbol before any Expert Advisor submits an order. It is a safety-only module and contains no entry signal, exit signal, order placement, order modification, or order-closing logic.

The module reads these MetaTrader 5 symbol properties for the requested symbol:

- `SYMBOL_VOLUME_MIN`
- `SYMBOL_VOLUME_MAX`
- `SYMBOL_VOLUME_STEP`

It fails closed when symbol volume specifications are unavailable, zero, negative, non-finite, or internally inconsistent. It rejects requested volumes that are zero, negative, non-finite, below the symbol minimum, or above the symbol maximum.

For an otherwise valid in-range requested volume, the module normalizes downward to the permitted `SYMBOL_VOLUME_STEP` increment anchored at `SYMBOL_VOLUME_MIN`. It never intentionally rounds upward, so it does not silently increase requested volume or trading risk.

Rounding and unit assumptions:

- Unit: lots for the requested trading symbol.
- Account currency: not used; no currency conversion is performed.
- Balance, equity, margin, and free margin: not used by this module.
- Time basis: not used by this module.
- Rounding method: downward step normalization using `SYMBOL_VOLUME_MIN` as the anchor and `SYMBOL_VOLUME_STEP` as the increment.
- Floating-point tolerance: `LOT_SAFETY_EPSILON` is explicitly defined in the include file to handle insignificant binary floating-point representation noise.

Basic usage inside an Expert Advisor or script:

```mql5
#include <LotSafety.mqh>

LotSafetyResult lot_result;
if(!LotSafetyNormalizeVolume(_Symbol, requested_lots, lot_result))
{
   Print("Lot validation failed: ", lot_result.reason);
   return;
}

const double safe_lots = lot_result.normalized_volume;
Print("Lot validation passed: ", lot_result.reason);
```

Before live use, users must compile and verify the include file and any calling Expert Advisor in MetaEditor for their MetaTrader 5 build and broker symbols.

For first-time MT5 EA users in Japan, see the Japanese setup guide: [`docs/ja/mt5-first-time-setup.md`](docs/ja/mt5-first-time-setup.md). It explains where to place the existing `LotSafety` include file and diagnostic script, how to compile the script, how to run it on a chart, and how to read the Experts log without placing, modifying, or closing orders.

### Diagnostic test scripts

`MQL5/Scripts/TestDrawdownGuard.mq5` runs deterministic synthetic account-value test cases with hard-coded expected results for no drawdown, daily and total drawdown below/exactly at/above limits, both limits breached, invalid negative equity, invalid negative limits, and internally inconsistent starting-equity inputs. It prints each case result and a final summary without placing, modifying, or closing orders.

To run the drawdown diagnostics:

1. Copy or keep `MQL5/Include/DrawdownGuard.mqh` under the terminal's `MQL5/Include` directory.
2. Copy or keep `MQL5/Scripts/TestDrawdownGuard.mq5` under the terminal's `MQL5/Scripts` directory.
3. Compile the script in MetaEditor.
4. Attach the script to any chart.
5. Review the printed diagnostics in the MetaTrader 5 Toolbox or Experts log.

`MQL5/Scripts/TestLotSafety.mq5` uses only the current chart symbol (`_Symbol`) and prints diagnostic results for valid and invalid sample volumes. It displays the symbol minimum, maximum, volume step, requested volume, normalized volume, pass/fail result, and human-readable reason.

The script tests boundary cases around zero, negative volume, the minimum volume, fractional volume-step requests, one-step requests, the maximum volume, and above-maximum requests. It also runs independent synthetic tests against the pure lot-normalization function using explicit hard-coded expected normalized volumes for `0.01`, `0.10`, `0.25`, and `0.001` volume steps; exact-minimum, between-step, exact-maximum, below-minimum, above-maximum, zero-step, negative-step, and minimum-greater-than-maximum cases are included. The synthetic expected values are constants in the script, not values calculated by the production normalization algorithm.

The script does not place, modify, or close any real or simulated orders.

To run it:

1. Copy or keep `MQL5/Include/LotSafety.mqh` under the terminal's `MQL5/Include` directory.
2. Copy or keep `MQL5/Scripts/TestLotSafety.mq5` under the terminal's `MQL5/Scripts` directory.
3. Compile the script in MetaEditor.
4. Attach the script to a chart for the symbol you want to inspect.
5. Review the printed diagnostics in the MetaTrader 5 Toolbox or Experts log.

## Repository templates

This repository includes GitHub issue and pull request templates under `.github/` to keep maintenance records structured and auditable. The bug report and feature request templates ask contributors to identify affected components, relevant MetaTrader 5 environment details, safety impact, verification expectations, and whether any order was placed, modified, or closed. The pull request template asks reviewers to confirm changed files, safety impact, MetaEditor or MT5 verification where applicable, tests not performed, and that no order-management or proprietary strategy logic was added unless explicitly intended and documented.

These templates are maintenance aids only. They do not change MQL5 runtime behavior and do not provide trading signals.
