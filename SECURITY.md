# Security policy

This project provides safety components, diagnostic scripts, and documentation for MQL5/MetaTrader 5 Expert Advisor (EA) workflows. It is not financial advice, does not guarantee profitability, and does not guarantee loss prevention.

## Supported versions

| Version | Supported |
| --- | --- |
| `main` branch | Yes, for current documentation and unreleased fixes |
| Latest tagged release | Yes, when a tagged release exists |
| Older commits or forks | No guaranteed support |

This is a small volunteer-maintained project. Maintenance is best-effort, and no guaranteed response time is promised.

## Reporting a safety or security concern

Use a public GitHub issue for ordinary bugs, documentation problems, unclear assumptions, broken links, or non-sensitive maintenance requests.

For a sensitive safety or security concern, initially provide only a minimal non-secret description. Do not publish exploit details, private account data, or proprietary EA code in a public issue. If a private reporting channel is available in the repository settings, use it; otherwise, open a minimal public issue asking for a maintainer contact path without including sensitive details.

## Information that must not be shared publicly

Do not include any of the following in GitHub issues, pull requests, screenshots, logs, or examples:

* broker login data;
* account numbers or personal account identifiers;
* passwords, API keys, tokens, or recovery codes;
* personal information;
* private trading logs or account history;
* proprietary EA source code, entry logic, or exit logic;
* screenshots that reveal balances, account identifiers, broker credentials, or private trading records.

If evidence is needed, redact secrets and account identifiers before sharing. Prefer synthetic examples that reproduce the issue without exposing private trading data.

## Scope of security handling

Relevant reports may include:

* unsafe documentation that could cause users to confuse balance, equity, margin, or free margin;
* unclear account-currency conversion assumptions;
* unsafe time-basis assumptions involving broker server time, VPS time, UTC, or JST;
* lot sizing behavior that could exceed symbol minimum, maximum, or volume-step constraints;
* drawdown-control behavior that fails open when required data is unavailable;
* accidental inclusion of secrets or private trading information.

This project cannot verify every broker environment, symbol specification, account type, VPS configuration, or user EA integration. Users remain responsible for MetaEditor compilation, MetaTrader 5 runtime verification, broker-specific checks, and deciding whether any safety component is appropriate for their own environment.
