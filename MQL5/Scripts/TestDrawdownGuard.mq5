#property script_show_inputs
#property strict

#include <DrawdownGuard.mqh>

// TestDrawdownGuard.mq5
// Deterministic diagnostic script for DrawdownGuard.mqh.
// It uses synthetic account-value inputs only and does not place, modify, or close orders.

bool TestDrawdownGuardDoublesEqual(const double actual,
                                   const double expected)
{
   return (MathAbs(actual - expected) <= 1.0e-8);
}

void RecordDrawdownGuardTestResult(const string label,
                                   const bool test_passed,
                                   int &total_tests,
                                   int &passed_tests,
                                   int &failed_tests)
{
   total_tests++;

   if(test_passed)
      passed_tests++;
   else
      failed_tests++;

   PrintFormat("DrawdownGuard test [%s]: %s", label, (test_passed ? "TEST PASS" : "TEST FAIL"));
}

void RunDrawdownGuardCase(const string label,
                          const double current_equity,
                          const double daily_starting_equity,
                          const double account_starting_equity,
                          const double max_allowed_daily_loss_amount,
                          const double max_allowed_total_loss_amount,
                          const bool expected_trading_allowed,
                          const bool expected_daily_limit_breached,
                          const bool expected_total_limit_breached,
                          const double expected_current_daily_loss_amount,
                          const double expected_current_total_loss_amount,
                          const double expected_remaining_daily_loss_allowance,
                          const double expected_remaining_total_loss_allowance,
                          int &total_tests,
                          int &passed_tests,
                          int &failed_tests)
{
   DrawdownGuardResult result;
   const bool accepted = DrawdownGuardEvaluate(current_equity,
                                               daily_starting_equity,
                                               account_starting_equity,
                                               max_allowed_daily_loss_amount,
                                               max_allowed_total_loss_amount,
                                               result);

   const bool test_passed = (accepted == expected_trading_allowed &&
                             result.trading_allowed == expected_trading_allowed &&
                             result.daily_limit_breached == expected_daily_limit_breached &&
                             result.total_limit_breached == expected_total_limit_breached &&
                             TestDrawdownGuardDoublesEqual(result.current_daily_loss_amount, expected_current_daily_loss_amount) &&
                             TestDrawdownGuardDoublesEqual(result.current_total_loss_amount, expected_current_total_loss_amount) &&
                             TestDrawdownGuardDoublesEqual(result.remaining_daily_loss_allowance, expected_remaining_daily_loss_allowance) &&
                             TestDrawdownGuardDoublesEqual(result.remaining_total_loss_allowance, expected_remaining_total_loss_allowance));

   RecordDrawdownGuardTestResult(label, test_passed, total_tests, passed_tests, failed_tests);

   PrintFormat("DrawdownGuard synthetic case [%s] current_equity=%.2f daily_start=%.2f account_start=%.2f daily_limit=%.2f total_limit=%.2f allowed=%s expected_allowed=%s daily_breached=%s expected_daily_breached=%s total_breached=%s expected_total_breached=%s daily_loss=%.2f expected_daily_loss=%.2f total_loss=%.2f expected_total_loss=%.2f remaining_daily=%.2f expected_remaining_daily=%.2f remaining_total=%.2f expected_remaining_total=%.2f reason=%s",
               label,
               current_equity,
               daily_starting_equity,
               account_starting_equity,
               max_allowed_daily_loss_amount,
               max_allowed_total_loss_amount,
               (result.trading_allowed ? "true" : "false"),
               (expected_trading_allowed ? "true" : "false"),
               (result.daily_limit_breached ? "true" : "false"),
               (expected_daily_limit_breached ? "true" : "false"),
               (result.total_limit_breached ? "true" : "false"),
               (expected_total_limit_breached ? "true" : "false"),
               result.current_daily_loss_amount,
               expected_current_daily_loss_amount,
               result.current_total_loss_amount,
               expected_current_total_loss_amount,
               result.remaining_daily_loss_allowance,
               expected_remaining_daily_loss_allowance,
               result.remaining_total_loss_allowance,
               expected_remaining_total_loss_allowance,
               result.reason);
}

void OnStart()
{
   int total_tests = 0;
   int passed_tests = 0;
   int failed_tests = 0;

   Print("DrawdownGuard deterministic synthetic tests use account-value units supplied by the caller.");
   Print("The caller is responsible for currency consistency. This script does not place, modify, or close orders.");

   RunDrawdownGuardCase("no drawdown",
                        100000.00, 100000.00, 100000.00, 5000.00, 10000.00,
                        true, false, false, 0.00, 0.00, 5000.00, 10000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("daily drawdown below limit",
                        98000.00, 100000.00, 105000.00, 5000.00, 10000.00,
                        true, false, false, 2000.00, 7000.00, 3000.00, 3000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("daily drawdown exactly at limit",
                        95000.00, 100000.00, 105000.00, 5000.00, 15000.00,
                        false, true, false, 5000.00, 10000.00, 0.00, 5000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("daily drawdown above limit",
                        94000.00, 100000.00, 105000.00, 5000.00, 15000.00,
                        false, true, false, 6000.00, 11000.00, -1000.00, 4000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("total drawdown below limit",
                        97000.00, 99000.00, 100000.00, 5000.00, 10000.00,
                        true, false, false, 2000.00, 3000.00, 3000.00, 7000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("total drawdown exactly at limit",
                        90000.00, 94000.00, 100000.00, 5000.00, 10000.00,
                        false, false, true, 4000.00, 10000.00, 1000.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("total drawdown above limit",
                        89000.00, 93000.00, 100000.00, 5000.00, 10000.00,
                        false, false, true, 4000.00, 11000.00, 1000.00, -1000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("both daily and total limits breached",
                        89000.00, 95000.00, 100000.00, 5000.00, 10000.00,
                        false, true, true, 6000.00, 11000.00, -1000.00, -1000.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("invalid negative equity",
                        -1.00, 100000.00, 100000.00, 5000.00, 10000.00,
                        false, true, true, 0.00, 0.00, 0.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("invalid negative daily limit",
                        99000.00, 100000.00, 100000.00, -5000.00, 10000.00,
                        false, true, true, 0.00, 0.00, 0.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("invalid negative total limit",
                        99000.00, 100000.00, 100000.00, 5000.00, -10000.00,
                        false, true, true, 0.00, 0.00, 0.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("daily start equity below current equity",
                        101000.00, 100000.00, 105000.00, 5000.00, 10000.00,
                        false, true, true, 0.00, 0.00, 0.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   RunDrawdownGuardCase("account start equity below current equity",
                        101000.00, 102000.00, 100000.00, 5000.00, 10000.00,
                        false, true, true, 0.00, 0.00, 0.00, 0.00,
                        total_tests, passed_tests, failed_tests);

   PrintFormat("DrawdownGuard test summary: total=%d passed=%d failed=%d", total_tests, passed_tests, failed_tests);
}
