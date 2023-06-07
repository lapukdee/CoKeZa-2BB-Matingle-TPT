//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define     eaLOCK_Account ""
/*
   #Example.
   "45843128,80000007"     => allow 2 acc.
   ""                      => Account not locked

*/
#define     eaLOCK_Date    "17.6.2023"
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

#define     ea_version     "1.32"
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
extern   string            exSetting      =  " --------------- Setting --------------- ";   // --------------------------------------------------
extern   int               exMagicnumber  =  2852023;                //• Magicnumber

extern   string            exBB        = " --------------- BB-Band Signal --------------- ";   // --------------------------------------------------

extern   ENUM_TIMEFRAMES      exBB_TF              = PERIOD_H1;            //• Timeframe
extern   int                  exBB_A_Period        = 20;                   //• A - Period
extern   int                  exBB_B_Period        = 30;                   //• B - Period
extern   ENUM_APPLIED_PRICE   exBB_Applied_price   = PRICE_CLOSE;          //• Applied price
extern   double               exBB_Deviation       = 2;                    //• Standard Deviations
extern   int                  exBB_BandsShift      = 0;                    //• Bands Shift

extern   string            exOrder        = " --------------- Martingale --------------- ";   // --------------------------------------------------
extern   double            exOrder_LotStart        = 0.01;  //• Lot - Start
extern   double            exOrder_LotMulti        = 2;     //• Lot - Multi
extern   int               exOrder_InDistancePoint = 300;   //• Distance of Order New (Point)

extern   string            exProfit             = " --------------- Profit --------------- ";   // --------------------------------------------------

extern   bool              exProfit_TP          = true;     // --------------- TP ---------------
extern   int               exProfit_TP_Point    = 300;      //• Order TP (Point)

extern   bool              exProfit_Tail        = true;     // --------------- Tailing ---------------
extern   int               exProfit_Tail_Point  = 200;      //• Tailing (Point)
extern   int               exProfit_Tail_Start  = 250;      //• Start (Point)
extern   int               exProfit_Tail_Step   = 75;       //• Step (Point)

extern   string            exCapital         = " --------------- Capital and Cut --------------- ";   // --------------------------------------------------
extern   double            exCapitalValue    =  1000;   //• Capital

extern   bool              exCapitalIs_SL    =  false;  //• Lose
extern   double            exCapitalPer_SL   =  30;     //• Percent - Lose

extern   bool              exCapitalIs_TP    =  false;   //• Win
extern   double            exCapitalPer_TP   =  10;      //• Percent - Win

//---
#include "inc/main.mqh"
#include "inc/CPort.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  eaOrder_InsertMode   =  true;   ///• eaOrder_InsertMode  #true  |  false: Old (All tick)
bool  eaIsTP_DivByCnt      =  false;    //• eaIsTP_DivByCnt  #false

bool  eaOrder_LotStartByBalance  =  false; //• eaOrder_LotStartByBalance  #false

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   {

      if(exProfit_Tail_Point > exProfit_Tail_Start) {
         Print(__FUNCSIG__, __LINE__, "#", " exProfit_Tail_Point:", exProfit_Tail_Point);
         Print(__FUNCSIG__, __LINE__, "#", " exProfit_Tail_Start:", exProfit_Tail_Start);

         Print(__LINE__, "$$ exProfit_Tail_Point > exProfit_Tail_Start");
         ExpertRemove();
      }

      double   VOLUME_MIN = SymbolInfoDouble(NULL, SYMBOL_VOLUME_MIN);

      if(exOrder_LotStart < VOLUME_MIN) {
         Print(__FUNCSIG__, __LINE__, "#", " VOLUME_MIN:", VOLUME_MIN);
         Print(__FUNCSIG__, __LINE__, "#", " exOrder_LotStart:", exOrder_LotStart);

         Print(__LINE__, "$$ exOrder_LotStart < VOLUME_MIN");
         ExpertRemove();
      }
      //if(exProfit_Tail_Point <= exProfit_Tail_Start) {
      //   ExpertRemove();
      //}
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

   double            PortSL_Price;

   int               State;         // 0: Start/Normal,  1: TialingRuner
   bool              FoceModify;
   //---

   void              Clear()
   {
      OP = -1;
      Cnt = -1;
      Value = -1;

      PortSL_Price   =  false;
      State          =  -1;
      FoceModify     =  false;
   }
};
sPortHold   PortHold;


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

      PortHold.PortSL_Price   =  Port.TPT_Buy.Price_SL;
      PortHold.State          =  Port.TPT_Buy.State;
      PortHold.FoceModify     =  Port.TPT_Buy.FoceModify;

   }
   if(Port.cnt_Sel > 0) {
      PortHold.OP             = OP_SELL;
      PortHold.Cnt            = Port.cnt_Sel;
      PortHold.Value          = Port.sumHold_Sel;

      PortHold.PortSL_Price   =  Port.TPT_Sell.Price_SL;
      PortHold.State          =  Port.TPT_Sell.State;
      PortHold.FoceModify     =  Port.TPT_Sell.FoceModify;

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

         BBand_EventBreak();                 //--- get Signal Module
         Print(__FUNCSIG__, __LINE__, "#");

         bool  Checker = ProduckLock.Checker();
         Print(__FUNCSIG__, __LINE__, "# Checker: ", Checker);

         if(Chart.EventBreak_R != -1
            && Checker                    //--- << ** ProduckLock
           ) {

            /* SendOrder */
            if(OrderSend_Active(Chart.EventBreak_R, 0)) {
               Port.Calculator();

               //Fiexd TP Point
               OrderModifys_Profit(Chart.EventBreak_R, 1);

            }

         }

      } else {
         //---    feature/feature_OrderInsert-UseLowHigh
         if(eaOrder_InsertMode) {

            if(PortHold.OP != -1 && PortHold.Value < 0) {

               int   Point_Distance = -1;

               if(PortHold.OP == OP_BUY) {
                  Point_Distance = int((iLow(NULL, exBB_TF, 1) - Port.ActivePlace_BOT) / Point); //Buy : Low -  Bot
               } else {
                  Point_Distance = int((Port.ActivePlace_TOP - iHigh(NULL, exBB_TF, 1)) / Point); //Sell : Top - High
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
      }

   } else {
      //--- All Tick
      //
      if(PortHold.OP != -1) {
         /* Detect Distance */
         //Print(__FUNCSIG__, __LINE__, "#");

         if(PortHold.Value < 0) {
            //--- Port Negtive

            //---
            bool  Check_exCapitalIs_SL =  false;
            if(exCapitalIs_SL) {
               double   Current  =  (PortHold.Value / exCapitalValue) * 100;
               if(Current <= -exCapitalPer_SL) {

                  Check_exCapitalIs_SL = Order_Close(PortHold.OP);

               }
            }
            //---

            if(!Check_exCapitalIs_SL &&
               !eaOrder_InsertMode) {
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
            //---
            bool  Check_exCapitalIs_SL =  false;
            if(exCapitalIs_TP) {
               double   Current  =  (PortHold.Value / exCapitalValue) * 100;
               if(Current >= exCapitalPer_TP) {
                  Check_exCapitalIs_SL = Order_Close(PortHold.OP);
               }
            }
            //---
            if(exProfit_Tail &&
               !Check_exCapitalIs_SL) {

               //--- Port Positive
               //Print(__FUNCSIG__, __LINE__, "# ", "Port Positive");

               /* ##Thongeak ##TPtailing */

               /* Detect TakeProfit */

               /* if Order Avg is + action same SL by Start Sl Price at Cap Price
                  Funtion Modufy Group
               */
               //Print(__FUNCSIG__, __LINE__, "# ", "PortHold.PortIsHave_TP: ", PortHold.PortIsHave_TP);

               if(!PortHold.FoceModify) {
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

                  int   Distance_Test  =  (PortHold.State  == 0) ?
                                          exProfit_Tail_Start :
                                          exProfit_Tail_Point + exProfit_Tail_Step;

                  //Print(__FUNCSIG__, __LINE__, "# ", "Distance_Test: ", Distance_Test);

                  if(Distance >= Distance_Test) {
                     //--- >> Order Modify Group
                     OrderModifys_SL(PortHold.OP);
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

   C += "PortSL_Price" + ": " + PortHold.PortSL_Price + "\n";
   C += "State" + ": " + PortHold.State + "\n";
   C += "FoceModify" + ": " + PortHold.FoceModify + "\n";

   C += "\n";


   Comment(C);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
