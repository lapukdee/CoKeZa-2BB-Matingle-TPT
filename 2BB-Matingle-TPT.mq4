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
extern   string            exEAname       =  "v" + string(ea_version);   //# 2BB-Matingle-TPT
extern   string            exSetting      =  " --------------- Setting --------------- ";   // --------------------------------------------------
extern   int               exMagicnumber  =  2852023;                //• Magicnumber

extern   string            exBB        = " --------------- BBand Signal --------------- ";   // --------------------------------------------------

extern   ENUM_TIMEFRAMES   exBB_TF              = PERIOD_H1;            //• Magicnumber
extern   int               exBB_A_Period        = 20;                   //• A - Period
extern   int               exBB_B_Period        = 30;                   //• B - Period
extern   int               exBB_Applied_price   = PRICE_CLOSE;          //• Applied price
extern   double            exBB_Deviation       = 2;                    //• Standard Deviations
extern   int               exBB_BandsShift      = 0;                    //• Bands Shift

extern   string            exOrder        = " --------------- Martingale --------------- ";   // --------------------------------------------------
extern   double            exOrder_LotStart        = 0.01;  //• Lot - Start
extern   double            exOrder_LotMulti        = 2;     //• Lot - Multi
extern   int               exOrder_InDistancePoint = 300;   //• Distance of Order New (Point)

extern   string            exProfit       = " --------------- Profit --------------- ";   // --------------------------------------------------
extern   int               exProfit_Tail  =  150;  //• Tailing (Point)
extern   int               exProfit_Start =  200;  //• Start (Point)
extern   int               exProfit_Step  =  25;   //• Step (Point)
//---
#include "inc/main.mqh"
#include "inc/CPort.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   {
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
   }
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
struct sPortHold {
   int               OP;
   int               Cnt;
   double            Value;

   bool              PortIsHave_TP;
   double            PortSL_Price;

   void              Clear()
   {
      OP = -1;
      Cnt = -1;
      Value = -1;

      PortIsHave_TP = false;
      PortSL_Price = -1;
   }
};
sPortHold   PortHold = {-1, -1, -1, false, -1};
//
struct sTP_MM {
   double            Tail_Price;
   void              Clear()
   {
      Tail_Price = -1;
   }
};
sTP_MM TP_MM = {-1};
//+-----------------,-------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   Port.Calculator();

//---

   if(IsNewBar()) {

      if(Port.cnt_All == 0) {

         BBand_EventBreak();
         Print(__FUNCSIG__, __LINE__, "#");

         if(Chart.EventBreak_R != -1) {

            /* SendOrder */
            OrderSend_Active(Chart.EventBreak_R, 0);

         }

      }

   } else {

      PortHold.Clear();

      if(Port.cnt_Buy > 0) {
         PortHold.OP             = OP_BUY;
         PortHold.Cnt            = Port.cnt_Buy;
         PortHold.Value          = Port.sumHold_Buy;

         PortHold.PortIsHave_TP  = Port.PortIsHaveTP_Buy.IsResult;
         PortHold.PortSL_Price   = Port.PortIsHaveTP_Buy.Price;

      }
      if(Port.cnt_Sel > 0) {
         PortHold.OP             = OP_SELL;
         PortHold.Cnt            = Port.cnt_Sel;
         PortHold.Value          = Port.sumHold_Sel;

         PortHold.PortIsHave_TP  = Port.PortIsHaveTP_Sell.IsResult;
         PortHold.PortSL_Price   = Port.PortIsHaveTP_Sell.Price;

      }
      //
      if(PortHold.OP != -1) {
         /* Detect Distance */
         Print(__FUNCSIG__, __LINE__, "#");

         if(PortHold.Value < 0) {
            //--- Port Negtive
            Print(__FUNCSIG__, __LINE__, "# ", "Port Negtive");

            bool  IsDetectDistance = Port.Point_Distance <= exOrder_InDistancePoint_Get(PortHold.Cnt);

            if(IsDetectDistance) {

               if(OrderSend_Active(PortHold.OP, PortHold.Cnt)) {
                  OrderModifys_SL(PortHold.OP);
               }

            }

         } else {
            //--- Port Positive
            Print(__FUNCSIG__, __LINE__, "# ", "Port Positive");

            /* ##Thongeak ##TPtailing */

            /* Detect TakeProfit */

            /* if Order Avg is + action same SL by Start Sl Price at Cap Price
               Funtion Modufy Group
            */
            Print(__FUNCSIG__, __LINE__, "# ", "PortHold.PortIsHave_TP: ", PortHold.PortIsHave_TP);

            if(PortHold.PortIsHave_TP) {
               int   Distance = -1;
               Print(__FUNCSIG__, __LINE__, "# ", "PortHold.OP: ", PortHold.OP);
               if(PortHold.OP == OP_BUY) {

                  Distance = int((Bid - PortHold.PortSL_Price) / Point); //Buy
                  Print(__FUNCSIG__, __LINE__, "# ", "Distance: ", Distance);
               }
               if(PortHold.OP == OP_SELL) {

                  Distance = int((PortHold.PortSL_Price - Ask) / Point); //Buy
                  Print(__FUNCSIG__, __LINE__, "# ", "Distance: ", Distance);
               }
//---
               int   Distance_Test  =  ( PortHold.Cnt  == 1) ? exProfit_Start : exProfit_Tail + exProfit_Step;
               Print(__FUNCSIG__, __LINE__, "# ", "Distance_Test: ", Distance_Test);

               if(Distance >= Distance_Test) {
                  //--- >> Order Modify Group
                  OrderModifys_SL(PortHold.OP);
               }
            } else {
               OrderModifys_SL(PortHold.OP);
            }


            //------

         }
      }

   }

   string   C = "";
   C += "cnt_All" + ": " + Port.cnt_All + "\n";
   C += "cnt_Buy" + ": " + Port.cnt_Buy + "\n";
   C += "cnt_Sel" + ": " + Port.cnt_Sel + "\n";
   C += "\n";

   C += "PortHold.OP" + ": " + PortHold.OP + "\n";
   C += "PortHold.Cnt" + ": " + PortHold.Cnt + "\n";
   C += "PortHold.Value" + ": " + PortHold.Value + "\n";

   C += "EventBreak_R" + ": " + Chart.EventBreak_R + "\n";
   C += "EventBreak_A" + ":  " + Chart.EventBreak_A + "\n";
   C += "EventBreak_B" + ":" + Chart.EventBreak_B + "\n";
   C += "\n";

   C += "ActivePoint_TOP" + ": " + Port.ActivePlace_TOP + "\n";
   C += "ActivePoint_BOT" + ": " + Port.ActivePlace_BOT + "\n";

   C += "ActivePoint_TOP" + ": " + Port.ActivePoint_TOP + "\n";
   C += "ActivePoint_BOT" + ": " + Port.ActivePoint_BOT + "\n";
   C += "Point_Distance" + ": " + Port.Point_Distance + "\n";

   C += "\n";


   Comment(C);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
