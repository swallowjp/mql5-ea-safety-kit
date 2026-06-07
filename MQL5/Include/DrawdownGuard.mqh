#ifndef DRAWDOWN_GUARD_MQH
#define DRAWDOWN_GUARD_MQH

// DrawdownGuard.mqh
// Account-value drawdown evaluation helper for MQL5.
//
// Scope and assumptions:
// - Unit: account-value units supplied by the caller. These values are currency-
//   agnostic and are not necessarily JPY, USD, or any other specific currency.
// - Currency consistency: the caller is responsible for passing current equity,
//   daily starting equity, account starting equity, maximum daily loss, and
//   maximum total loss in one consistent account currency or account-value unit.
// - Reference equity: daily loss is measured against daily_starting_equity;
//   total loss is measured against account_starting_equity.
// - Time basis: this module does not define the daily reset time. The caller is
//   responsible for selecting and documenting whether the daily starting equity
//   is based on broker server time, Virtual Private Server (VPS) time,
//   Coordinated Universal Time (UTC), Japan Standard Time (JST), or another
//   explicitly documented basis.
// - Rounding method: no rounding is applied. Raw double values supplied by the
//   caller are compared using DRAWDOWN_GUARD_EPSILON only to absorb insignificant
//   binary floating-point representation noise around equality boundaries.
// - Trading behavior: this module only evaluates and reports status. It does not
//   place orders, modify orders, close positions, or implement entry/exit logic.

#define DRAWDOWN_GUARD_EPSILON 1.0e-9

struct DrawdownGuardResult
{
   bool   trading_allowed;
   bool   daily_limit_breached;
   bool   total_limit_breached;
   double current_equity;
   double daily_starting_equity;
   double account_starting_equity;
   double max_allowed_daily_loss_amount;
   double max_allowed_total_loss_amount;
   double current_daily_loss_amount;
   double current_total_loss_amount;
   double remaining_daily_loss_allowance;
   double remaining_total_loss_allowance;
   string reason;
};

bool DrawdownGuardIsFinite(const double value)
{
   return MathIsValidNumber(value);
}

void DrawdownGuardInitializeResult(DrawdownGuardResult &result,
                                   const double current_equity,
                                   const double daily_starting_equity,
                                   const double account_starting_equity,
                                   const double max_allowed_daily_loss_amount,
                                   const double max_allowed_total_loss_amount)
{
   result.trading_allowed = false;
   result.daily_limit_breached = false;
   result.total_limit_breached = false;
   result.current_equity = current_equity;
   result.daily_starting_equity = daily_starting_equity;
   result.account_starting_equity = account_starting_equity;
   result.max_allowed_daily_loss_amount = max_allowed_daily_loss_amount;
   result.max_allowed_total_loss_amount = max_allowed_total_loss_amount;
   result.current_daily_loss_amount = 0.0;
   result.current_total_loss_amount = 0.0;
   result.remaining_daily_loss_allowance = 0.0;
   result.remaining_total_loss_allowance = 0.0;
   result.reason = "Evaluation has not run.";
}

void DrawdownGuardSetFailure(DrawdownGuardResult &result,
                             const string reason)
{
   result.trading_allowed = false;
   result.daily_limit_breached = true;
   result.total_limit_breached = true;
   result.reason = reason;
}

bool DrawdownGuardEvaluate(const double current_equity,
                           const double daily_starting_equity,
                           const double account_starting_equity,
                           const double max_allowed_daily_loss_amount,
                           const double max_allowed_total_loss_amount,
                           DrawdownGuardResult &result)
{
   DrawdownGuardInitializeResult(result,
                                 current_equity,
                                 daily_starting_equity,
                                 account_starting_equity,
                                 max_allowed_daily_loss_amount,
                                 max_allowed_total_loss_amount);

   if(!DrawdownGuardIsFinite(current_equity) ||
      !DrawdownGuardIsFinite(daily_starting_equity) ||
      !DrawdownGuardIsFinite(account_starting_equity) ||
      !DrawdownGuardIsFinite(max_allowed_daily_loss_amount) ||
      !DrawdownGuardIsFinite(max_allowed_total_loss_amount))
   {
      DrawdownGuardSetFailure(result, "Required drawdown input contains a non-finite value; trading is blocked.");
      return false;
   }

   if(current_equity < 0.0)
   {
      DrawdownGuardSetFailure(result, "Current equity must not be negative; trading is blocked.");
      return false;
   }

   if(daily_starting_equity < 0.0)
   {
      DrawdownGuardSetFailure(result, "Daily starting equity must not be negative; trading is blocked.");
      return false;
   }

   if(account_starting_equity < 0.0)
   {
      DrawdownGuardSetFailure(result, "Account starting equity must not be negative; trading is blocked.");
      return false;
   }

   if(max_allowed_daily_loss_amount < 0.0)
   {
      DrawdownGuardSetFailure(result, "Maximum allowed daily loss amount must not be negative; trading is blocked.");
      return false;
   }

   if(max_allowed_total_loss_amount < 0.0)
   {
      DrawdownGuardSetFailure(result, "Maximum allowed total loss amount must not be negative; trading is blocked.");
      return false;
   }

   if(daily_starting_equity + DRAWDOWN_GUARD_EPSILON < current_equity)
   {
      DrawdownGuardSetFailure(result, "Daily starting equity is below current equity; inputs are internally inconsistent for this basic loss-only guard.");
      return false;
   }

   if(account_starting_equity + DRAWDOWN_GUARD_EPSILON < current_equity)
   {
      DrawdownGuardSetFailure(result, "Account starting equity is below current equity; inputs are internally inconsistent for this basic loss-only guard.");
      return false;
   }

   result.current_daily_loss_amount = daily_starting_equity - current_equity;
   result.current_total_loss_amount = account_starting_equity - current_equity;

   if(MathAbs(result.current_daily_loss_amount) <= DRAWDOWN_GUARD_EPSILON)
      result.current_daily_loss_amount = 0.0;

   if(MathAbs(result.current_total_loss_amount) <= DRAWDOWN_GUARD_EPSILON)
      result.current_total_loss_amount = 0.0;

   result.remaining_daily_loss_allowance = max_allowed_daily_loss_amount - result.current_daily_loss_amount;
   result.remaining_total_loss_allowance = max_allowed_total_loss_amount - result.current_total_loss_amount;

   result.daily_limit_breached = (result.current_daily_loss_amount + DRAWDOWN_GUARD_EPSILON >= max_allowed_daily_loss_amount);
   result.total_limit_breached = (result.current_total_loss_amount + DRAWDOWN_GUARD_EPSILON >= max_allowed_total_loss_amount);
   result.trading_allowed = (!result.daily_limit_breached && !result.total_limit_breached);

   if(result.trading_allowed)
   {
      result.reason = "Trading allowed: daily and total drawdown limits are not breached.";
      return true;
   }

   if(result.daily_limit_breached && result.total_limit_breached)
      result.reason = "Trading blocked: daily and total drawdown limits are breached.";
   else if(result.daily_limit_breached)
      result.reason = "Trading blocked: daily drawdown limit is breached.";
   else
      result.reason = "Trading blocked: total drawdown limit is breached.";

   return false;
}

#endif // DRAWDOWN_GUARD_MQH
