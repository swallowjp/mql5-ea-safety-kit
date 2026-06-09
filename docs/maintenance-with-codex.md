# Codex-assisted maintenance workflow

This guide documents the real maintenance workflow used for this repository when a scoped GitHub issue is implemented with Codex assistance. It is a human-reviewed workflow for safety and documentation work around MQL5/MetaTrader 5 Expert Advisor (EA) components.

Codex output is treated as a proposed diff. It is not automatically trusted code, does not replace maintainer review, and does not prove that MQL5 code compiles or behaves correctly in a user's MetaEditor or MetaTrader 5 environment.

This repository is safety-focused. Maintenance work must not unintentionally add trading strategy logic, entry signals, exit signals, order placement, order modification, or order-closing logic.

## 1. Issue definition

Each change should begin with a scoped GitHub issue before implementation starts.

The issue should state:

* the problem being addressed;
* explicit acceptance criteria;
* files expected to be added or changed, when known;
* safety limits, non-goals, and out-of-scope behavior;
* whether MQL5 runtime code may be changed or whether the work is documentation-only;
* required documentation updates, including `README.md`, `CHANGELOG.md`, or other relevant files;
* expected verification steps and any environment-specific checks that a human must perform.

For safety-related changes, the issue should also state which assumptions are in scope, including account currency, reference equity, time basis, rounding method, and failure behavior when required data is unavailable.

The issue must not request or include proprietary entry or exit logic, private broker credentials, account numbers, API keys, personal trading logs, or other secrets.

## 2. Codex implementation

Codex reads the issue, `AGENTS.md`, and the relevant repository documentation before changing files.

Codex may then prepare a proposed diff on a separate branch. The diff should stay within the issue scope and should avoid unrelated formatting changes.

During implementation, Codex must:

* preserve MQL5 and MetaTrader 5 compatibility when MQL5 files are touched;
* avoid adding trading strategy logic or order-operation logic unless the scoped issue explicitly permits that kind of runtime behavior;
* update documentation when behavior, assumptions, verification steps, or user-visible workflow changes;
* avoid claims of profitability, guaranteed loss prevention, third-party adoption, production deployment, or automated MQL5 continuous integration (CI) unless those claims are true and verified;
* avoid claiming that MetaEditor compilation or MetaTrader 5 runtime verification was completed unless those tools were actually used;
* record checks that were performed and checks that could not be performed.

Codex output is a maintenance aid, not a release authority. The generated diff remains unmerged until human review is complete.

## 3. Pull request review

A pull request is the review boundary for Codex-assisted work.

Before merge, a human reviewer should inspect:

* all changed files;
* public APIs, file paths, examples, and documented behavior;
* risk calculations, including explicit denominators for percentage calculations;
* balance, equity, margin, and free margin terminology;
* lot-size handling against symbol minimum, maximum, and volume-step constraints when lot logic changes;
* account-currency conversion assumptions when currency behavior changes;
* broker server time, Virtual Private Server (VPS) time, Coordinated Universal Time (UTC), and Japan Standard Time (JST) wording when time behavior changes;
* documentation claims compared with the actual implementation;
* whether unknown, skipped, or environment-specific checks are clearly recorded.

The reviewer should treat the pull request as an auditable proposal. Approval means the reviewed diff is acceptable for this repository; it does not mean every broker, account type, symbol specification, or user environment has been verified.

## 4. MetaEditor compilation

MetaEditor compilation is required when MQL5 runtime files, scripts, include files, or examples are changed and MetaEditor is available.

For MQL5 runtime changes, record:

* the MT5 or MetaEditor build, when available;
* the files compiled;
* the exact compilation result, including errors and warnings;
* whether any generated `.ex5` output was created from the intended `.mq5` source.

If MetaEditor was not used, do not imply that compilation passed. Record the check as not performed and explain the limitation, for example: `MetaEditor was not available in this environment`.

Documentation-only changes do not require MetaEditor compilation unless the documentation embeds MQL5 examples that need validation. For documentation-only changes, state that MetaEditor compilation was not required because no MQL5 runtime code changed.

## 5. MetaTrader 5 runtime verification

MetaTrader 5 runtime verification is required when MQL5 runtime behavior changes and MT5 is available.

For deterministic diagnostic scripts, runtime verification should record:

* the script name and chart symbol used;
* the account type used for testing, without account numbers or credentials;
* the Experts log summary line, such as total, passed, and failed counts;
* any errors or warnings shown in the Experts log;
* confirmation that the diagnostic did not place, modify, or close orders.

Runtime verification confirms only the tested environment and tested inputs. Broker behavior, symbol specifications, trading-session rules, and account permissions can differ across brokers, account types, and symbols.

If MT5 was not used, do not imply that runtime verification passed. Record the check as not performed and explain the limitation.

## 6. Documentation-only review

For documentation-only changes, review is still required even when MetaEditor and MT5 verification are not required.

The documentation-only review should check:

* links, file paths, and headings;
* whether wording matches actual repository behavior;
* whether documentation separates verified behavior from assumptions and planned features;
* whether the change avoids claims of automated MQL5 CI, third-party adoption, production deployment, profitability, or guaranteed loss prevention;
* whether sensitive information such as account credentials, broker login data, API keys, personal information, proprietary EA code, and private trading logs is excluded;
* whether the change accurately lists checks performed and checks not performed.

Documentation-only review does not prove MQL5 runtime behavior. It only reviews the correctness and scope of the documentation change.

## 7. Merge and release management

Merge only after human review is complete and the review record is acceptable for the change type.

After review:

* close the linked issue after completion;
* delete temporary branches when appropriate;
* record user-visible changes in `CHANGELOG.md`;
* update release notes or roadmap items when they change;
* prepare tagged GitHub Releases manually from reviewed `main` when a release is ready.

This repository does not currently claim automated MQL5 CI. Release preparation should therefore keep manual verification records visible and should not convert unperformed manual checks into passing claims.

## Current limitations

* This repository does not currently use automated MQL5 CI.
* MetaEditor compilation is manual and environment-specific.
* MetaTrader 5 runtime verification is manual and environment-specific.
* Broker behavior and symbol specifications can differ by broker, account type, and symbol.
* Codex cannot replace human review or environment-specific verification.
* Documentation-only review does not verify MQL5 runtime behavior.
