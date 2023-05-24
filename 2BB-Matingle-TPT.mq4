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



//---
#include "inc/main.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---



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
