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
   ENUM_TIMEFRAMES   timeframe   = exBB_TF;      // timeframe




   int          shift = Global.RoomFocus;           // shift

   BBand_getValue_Result[0][MODE_MAIN]  = iBands(symbol, timeframe, vPeriod_, exBB_Deviation, exBB_BandsShift, exBB_Applied_price, MODE_MAIN, shift);
   BBand_getValue_Result[0][MODE_UPPER] = iBands(symbol, timeframe, vPeriod_, exBB_Deviation, exBB_BandsShift, exBB_Applied_price, MODE_UPPER, shift);
   BBand_getValue_Result[0][MODE_LOWER] = iBands(symbol, timeframe, vPeriod_, exBB_Deviation, exBB_BandsShift, exBB_Applied_price, MODE_LOWER, shift);


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
            bool IsStand_A = true;

            if(IsStand_A) {
               Print(__LINE__, "# ");
               if(_Close > BBand_A[0][MODE_UPPER] && __Open > BBand_A[0][MODE_MAIN]) {
                  Chart.EventBreak_A = OP_SELL;
                  Print(__LINE__, "# ");
               }
               if(_Close < BBand_A[0][MODE_LOWER] && __Open < BBand_A[0][MODE_MAIN]) {
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
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderModifys_Profit(int  OP, int  cnt)
{
   if(!exProfit_TP) {
      return   exProfit_TP;
   }
   Print(__FUNCSIG__, __LINE__, "# ", "OP: ", OP);
   Print(__FUNCSIG__, __LINE__, "# ", "cnt: ", cnt);
   double   __TP_New = -1;

   double   _Profit_TP_Point = double(exProfit_TP_Point);
   if(eaIsTP_DivByCnt) {
      double   Rate = 0.5;
      double   Div = MathPow(Rate, cnt - 1);
      _Profit_TP_Point = double(exProfit_TP_Point) * Div;
   }

   Print(__FUNCSIG__, __LINE__, "# ", "_Profit_TP_Point: ", NormalizeDouble(_Profit_TP_Point, 0));
   {
      if(_Profit_TP_Point <= 0) {
         _Profit_TP_Point = 1;
         Print(__FUNCSIG__, __LINE__, "# ", "_Profit_TP_Point <= 0: ", _Profit_TP_Point);
      }
      _Profit_TP_Point = _Profit_TP_Point * Point;

   }


   if(OP == OP_BUY) {
      __TP_New   = NormalizeDouble(Port.sumProd_Buy + _Profit_TP_Point, Digits);

      if(Port.sumProd_Buy > __TP_New) {
         return   false;
      }
   } else {
      __TP_New   = NormalizeDouble(Port.sumProd_Sel - _Profit_TP_Point, Digits);

      if(Port.sumProd_Sel < __TP_New) {
         return   false;
      }
   }

   Print(__FUNCSIG__, __LINE__, "# ", "__TP_New: ", __TP_New);
   Draw_HLine(OP_BUY, __TP_New, clrLime, "__TP_New");
   //---

   int   __OrdersTotal   =  OrdersTotal();
   for(int icnt = 0; icnt < __OrdersTotal; icnt++) {

      if(OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == exMagicnumber &&
         OrderType() == OP) {

         double   OrderTakeProfit_ = OrderTakeProfit();

         if(OrderTakeProfit_ != __TP_New) {

            int      OrderTicket_   = OrderTicket();
            double   OrderStopLoss_ = OrderStopLoss();

            bool res = OrderModify(OrderTicket_, OrderOpenPrice(), OrderStopLoss_, __TP_New, 0);
            if(!res) {
               Print(__FUNCSIG__, __LINE__, "#" + "@", OrderTicket_, " Error in OrderModify. Error code=", GetLastError());
               return   false;
            } else
               Print(__FUNCSIG__, __LINE__, "#" + "@", OrderTicket_, " Order modified successfully.");
         }

      }
   }

   return   true;
}
//+------------------------------------------------------------------+
