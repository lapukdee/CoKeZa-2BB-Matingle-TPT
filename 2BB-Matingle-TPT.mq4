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

string   EA_Identity_Short = "2BB";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern   string            exEAname       = "v" + string(ea_version);   //# 2BB-Matingle-TPT
extern   string            exSetting      = " --------------- Setting --------------- ";   // --------------------------------------------------
extern   int               exMagicnumber  =  0;                //• Magicnumber

extern   string            exBB        = " --------------- BBand Signal --------------- ";   // --------------------------------------------------

extern   ENUM_TIMEFRAMES   exBB_TF              = PERIOD_CURRENT;       //• Magicnumber
extern   int               exBB_A_Period        = 20;                   //• A - Period
extern   int               exBB_B_Period        = 30;                   //• B - Period
extern   int               exBB_Applied_price   = PRICE_CLOSE;          //• Applied price
extern   double            exBB_Deviation       = 2;                    //• Standard Deviations
extern   int               exBB_BandsShift      = 0;                    //• Bands Shift

extern   string            exOrder        = " --------------- Martingale --------------- ";   // --------------------------------------------------
extern   double            exOrder_LotStart = 0.01;            //• Lot - Start
extern   double            exOrder_LotMulti = 2;               //• Lot - Multi
extern   int               exOrder_InDistancePoint =  300;     //• Distance of Order New (Point)

//---
#include "inc/main.mqh"
#include "inc/CPort.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---

   BBand_EventBreak();

   Port.Calculator();

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
   Port.Calculator();

   //---

   int Hold_OP = -1, Hold_Cnt = -1;

   //---

   if(IsNewBar()) {
      BBand_EventBreak();

      if(Port.cnt_All == 0) {

         if(Chart.EventBreak_R != -1) {

            /* SendOrder */
            OrderSend_Active(Chart.EventBreak_R, 0);

         }

      } else {

         if(Port.cnt_Buy > 0) {
            Hold_OP  = OP_BUY;
            Hold_Cnt = Port.cnt_Buy;
         }
         if(Port.cnt_Sel > 0) {
            Hold_OP  = OP_SELL;
            Hold_Cnt = Port.cnt_Sel;
         }
         //
         if(Hold_OP != -1) {
            /* Detect Distance */

            bool  IsDetectDistance = Port.Point_Distance >= exOrder_InDistancePoint;

            if(IsDetectDistance) {

               OrderSend_Active(Hold_OP, Hold_Cnt);

            } else {

               /* Detect TakeProfit */

               /* if Order Avg is + action same SL by Start Sl Price at Cap Price
                  Funtion Modufy Group
               */
               Fixme .pls Detect TakeProfit
            }
         }

      }
   }

   string   C = "";
   C += "cnt_All" + ":" + Port.cnt_All + "\n";
   C += "cnt_Buy" + ":" + Port.cnt_Buy + "\n";
   C += "cnt_Sel" + ":" + Port.cnt_Sel + "\n";
   C += "\n";

   C += "EventBreak_R" + ":" + Hold_OP + "\n";

   C += "EventBreak_R" + ":" + Chart.EventBreak_R + "\n";
   C += "EventBreak_A" + ":" + Chart.EventBreak_A + "\n";
   C += "EventBreak_B" + ":" + Chart.EventBreak_B + "\n";
   C += "\n";

   C += "ActivePoint_TOP" + ":" + Port.ActivePlace_TOP + "\n";
   C += "ActivePoint_BOT" + ":" + Port.ActivePlace_BOT + "\n";

   C += "ActivePoint_TOP" + ":" + Port.ActivePoint_TOP + "\n";
   C += "ActivePoint_BOT" + ":" + Port.ActivePoint_BOT + "\n";
   C += "Point_Distance" + ":" + Port.Point_Distance + "\n";

   C += "\n";


   Comment(C);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
