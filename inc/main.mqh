//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
double BBand_A[1][3];
double BBand_B[1][3];

double BBand_getValue_Result[1][3];
/* (0 - MODE_MAIN, 1 - MODE_UPPER, 2 - MODE_LOWER). */

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  BBand_getValue(int vPeriod_)
{
   string            symbol      = NULL;      // symbol
   ENUM_TIMEFRAMES   timeframe   = PERIOD_CURRENT;      // timeframe

   double       deviation = 2;      // standard deviations
   int          bands_shift = 0;    // bands shift
   int          applied_price = PRICE_CLOSE;  // applied price

   int          shift = Global.RoomFocus;           // shift

   BBand_getValue_Result[0][MODE_MAIN]  = iBands(symbol, timeframe, vPeriod_, deviation, bands_shift, applied_price, MODE_MAIN, shift);
   BBand_getValue_Result[0][MODE_UPPER] = iBands(symbol, timeframe, vPeriod_, deviation, bands_shift, applied_price, MODE_UPPER, shift);
   BBand_getValue_Result[0][MODE_LOWER] = iBands(symbol, timeframe, vPeriod_, deviation, bands_shift, applied_price, MODE_LOWER, shift);


   BBand_getValue_Result[0][MODE_MAIN] = NormalizeDouble(BBand_getValue_Result[0][MODE_MAIN], Digits);
   BBand_getValue_Result[0][MODE_UPPER] = NormalizeDouble(BBand_getValue_Result[0][MODE_UPPER], Digits);
   BBand_getValue_Result[0][MODE_LOWER] = NormalizeDouble(BBand_getValue_Result[0][MODE_LOWER], Digits);

   return true;
}
//+------------------------------------------------------------------+
