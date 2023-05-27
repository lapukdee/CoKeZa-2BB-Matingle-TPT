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
extern   double            exOrder_LotStart        = 0.01;           //• Lot - Start
extern   double            exOrder_LotMulti        = 2;              //• Lot - Multi
extern   int               exOrder_InDistancePoint = 300;           //• Distance of Order New (Point)

extern   string            exProfit       = " --------------- Profit --------------- ";   // --------------------------------------------------
extern   int               exProfit_Tail  =  50;
extern   int               exProfit_Start =  50;
extern   int               exProfit_Step  =  10;
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
struct sPortHold {
   int               OP;
   int               Cnt;
   double            Value;

   bool              PortIsHave_TP;
   double            PortSL_Price;
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

      } else {
         Print(__FUNCSIG__, __LINE__, "#");

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

               bool  IsDetectDistance = Port.Point_Distance >= exOrder_InDistancePoint;

               if(IsDetectDistance) {

                  OrderSend_Active(PortHold.OP, PortHold.Cnt);

               }

            } else {
               //--- Port Positive
               Print(__FUNCSIG__, __LINE__, "# ", "Port Positive");

               /* ##Thongeak ##TPtailing */

               /* Detect TakeProfit */

               /* if Order Avg is + action same SL by Start Sl Price at Cap Price
                  Funtion Modufy Group
               */
               if(PortHold.PortIsHave_TP) {

                  if(PortHold.OP == OP_BUY) {

                     int   Distance = int((Bid - PortHold.PortSL_Price) / Point); //Buy

                     if(Distance >= exProfit_Tail + exProfit_Step) {
                        //--- >> Order Modify Group
                     }

                  }
                  if(PortHold.OP == OP_SELL) {

                     int   Distance = int((PortHold.PortSL_Price - Ask) / Point); //Buy

                     if(Distance >= exProfit_Tail + exProfit_Step) {
                        //--- >> Order Modify Group
                     }

                  }

               } else {

               }


               //------

            }
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
