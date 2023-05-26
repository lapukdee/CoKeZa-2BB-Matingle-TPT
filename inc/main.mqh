//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
struct sGlobal {
   int   RoomFocus;
};
sGlobal   Global = {1};

struct sChart {
   int   EventBreak_R;
   int   EventBreak_A;
   int   EventBreak_B;
};
sChart Chart = {-1, -1, -1};
//+------------------------------------------------------------------+
//|                                                                  |
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
int   BBand_EventBreak()
{
   if(BBand_getValue(exBB_A_Period)) {
      int res = ArrayCopy(BBand_A, BBand_getValue_Result);
      Print(__LINE__, "# BBand_getValue(A): ", exBB_A_Period);
      Print(__LINE__, "# ", "BBand_getValue(A,MODE_LOWER): ", BBand_A[0][MODE_LOWER]);
      Print(__LINE__, "# ", "BBand_getValue(A,MODE_UPPER): ", BBand_A[0][MODE_UPPER]);
      Print(__LINE__, "# ", "BBand_getValue(A,MODE_MAIN): ",  BBand_A[0][MODE_MAIN]);
   }

   if(BBand_getValue(exBB_B_Period)) {
      int res = ArrayCopy(BBand_B, BBand_getValue_Result);
      Print(__LINE__, "# BBand_getValue(B): ", exBB_B_Period);
      Print(__LINE__, "# ", "BBand_getValue(B,MODE_LOWER): ", BBand_B[0][MODE_LOWER]);
      Print(__LINE__, "# ", "BBand_getValue(B,MODE_UPPER): ", BBand_B[0][MODE_UPPER]);
      Print(__LINE__, "# ", "BBand_getValue(B,MODE_MAIN): ",  BBand_B[0][MODE_MAIN]);
   }
   //---
   {
      double _Close = NormalizeDouble(iClose(NULL, exBB_TF, Global.RoomFocus), Digits);
      double __Open = NormalizeDouble(iOpen(NULL, exBB_TF, Global.RoomFocus), Digits);
      Print(__LINE__, "# ", "_Close: ",  _Close);
      Print(__LINE__, "# ", "__Open: ",  __Open);

      Chart.EventBreak_R = -1;
      Chart.EventBreak_A = -1;
      Chart.EventBreak_B = -1;

      {
         {
            bool IsStand_A = __Open < BBand_A[0][MODE_UPPER] && __Open > BBand_A[0][MODE_LOWER];

            if(IsStand_A) {
               Print(__LINE__, "# ");
               if(_Close > BBand_A[0][MODE_UPPER]) {
                  Chart.EventBreak_A = OP_SELL;
                  Print(__LINE__, "# ");
               }
               if(_Close < BBand_A[0][MODE_LOWER]) {
                  Chart.EventBreak_A = OP_BUY;
                  Print(__LINE__, "# ");
               }
            }
            Print(__LINE__, "# ", "Chart.EventBreak_A:* ",  Chart.EventBreak_A);
         }
         {
            bool IsStand_B = __Open < BBand_B[0][MODE_UPPER] && __Open > BBand_B[0][MODE_LOWER];

            if(IsStand_B) {
               Print(__LINE__, "# ");
               if(_Close > BBand_B[0][MODE_UPPER]) {
                  Chart.EventBreak_B = OP_SELL;
                  Print(__LINE__, "# ");
               }
               if(_Close < BBand_B[0][MODE_LOWER]) {
                  Chart.EventBreak_B = OP_BUY;
                  Print(__LINE__, "# ");
               }
            }
            Print(__LINE__, "# ", "Chart.EventBreak_B:* ",  Chart.EventBreak_B);
         }

      }

   }
   {
      if(Chart.EventBreak_A != -1 &&
         Chart.EventBreak_A == Chart.EventBreak_B) {
         Chart.EventBreak_R = Chart.EventBreak_A;
      }
      Print("*");
      Print(__LINE__, "# ", "Chart.EventBreak_R:* ",  Chart.EventBreak_R);
   }

   return Chart.EventBreak_R;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   cIsNewBar_Save = -1;
bool              IsNewBar()
{
   int getBar = iBars(NULL, exBB_TF);

   if(cIsNewBar_Save != getBar) {

      if(cIsNewBar_Save == -1) {
         cIsNewBar_Save = getBar;
         return   false;
      }
   
      cIsNewBar_Save = getBar;
      if(cIsNewBar_Save != -1)
         return   true;

   }

   return   false;
}
//+------------------------------------------------------------------+
