#property script_show_inputs
#property strict

#include <LotSafety.mqh>

// TestLotSafety.mq5
// Diagnostic script for LotSafety.mqh.
// Uses only the current chart symbol (_Symbol), prints boundary-case results,
// runs independent synthetic normalization tests with hard-coded expected values,
// and does not place, modify, or close any real or simulated order.

bool TestLotSafetyVolumesEqual(const double actual_volume, const double expected_volume)
{
   return MathAbs(actual_volume - expected_volume) <= LOT_SAFETY_EPSILON;
}

void RecordLotSafetyTestResult(const string label,
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

   if(!test_passed)
      PrintFormat("LotSafety test failure recorded for [%s]", label);
}

void RunSymbolLotSafetyCase(const string label,
                            const string symbol,
                            const double requested_volume,
                            const bool expected_acceptance,
                            const bool check_expected_normalized_volume,
                            const double expected_normalized_volume,
                            int &total_tests,
                            int &passed_tests,
                            int &failed_tests)
{
   LotSafetyResult result;
   const bool accepted = LotSafetyNormalizeVolume(symbol, requested_volume, result);
   const bool acceptance_matches = (accepted == expected_acceptance);
   bool normalized_matches = true;

   if(check_expected_normalized_volume)
      normalized_matches = (accepted && TestLotSafetyVolumesEqual(result.normalized_volume, expected_normalized_volume));

   const bool test_passed = (acceptance_matches && normalized_matches);
   RecordLotSafetyTestResult(label, test_passed, total_tests, passed_tests, failed_tests);

   PrintFormat("LotSafety symbol test [%s] requested=%.12f actual=%s expected=%s actual_normalized=%.12f expected_normalized=%s test=%s reason=%s",
               label,
               requested_volume,
               (accepted ? "ACCEPTED" : "REJECTED"),
               (expected_acceptance ? "ACCEPTED" : "REJECTED"),
               result.normalized_volume,
               (check_expected_normalized_volume ? DoubleToString(expected_normalized_volume, 12) : "not checked"),
               (test_passed ? "TEST PASS" : "TEST FAIL"),
               result.reason);
}

void RunSymbolNormalizedInvariantCase(const string label,
                                      const string symbol,
                                      const double requested_volume,
                                      const double volume_min,
                                      const double volume_max,
                                      int &total_tests,
                                      int &passed_tests,
                                      int &failed_tests)
{
   LotSafetyResult result;
   const bool accepted = LotSafetyNormalizeVolume(symbol, requested_volume, result);
   const bool test_passed = (accepted &&
                             result.normalized_volume <= requested_volume + LOT_SAFETY_EPSILON &&
                             result.normalized_volume >= volume_min - LOT_SAFETY_EPSILON &&
                             result.normalized_volume <= volume_max + LOT_SAFETY_EPSILON &&
                             result.normalized_volume > 0.0 &&
                             LotSafetyIsFinite(result.normalized_volume));

   RecordLotSafetyTestResult(label, test_passed, total_tests, passed_tests, failed_tests);

   PrintFormat("LotSafety symbol invariant test [%s] requested=%.12f actual=%s actual_normalized=%.12f min=%.12f max=%.12f test=%s reason=%s",
               label,
               requested_volume,
               (accepted ? "ACCEPTED" : "REJECTED"),
               result.normalized_volume,
               volume_min,
               volume_max,
               (test_passed ? "TEST PASS" : "TEST FAIL"),
               result.reason);
}

void RunSyntheticLotSafetyCase(const string label,
                               const double volume_min,
                               const double volume_max,
                               const double volume_step,
                               const double requested_volume,
                               const bool expected_acceptance,
                               const double expected_normalized_volume,
                               int &total_tests,
                               int &passed_tests,
                               int &failed_tests)
{
   LotSafetyResult result;
   const bool accepted = LotSafetyNormalizeVolumeFromSpecs("SYNTHETIC", requested_volume, volume_min, volume_max, volume_step, result);
   const bool acceptance_matches = (accepted == expected_acceptance);
   bool normalized_matches = true;

   if(expected_acceptance)
      normalized_matches = (accepted && TestLotSafetyVolumesEqual(result.normalized_volume, expected_normalized_volume));
   else
      normalized_matches = TestLotSafetyVolumesEqual(result.normalized_volume, expected_normalized_volume);

   const bool test_passed = (acceptance_matches && normalized_matches);
   RecordLotSafetyTestResult(label, test_passed, total_tests, passed_tests, failed_tests);

   PrintFormat("LotSafety synthetic test [%s] min=%.12f max=%.12f step=%.12f requested=%.12f actual=%s expected=%s actual_normalized=%.12f expected_normalized=%.12f test=%s reason=%s",
               label,
               volume_min,
               volume_max,
               volume_step,
               requested_volume,
               (accepted ? "ACCEPTED" : "REJECTED"),
               (expected_acceptance ? "ACCEPTED" : "REJECTED"),
               result.normalized_volume,
               expected_normalized_volume,
               (test_passed ? "TEST PASS" : "TEST FAIL"),
               result.reason);
}

void RunSyntheticLotSafetyTests(int &total_tests,
                                int &passed_tests,
                                int &failed_tests)
{
   Print("LotSafety synthetic tests use explicit hard-coded expected normalized volumes.");

   RunSyntheticLotSafetyCase("0.01 step between steps", 0.01, 100.00, 0.01, 0.037, true, 0.03, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("0.10 step between steps", 0.10, 5.00, 0.10, 0.37, true, 0.30, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("0.25 step between steps", 0.25, 10.00, 0.25, 1.12, true, 1.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("0.001 step between steps", 0.001, 2.000, 0.001, 0.1234, true, 0.123, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("exact minimum", 0.10, 1.00, 0.10, 0.10, true, 0.10, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("between valid steps", 0.10, 1.00, 0.10, 0.19, true, 0.10, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("exact maximum", 0.10, 1.00, 0.10, 1.00, true, 1.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("below minimum", 0.10, 1.00, 0.10, 0.09, false, 0.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("above maximum", 0.10, 1.00, 0.10, 1.01, false, 0.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("zero step", 0.10, 1.00, 0.00, 0.50, false, 0.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("negative step", 0.10, 1.00, -0.10, 0.50, false, 0.00, total_tests, passed_tests, failed_tests);
   RunSyntheticLotSafetyCase("minimum greater than maximum", 2.00, 1.00, 0.10, 1.50, false, 0.00, total_tests, passed_tests, failed_tests);
}

void OnStart()
{
   const string symbol = _Symbol;

   double volume_min = 0.0;
   double volume_max = 0.0;
   double volume_step = 0.0;
   string reason = "";
   int total_tests = 0;
   int passed_tests = 0;
   int failed_tests = 0;

   PrintFormat("LotSafety diagnostic tests for current chart symbol: %s", symbol);
   Print("This script prints diagnostics only and does not place, modify, or close orders.");

   if(!LotSafetyGetSymbolSpecs(symbol, volume_min, volume_max, volume_step, reason))
   {
      PrintFormat("LotSafety test setup failed: %s", reason);
      return;
   }

   PrintFormat("Symbol volume specifications: SYMBOL_VOLUME_MIN=%.12f SYMBOL_VOLUME_MAX=%.12f SYMBOL_VOLUME_STEP=%.12f tolerance=%.12e",
               volume_min,
               volume_max,
               volume_step,
               LOT_SAFETY_EPSILON);

   RunSymbolLotSafetyCase("negative", symbol, -volume_step, false, false, 0.0, total_tests, passed_tests, failed_tests);
   RunSymbolLotSafetyCase("zero", symbol, 0.0, false, false, 0.0, total_tests, passed_tests, failed_tests);
   RunSymbolLotSafetyCase("below minimum", symbol, volume_min * 0.5, false, false, 0.0, total_tests, passed_tests, failed_tests);
   RunSymbolLotSafetyCase("exact minimum", symbol, volume_min, true, true, volume_min, total_tests, passed_tests, failed_tests);

   if(volume_min + (volume_step * 0.5) <= volume_max)
      RunSymbolNormalizedInvariantCase("above minimum partial step", symbol, volume_min + (volume_step * 0.5), volume_min, volume_max, total_tests, passed_tests, failed_tests);

   if(volume_min + volume_step <= volume_max)
      RunSymbolLotSafetyCase("one full step above minimum", symbol, volume_min + volume_step, true, true, volume_min + volume_step, total_tests, passed_tests, failed_tests);

   if(volume_min + (volume_step * 1.5) <= volume_max)
      RunSymbolNormalizedInvariantCase("one and a half steps above minimum", symbol, volume_min + (volume_step * 1.5), volume_min, volume_max, total_tests, passed_tests, failed_tests);

   if(volume_max > volume_min + volume_step)
   {
      RunSymbolNormalizedInvariantCase("below maximum partial step", symbol, volume_max - (volume_step * 0.5), volume_min, volume_max, total_tests, passed_tests, failed_tests);
      RunSymbolLotSafetyCase("one step below maximum", symbol, volume_max - volume_step, true, true, volume_max - volume_step, total_tests, passed_tests, failed_tests);
   }

   RunSymbolLotSafetyCase("exact maximum", symbol, volume_max, true, true, volume_max, total_tests, passed_tests, failed_tests);
   RunSymbolLotSafetyCase("above maximum", symbol, volume_max + volume_step, false, false, 0.0, total_tests, passed_tests, failed_tests);

   RunSyntheticLotSafetyTests(total_tests, passed_tests, failed_tests);

   PrintFormat("LotSafety test summary: total=%d passed=%d failed=%d", total_tests, passed_tests, failed_tests);
}
