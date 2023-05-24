//+------------------------------------------------------------------+
//|                                             2BB-Matingle-TPT.mq4 |
//|                               Copyright 2023, Thongeax Studio TH |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Thongeax Studio TH"
#property link      "https://www.facebook.com/lapukdee/"

#define     ea_version     "1.00"
#property   version        ea_version

#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern   string            exEAname       = "v" + string(ea_version);   //# 2BB-Matingle-TPT
extern   string            exOrder        = " --------------- Setting --------------- ";   // --------------------------------------------------
extern   int               exMagicnumber  =  26102022;         //• Magicnumber

extern   ENUM_TIMEFRAMES   exBB_TF  = PERIOD_CURRENT;
extern   int               exBB_A_Period  = 20;
extern   int               exBB_B_Period  = 30;

struct sGlobal {
   int   RoomFocus;
};
sGlobal   Global = {72};

struct sChart {
   int   EventBreak_R;
   int   EventBreak_A;
   int   EventBreak_B;
};
sChart Chart = {-1};

//---
#include "inc/main.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---

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
         if(__Open > BBand_A[0][MODE_MAIN]) {
            Print(__LINE__, "# ");
            if(_Close > BBand_A[0][MODE_UPPER]) {
               Chart.EventBreak_A = OP_SELL;
               Print(__LINE__, "# ");
            }
         }
         if(__Open < BBand_A[0][MODE_MAIN] ) {
            Print(__LINE__, "# ");
            if(_Close < BBand_A[0][MODE_UPPER]) {
               Chart.EventBreak_A = OP_BUY;
               Print(__LINE__, "# ");
            }
         }
         Print(__LINE__, "# ", "Chart.EventBreak_A:* ",  Chart.EventBreak_A);
      }
      {
         if(__Open > BBand_B[0][MODE_MAIN]  ) {
            Print(__LINE__, "# ");
            if(_Close > BBand_B[0][MODE_UPPER]) {
               Chart.EventBreak_B = OP_SELL;
               Print(__LINE__, "# ");
            }
         }
         if(__Open < BBand_B[0][MODE_MAIN]) {
            Print(__LINE__, "# ");
            if(_Close < BBand_B[0][MODE_UPPER]) {
               Chart.EventBreak_B = OP_BUY;
               Print(__LINE__, "# ");
            }
         }
         Print(__LINE__, "# ", "Chart.EventBreak_B:* ",  Chart.EventBreak_B);
      }
   }



//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
