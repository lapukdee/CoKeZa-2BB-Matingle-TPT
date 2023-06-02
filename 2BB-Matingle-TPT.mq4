//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define     eaLOCK_Account ""
/*
   #Example.
   "45843128,80000007"     => allow 2 acc.
   ""                      => Account not locked

*/
#define     eaLOCK_Date    ""
/*
   - Compared to the center time +0
   #Example.
   "31.12.2023"   => Day,Month,Year
   ""             => Unlimited

*/
#include "inc/ProduckLock.mqh"
//+------------------------------------------------------------------+
//|                                             2BB-Matingle-TPT.mq4 |
//|                               Copyright 2023, Thongeax Studio TH |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Thongeax Studio TH"
#property link      "https://www.facebook.com/lapukdee/"

#define     ea_version     "1.4e"
#property   version        ea_version

#property strict

#property   description    "Account Allow : "+eaLOCK_Account
#property   description    "Expire Date : "+eaLOCK_Date

string   EA_Identity_Short = "2BB";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern   string            exEAname       =  "v" + string(ea_version);  //# 2BB-Matingle-TPT
extern   string            exLOCK_Date    =  string(eaLOCK_Date);       //# Lock
extern   string            exSetting      =  " --------------- Setting --------------- "; // --------------------------------------------------
extern   int               exMagicnumber  =  2852023;                //• Magicnumber

extern   string               exBB           =  " --------------- BBand Signal --------------- ";  // --------------------------------------------------

extern   ENUM_TIMEFRAMES      exBB_TF                 = PERIOD_H1;       //• Timeframe
extern   int                  exBB_A_Period           = 20;              //• A - Period
extern   int                  exBB_B_Period           = 30;              //• B - Period
extern   ENUM_APPLIED_PRICE   exBB_Applied_price_A    = PRICE_CLOSE;     //• A - Applied
extern   ENUM_APPLIED_PRICE   exBB_Applied_price_B    = PRICE_CLOSE;     //• B - Applied
extern   double               exBB_Deviation_A        = 2;               //• A - Deviations
extern   double               exBB_Deviation_B        = 2;               //• B - Deviations
extern   int                  exBB_BandsShift         = 0;               //• Bands Shift

extern   string            exOrder        = " --------------- Martingale --------------- ";  // --------------------------------------------------
extern   double            exOrder_LotStart        = 0.01;  //• Lot - Start
extern   double            exOrder_LotMulti        = 2;     //• Lot - Multi
extern   int               exOrder_InDistancePoint = 300;   //• Distance of Order New (Point)

extern   ENUM_TIMEFRAMES   exOrder_InsertTF        = PERIOD_M30;            //• Insert Timeframe

extern   string            exProfit             = " --------------- Profit ---------------  [auto by BB-A]";   // --------------------------------------------------

bool              exProfit_TP          = true;     // --------------- TP ---------------
int      __Profit_TP_Point    = -1;      //• Order TP (Point)

extern   bool              exProfit_Tail           = true;     // --------------- Tailing ---------------
extern   int               exProfit_Tail_Point_P   = 33;      //• Tailing | % : [Order TP (Point)]
extern   int               exProfit_Tail_Start_P   = 66;      //• Start | % : [Order TP (Point)]
extern   int               exProfit_Tail_Step_P    = 33;       //• Step | % : [Order TP (Point)]

//---
#include "inc/main.mqh"
#include "inc/CPort.mqh"
#include "inc/Profit_Tail.mqh"
//---

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern   bool  eaOrder_InsertMode   =  true;    //• eaOrder_InsertMode  #true  |  false: Old (All tick)
extern   bool  eaIsTP_DivByCnt      =  true;    //• eaIsTP_DivByCnt  #false

extern   bool  eaOrder_LotStartByBalance  =  true; //• eaOrder_LotStartByBalance  #false
extern   double               eaCapital   =  50;   //• eaCapital

extern   double   exProfit_TP_PointReduceRate   =  0.5;   //• TP PointReduceRate
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   {
      __Profit_TP_Point = BBand_getBandSize(exBB_TF, exBB_A_Period, exBB_Deviation_A, exBB_Applied_price_A);
      Tailing.SetValue(__Profit_TP_Point);
   }
//---
   {
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
   }

   BBand_EventBreak();

   Port.Calculator();

   OnTick();
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
void  Hold_Mapping()
{
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
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   Port.Calculator();
   {
      Hold_Mapping();
   }
//---

   if(IsNewBar()) {

      if(Port.cnt_All == 0) {

         BBand_EventBreak();
         Print(__FUNCSIG__, __LINE__, "#");

         bool  Checker = ProduckLock.Checker();
         Print(__FUNCSIG__, __LINE__, "# Checker: ", Checker);

         if(Chart.EventBreak_R != -1
            && Checker                    //--- << ** ProduckLock
           ) {

            /* SendOrder */
            if(OrderSend_Active(Chart.EventBreak_R, 0)) {
               Port.Calculator();

               __Profit_TP_Point = BBand_getBandSize(exBB_TF, exBB_A_Period, exBB_Deviation_A, exBB_Applied_price_A);
               //Fiexd TP Point
               OrderModifys_Profit(Chart.EventBreak_R, 1);

            }

         }

      } else {

      }

   }
   if(IsNewBar_Insert()) {

      Print("IsNewBar_Insert()");
      //---    feature/feature_OrderInsert-UseLowHigh
      if(eaOrder_InsertMode) {
         Print("eaOrder_InsertMode");

         if(PortHold.OP != -1  &&
            PortHold.Value < 0) {
            Print("eaOrder_InsertMode@Inside");

            int   Point_Distance = -1;

            if(PortHold.OP == OP_BUY) {
               Point_Distance = int((iLow(NULL, exOrder_InsertTF, 0) - Port.ActivePlace_BOT) / Point); //Buy : Low -  Bot
            } else {
               Point_Distance = int((Port.ActivePlace_TOP - iHigh(NULL, exOrder_InsertTF, 0)) / Point); //Sell : Top - High
            }

            bool  IsDetectDistance =  Point_Distance <= exOrder_InDistancePoint_Get(PortHold.Cnt);
            if(IsDetectDistance) {

               if(OrderSend_Active(PortHold.OP, PortHold.Cnt)) {
                  Port.Calculator();
                  {
                     Hold_Mapping();
                  }
                  {
                     // Fiexd TP Point
                     OrderModifys_Profit(PortHold.OP, PortHold.Cnt);
                  }
                  {
                     OrderModifys_SL(PortHold.OP);
                  }
                  //---


               }

            }
         }
      }
      //---
   } else {

      //
      if(PortHold.OP != -1) {
         /* Detect Distance */
         //Print(__FUNCSIG__, __LINE__, "#");

         if(PortHold.Value < 0) {
            //--- Port Negtive
            if(!eaOrder_InsertMode) {
               Print(__FUNCSIG__, __LINE__, "# ", "Port Negtive");

               bool  IsDetectDistance = Port.Point_Distance <= exOrder_InDistancePoint_Get(PortHold.Cnt);

               if(IsDetectDistance) {

                  if(OrderSend_Active(PortHold.OP, PortHold.Cnt)) {
                     OrderModifys_SL(PortHold.OP);
                  }

               }
            }
            //---
         } else {
            if(exProfit_Tail) {

               //--- Port Positive
               //Print(__FUNCSIG__, __LINE__, "# ", "Port Positive");

               /* ##Thongeak ##TPtailing */

               /* Detect TakeProfit */

               /* if Order Avg is + action same SL by Start Sl Price at Cap Price
                  Funtion Modufy Group
               */
               //Print(__FUNCSIG__, __LINE__, "# ", "PortHold.PortIsHave_TP: ", PortHold.PortIsHave_TP);

               if(PortHold.PortIsHave_TP) {
                  int   Distance = -1;
                  //Print(__FUNCSIG__, __LINE__, "# ", "PortHold.OP: ", PortHold.OP);
                  if(PortHold.OP == OP_BUY) {

                     Distance = int((Bid - PortHold.PortSL_Price) / Point); //Buy
                     //Print(__FUNCSIG__, __LINE__, "# ", "Distance: ", Distance);
                  }
                  if(PortHold.OP == OP_SELL) {

                     Distance = int((PortHold.PortSL_Price - Ask) / Point); //Buy
                     //Print(__FUNCSIG__, __LINE__, "# ", "Distance: ", Distance);
                  }

                  int   Distance_Test  =  ( PortHold.Cnt  == 1) ? Tailing.Tail_Start : Tailing.Tail_Point + Tailing.Tail_Step;
                  //Print(__FUNCSIG__, __LINE__, "# ", "Distance_Test: ", Distance_Test);

                  if(Distance >= Distance_Test) {
                     //--- >> Order Modify Group
                     OrderModifys_SL(PortHold.OP, PortHold.PortSL_Price);
                  }
               } else {
                  OrderModifys_SL(PortHold.OP);
               }
            }

            //------
         }
      }

   }

   string   C = "";

   C += "Produck" + ": " + ProduckLock.Passport() + "\n";

   C += "cnt_All" + ": " + Port.cnt_All + "\n";
   C += "cnt_Buy" + ": " + Port.cnt_Buy + "\n";
   C += "cnt_Sel" + ": " + Port.cnt_Sel + "\n";
   C += "\n";

   C += "Port.OP" + ": " + PortHold.OP + "\n";
   C += "Port.Cnt" + ": " + PortHold.Cnt + "\n";
   C += "Port.Value" + ": " + PortHold.Value + "\n";

   C += "Event_R" + ": " + Chart.EventBreak_R + "\n";
   C += "Event_A" + ":  " + Chart.EventBreak_A + "\n";
   C += "Event_B" + ": " + Chart.EventBreak_B + "\n";
   C += "\n";

   C += "A.PR.TOP" + ": " + Port.ActivePlace_TOP + "\n";
   C += "A.PR.BOT" + ": " + Port.ActivePlace_BOT + "\n";

   C += "A.P.TOP" + ": " + Port.ActivePoint_TOP + "\n";
   C += "A.P.BOT" + ": " + Port.ActivePoint_BOT + "\n";
   C += "Distance" + ": " + Port.Point_Distance + "\n";
   C += "\n";

//C += "Hold.PortSL_Price" + ": " + PortHold.PortSL_Price + "\n";
   C += "__Profit_TP_Point" + ": " + __Profit_TP_Point + "\n";
   C += "BarS_Insert" + ": " + cIsNewBar_Save_Insert + "\n";

   C += "\n";


   Comment(C);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
