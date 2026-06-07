#ifndef LOT_SAFETY_MQH
#define LOT_SAFETY_MQH

// LotSafety.mqh
// Symbol-aware lot validation and conservative downward normalization for MQL5.
//
// Scope and assumptions:
// - Unit: lots for the requested trading symbol.
// - Account currency: not used by this module; no currency conversion is performed.
// - Reference equity/balance/time basis: not used by this module; no risk percentage
//   or account-value calculation is performed.
// - Rounding method: volumes are snapped downward to SYMBOL_VOLUME_STEP increments
//   anchored at SYMBOL_VOLUME_MIN. The function never intentionally rounds upward.
// - Floating-point tolerance: LOT_SAFETY_EPSILON is used only to avoid rejecting
//   values that differ from symbol limits by insignificant binary representation noise.
// - Trading behavior: this module does not place, modify, or close orders.

#define LOT_SAFETY_EPSILON 1.0e-12
#define LOT_SAFETY_MAX_VOLUME_DIGITS 8

struct LotSafetyResult
{
   bool   ok;
   string symbol;
   double requested_volume;
   double normalized_volume;
   double volume_min;
   double volume_max;
   double volume_step;
   string reason;
};

bool LotSafetyIsFinite(const double value)
{
   return MathIsValidNumber(value);
}

int LotSafetyVolumeDigits(const double volume_step)
{
   if(!LotSafetyIsFinite(volume_step) || volume_step <= 0.0)
      return LOT_SAFETY_MAX_VOLUME_DIGITS;

   double step = volume_step;
   for(int digits = 0; digits <= LOT_SAFETY_MAX_VOLUME_DIGITS; digits++)
   {
      const double rounded = NormalizeDouble(step, 0);
      if(MathAbs(step - rounded) <= LOT_SAFETY_EPSILON)
         return digits;
      step *= 10.0;
   }

   return LOT_SAFETY_MAX_VOLUME_DIGITS;
}

void LotSafetySetFailure(LotSafetyResult &result,
                         const string reason,
                         const double normalized_volume = 0.0)
{
   result.ok = false;
   result.normalized_volume = normalized_volume;
   result.reason = reason;
}

bool LotSafetyGetSymbolSpecs(const string symbol,
                             double &volume_min,
                             double &volume_max,
                             double &volume_step,
                             string &reason)
{
   volume_min = 0.0;
   volume_max = 0.0;
   volume_step = 0.0;

   if(symbol == "")
   {
      reason = "Symbol name is empty; volume specifications were not requested.";
      return false;
   }

   if(!SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN, volume_min))
   {
      reason = "Could not retrieve SYMBOL_VOLUME_MIN for symbol " + symbol + ".";
      return false;
   }

   if(!SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX, volume_max))
   {
      reason = "Could not retrieve SYMBOL_VOLUME_MAX for symbol " + symbol + ".";
      return false;
   }

   if(!SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP, volume_step))
   {
      reason = "Could not retrieve SYMBOL_VOLUME_STEP for symbol " + symbol + ".";
      return false;
   }

   if(!LotSafetyIsFinite(volume_min) || !LotSafetyIsFinite(volume_max) || !LotSafetyIsFinite(volume_step))
   {
      reason = "Symbol volume specifications contain a non-finite value for symbol " + symbol + ".";
      return false;
   }

   if(volume_min <= 0.0)
   {
      reason = "SYMBOL_VOLUME_MIN must be positive for symbol " + symbol + ".";
      return false;
   }

   if(volume_max <= 0.0)
   {
      reason = "SYMBOL_VOLUME_MAX must be positive for symbol " + symbol + ".";
      return false;
   }

   if(volume_step <= 0.0)
   {
      reason = "SYMBOL_VOLUME_STEP must be positive for symbol " + symbol + ".";
      return false;
   }

   if(volume_min > volume_max + LOT_SAFETY_EPSILON)
   {
      reason = "Symbol volume specifications are inconsistent: minimum volume is greater than maximum volume for symbol " + symbol + ".";
      return false;
   }

   return true;
}

bool LotSafetyNormalizeVolume(const string symbol,
                              const double requested_volume,
                              LotSafetyResult &result)
{
   result.ok = false;
   result.symbol = symbol;
   result.requested_volume = requested_volume;
   result.normalized_volume = 0.0;
   result.volume_min = 0.0;
   result.volume_max = 0.0;
   result.volume_step = 0.0;
   result.reason = "Validation has not run.";

   if(!LotSafetyIsFinite(requested_volume))
   {
      LotSafetySetFailure(result, "Requested volume is non-finite; refusing to normalize lot size.");
      return false;
   }

   if(requested_volume <= 0.0)
   {
      LotSafetySetFailure(result, "Requested volume must be greater than zero; refusing zero or negative lot size.");
      return false;
   }

   string specs_reason = "";
   if(!LotSafetyGetSymbolSpecs(symbol, result.volume_min, result.volume_max, result.volume_step, specs_reason))
   {
      LotSafetySetFailure(result, specs_reason);
      return false;
   }

   if(requested_volume < result.volume_min - LOT_SAFETY_EPSILON)
   {
      LotSafetySetFailure(result,
                          "Requested volume is below SYMBOL_VOLUME_MIN; refusing to increase lot size silently.");
      return false;
   }

   if(requested_volume > result.volume_max + LOT_SAFETY_EPSILON)
   {
      LotSafetySetFailure(result, "Requested volume is above SYMBOL_VOLUME_MAX; refusing lot size.");
      return false;
   }

   double normalized = result.volume_min;
   const double distance_from_min = requested_volume - result.volume_min;

   if(distance_from_min > LOT_SAFETY_EPSILON)
   {
      const double step_count = MathFloor((distance_from_min / result.volume_step) + LOT_SAFETY_EPSILON);
      normalized = result.volume_min + (step_count * result.volume_step);
   }

   const int digits = LotSafetyVolumeDigits(result.volume_step);
   normalized = NormalizeDouble(normalized, digits);

   // NormalizeDouble can round upward by a tiny amount. If that would increase
   // risk beyond the request outside the explicit tolerance, step down once.
   if(normalized > requested_volume + LOT_SAFETY_EPSILON)
      normalized = NormalizeDouble(normalized - result.volume_step, digits);

   if(normalized < result.volume_min - LOT_SAFETY_EPSILON)
   {
      LotSafetySetFailure(result,
                          "Downward normalization would fall below SYMBOL_VOLUME_MIN; refusing lot size.");
      return false;
   }

   if(normalized > result.volume_max + LOT_SAFETY_EPSILON)
   {
      LotSafetySetFailure(result,
                          "Downward normalization produced a value above SYMBOL_VOLUME_MAX; refusing lot size.");
      return false;
   }

   if(normalized <= 0.0 || !LotSafetyIsFinite(normalized))
   {
      LotSafetySetFailure(result,
                          "Downward normalization produced an invalid volume; refusing lot size.");
      return false;
   }

   result.ok = true;
   result.normalized_volume = normalized;

   if(MathAbs(result.normalized_volume - result.requested_volume) <= LOT_SAFETY_EPSILON)
      result.reason = "Requested volume is valid for the symbol volume limits and step.";
   else
      result.reason = "Requested volume was normalized downward to the permitted symbol volume step without increasing risk.";

   return true;
}

#endif // LOT_SAFETY_MQH
