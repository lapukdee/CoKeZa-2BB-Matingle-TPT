//+------------------------------------------------------------------+
//|                                             2BB-Matingle-TPT.mq4 |
//|                               Copyright 2023, Thongeax Studio TH |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Thongeax Studio TH"
#property link      "https://www.facebook.com/lapukdee/"
#property version   "1.00"
#property strict

#include "inc/main.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   if(BBand_getValue(20)) {
      int res = ArrayCopy(BBand_A, BBand_getValue_Result);
      Print(__LINE__, "# BBand_getValue(A): ", res);
   }
   Print(__LINE__, "# ", "BBand_getValue(A,MODE_LOWER): ", BBand_A[0][MODE_LOWER]);
   Print(__LINE__, "# ", "BBand_getValue(A,MODE_UPPER): ", BBand_A[0][MODE_UPPER]);
   Print(__LINE__, "# ", "BBand_getValue(A,MODE_MAIN): ",  BBand_A[0][MODE_MAIN]);

   //---

   if(BBand_getValue(30)) {
      int res = ArrayCopy(BBand_B, BBand_getValue_Result);
      Print(__LINE__, "# BBand_getValue(B): ", res);
   }
   Print(__LINE__, "# ", "BBand_getValue(B,MODE_LOWER): ", BBand_B[0][MODE_LOWER]);
   Print(__LINE__, "# ", "BBand_getValue(B,MODE_UPPER): ", BBand_B[0][MODE_UPPER]);
   Print(__LINE__, "# ", "BBand_getValue(B,MODE_MAIN): ",  BBand_B[0][MODE_MAIN]);

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
