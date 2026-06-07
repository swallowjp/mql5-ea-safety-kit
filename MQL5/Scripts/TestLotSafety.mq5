#property script_show_inputs
#property strict

#include <LotSafety.mqh>

// TestLotSafety.mq5
// Diagnostic script for LotSafety.mqh.
// Uses only the current chart symbol (_Symbol), prints boundary-case results,
// and does not place, modify, or close any real or simulated order.

void PrintLotSafetyCase(const string label, const string symbol, const double requested_volume)
{
   LotSafetyResult result;
   const bool ok = LotSafetyNormalizeVolume(symbol, requested_volume, result);

   PrintFormat("LotSafety test [%s] symbol=%s requested=%.12f normalized=%.12f result=%s reason=%s",
               label,
               symbol,
               requested_volume,
               result.normalized_volume,
               (ok ? "PASS" : "FAIL"),
               result.reason);
}

void OnStart()
{
   const string symbol = _Symbol;

   double volume_min = 0.0;
   double volume_max = 0.0;
   double volume_step = 0.0;
   string reason = "";

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

   PrintLotSafetyCase("negative", symbol, -volume_step);
   PrintLotSafetyCase("zero", symbol, 0.0);
   PrintLotSafetyCase("below minimum", symbol, volume_min * 0.5);
   PrintLotSafetyCase("exact minimum", symbol, volume_min);

   if(volume_min + (volume_step * 0.5) <= volume_max)
      PrintLotSafetyCase("above minimum partial step", symbol, volume_min + (volume_step * 0.5));

   if(volume_min + volume_step <= volume_max)
      PrintLotSafetyCase("one full step above minimum", symbol, volume_min + volume_step);

   if(volume_min + (volume_step * 1.5) <= volume_max)
      PrintLotSafetyCase("one and a half steps above minimum", symbol, volume_min + (volume_step * 1.5));

   if(volume_max > volume_min + volume_step)
   {
      PrintLotSafetyCase("below maximum partial step", symbol, volume_max - (volume_step * 0.5));
      PrintLotSafetyCase("one step below maximum", symbol, volume_max - volume_step);
   }

   PrintLotSafetyCase("exact maximum", symbol, volume_max);
   PrintLotSafetyCase("above maximum", symbol, volume_max + volume_step);
}
