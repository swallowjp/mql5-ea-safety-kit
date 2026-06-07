#property script_show_inputs
#property strict

#include <LotSafety.mqh>

// TestLotSafety.mq5
// Diagnostic script for LotSafety.mqh.
// Uses only the current chart symbol (_Symbol), prints boundary-case results,
// and does not place, modify, or close any real or simulated order.

bool TestLotSafetyVolumesEqual(const double actual_volume, const double expected_volume)
{
   return MathAbs(actual_volume - expected_volume) <= LOT_SAFETY_EPSILON;
}

double TestExpectedDownwardNormalizedVolume(const double requested_volume,
                                           const double volume_min,
                                           const double volume_step)
{
   double expected_volume = volume_min;
   const double distance_from_min = requested_volume - volume_min;

   if(distance_from_min > LOT_SAFETY_EPSILON)
   {
      const double step_count = MathFloor((distance_from_min / volume_step) + LOT_SAFETY_EPSILON);
      expected_volume = volume_min + (step_count * volume_step);
   }

   expected_volume = NormalizeDouble(expected_volume, LotSafetyVolumeDigits(volume_step));

   if(expected_volume > requested_volume + LOT_SAFETY_EPSILON)
      expected_volume = NormalizeDouble(expected_volume - volume_step, LotSafetyVolumeDigits(volume_step));

   return expected_volume;
}

void RunLotSafetyCase(const string label,
                      const string symbol,
                      const double requested_volume,
                      const bool expected_acceptance,
                      const double expected_normalized_volume,
                      int &total_tests,
                      int &passed_tests,
                      int &failed_tests)
{
   LotSafetyResult result;
   const bool accepted = LotSafetyNormalizeVolume(symbol, requested_volume, result);
   const bool acceptance_matches = (accepted == expected_acceptance);
   bool normalized_matches = true;

   if(expected_acceptance)
      normalized_matches = (accepted && TestLotSafetyVolumesEqual(result.normalized_volume, expected_normalized_volume));

   const bool test_passed = (acceptance_matches && normalized_matches);

   total_tests++;
   if(test_passed)
      passed_tests++;
   else
      failed_tests++;

   PrintFormat("LotSafety test [%s] requested=%.12f actual=%s expected=%s actual_normalized=%.12f expected_normalized=%s test=%s reason=%s",
               label,
               requested_volume,
               (accepted ? "ACCEPTED" : "REJECTED"),
               (expected_acceptance ? "ACCEPTED" : "REJECTED"),
               result.normalized_volume,
               (expected_acceptance ? DoubleToString(expected_normalized_volume, 12) : "n/a"),
               (test_passed ? "TEST PASS" : "TEST FAIL"),
               result.reason);
}

void RunAcceptedLotSafetyCase(const string label,
                              const string symbol,
                              const double requested_volume,
                              const double volume_min,
                              const double volume_step,
                              int &total_tests,
                              int &passed_tests,
                              int &failed_tests)
{
   const double expected_normalized_volume = TestExpectedDownwardNormalizedVolume(requested_volume,
                                                                                 volume_min,
                                                                                 volume_step);
   RunLotSafetyCase(label,
                    symbol,
                    requested_volume,
                    true,
                    expected_normalized_volume,
                    total_tests,
                    passed_tests,
                    failed_tests);
}

void RunRejectedLotSafetyCase(const string label,
                              const string symbol,
                              const double requested_volume,
                              int &total_tests,
                              int &passed_tests,
                              int &failed_tests)
{
   RunLotSafetyCase(label,
                    symbol,
                    requested_volume,
                    false,
                    0.0,
                    total_tests,
                    passed_tests,
                    failed_tests);
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

   RunRejectedLotSafetyCase("negative", symbol, -volume_step, total_tests, passed_tests, failed_tests);
   RunRejectedLotSafetyCase("zero", symbol, 0.0, total_tests, passed_tests, failed_tests);
   RunRejectedLotSafetyCase("below minimum", symbol, volume_min * 0.5, total_tests, passed_tests, failed_tests);
   RunAcceptedLotSafetyCase("exact minimum", symbol, volume_min, volume_min, volume_step, total_tests, passed_tests, failed_tests);

   if(volume_min + (volume_step * 0.5) <= volume_max)
      RunAcceptedLotSafetyCase("above minimum partial step", symbol, volume_min + (volume_step * 0.5), volume_min, volume_step, total_tests, passed_tests, failed_tests);

   if(volume_min + volume_step <= volume_max)
      RunAcceptedLotSafetyCase("one full step above minimum", symbol, volume_min + volume_step, volume_min, volume_step, total_tests, passed_tests, failed_tests);

   if(volume_min + (volume_step * 1.5) <= volume_max)
      RunAcceptedLotSafetyCase("one and a half steps above minimum", symbol, volume_min + (volume_step * 1.5), volume_min, volume_step, total_tests, passed_tests, failed_tests);

   if(volume_max > volume_min + volume_step)
   {
      RunAcceptedLotSafetyCase("below maximum partial step", symbol, volume_max - (volume_step * 0.5), volume_min, volume_step, total_tests, passed_tests, failed_tests);
      RunAcceptedLotSafetyCase("one step below maximum", symbol, volume_max - volume_step, volume_min, volume_step, total_tests, passed_tests, failed_tests);
   }

   RunAcceptedLotSafetyCase("exact maximum", symbol, volume_max, volume_min, volume_step, total_tests, passed_tests, failed_tests);
   RunRejectedLotSafetyCase("above maximum", symbol, volume_max + volume_step, total_tests, passed_tests, failed_tests);

   PrintFormat("LotSafety test summary: total=%d passed=%d failed=%d", total_tests, passed_tests, failed_tests);
}
