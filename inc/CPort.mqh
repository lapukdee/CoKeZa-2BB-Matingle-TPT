//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPort
{
public:
   int                  cnt_Buy, cnt_Sel, cnt_All;
   int                  cnt_BuyPen, cnt_SelPen, cnt_AllPen;

   double               Point_Buy, Point_Sel;

   double               sumProd_Buy, sumLot_Buy;
   double               sumProd_Sel, sumLot_Sel, sumLot_All;
   double               sumHold_Buy, sumHold_Sel, sumHold_All;

   int                  Point_Distance;

   //---
   double               ActivePlace_TOP, ActivePlace_BOT;
   int                  ActivePoint_TOP, ActivePoint_BOT;
   //---
   datetime             Older_Lasted;

                     CPort(void)
   {
      Init();

      //SymbolInfoDouble
   };
                    ~CPort(void) {};
   void              Init()
   {
      cnt_Buy  =  0;
      cnt_Sel  =  0;
      cnt_All  =  0;

      cnt_BuyPen = 0;
      cnt_SelPen = 0;
      cnt_AllPen = 0;

      Point_Buy = 0;
      Point_Sel = 0;

      sumProd_Buy = 0;
      sumLot_Buy = 0;
      sumProd_Sel = 0;
      sumLot_Sel = 0;

      sumLot_All  = 0;
      sumHold_Buy = 0;
      sumHold_Sel = 0;
      sumHold_All = 0;

      Point_Distance = -1;

      ActivePlace_TOP = -1;
      ActivePlace_BOT = 9999999999;

      ActivePoint_TOP = 0;
      ActivePoint_BOT = 0;
      //---

      Older_Lasted = 0;
   }
//---
   struct sTPT {

      int            Counter_Standby,  Counter_Runner_;
      double         Price_Standby,    Price_Runner_;
      bool           Eq_Standby,       Eq_Runner_;

      int            State;         // 0: Start/Normal,  1: TialingRuner
      bool           FoceModify;
      double         Price_SL;

      bool           IsPrice_FixTP;

      void           Clear()
      {
         Counter_Standby = 0;
         Counter_Runner_ = 0;
         Price_Standby = -1;
         Price_Runner_ = -1;
         Eq_Standby = true;
         Eq_Runner_ = true;

         State = -1;       // 0: Start/Normal,  1: TialingRuner
         FoceModify = false;

         IsPrice_FixTP  =  true;
      }
   };
   sTPT              TPT_Buy;
   sTPT              TPT_Sell;
//---

   struct sOlder {
      datetime       Frist;
      datetime       Last;

      void           Clear()
      {
         Frist = 99999999999999999;
         Last  = 0;
      }
   };
   sOlder              Older_Buy;
   sOlder              Older_Sell;
//---

   void              Calculator()
   {
      //if(OrdersTotal() >= 1)
      {
         Init();

         {
            TPT_Buy.Clear();
            TPT_Sell.Clear();
         }
         {
            Older_Buy.Clear();
            Older_Sell.Clear();
         }

         int   __OrdersTotal   =  OrdersTotal();
         for(int icnt = 0; icnt < __OrdersTotal; icnt++) { // for loop
            bool r = OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
            // check for opened position, symbol & MagicNumber
            if(r &&
               OrderSymbol() == Symbol() &&
               OrderMagicNumber() == exMagicnumber) {


               int   OrderType_ =  OrderType();

               {
                  /* v1.64 */
                  if(OrderType_ <= OP_SELL) {
                     ActivePlace_TOP   =  MathMax(ActivePlace_TOP, OrderOpenPrice());
                     ActivePlace_BOT   =  MathMin(ActivePlace_BOT, OrderOpenPrice());
                  }
               }

               if(OrderType_ == OP_BUY) {
                  cnt_All++;
                  cnt_Buy++;

                  sumProd_Buy += OrderOpenPrice() * OrderLots();
                  sumLot_Buy += OrderLots();
                  sumLot_All += OrderLots();

                  sumHold_Buy += OrderProfit() + OrderCommission() + OrderSwap();
                  {
                     /* Check SL */
                     double   _OrderStopLoss = OrderStopLoss();
                     if(_OrderStopLoss != 0) {
                        //Runner

                        if(cnt_Buy == 1) {
                           TPT_Buy.Price_Runner_ = _OrderStopLoss;
                           TPT_Buy.Counter_Runner_++;
                        }
                        if(cnt_Buy >= 2 && TPT_Buy.Eq_Runner_)  {
                           if(TPT_Buy.Price_Runner_ == _OrderStopLoss) {
                              TPT_Buy.Counter_Runner_++;
                           } else {
                              TPT_Buy.Eq_Runner_   =  false;
                           }
                        }
                     }
                     if(_OrderStopLoss == 0) {
                        //Standby
                        TPT_Buy.Counter_Standby++;
                     }

                  }
                  {
                     double   _OrderTakeProfit   =  OrderTakeProfit();
                     if(_OrderTakeProfit == 0) {
                        TPT_Buy.IsPrice_FixTP = false;
                     }

                  }
                  {
                     Older_Buy.Last = MathMax(Older_Buy.Last, OrderOpenTime());
                  }
               }


               if(OrderType_ == OP_BUYSTOP || OrderType_ == OP_BUYLIMIT) {
                  cnt_BuyPen++;
               }
               //---

               if(OrderType_ == OP_SELL) {
                  cnt_All++;
                  cnt_Sel++;

                  sumProd_Sel += OrderOpenPrice() * OrderLots();
                  sumLot_Sel += OrderLots();
                  sumLot_All += OrderLots();

                  sumHold_Sel += OrderProfit() + OrderCommission() + OrderSwap();
                  {
                     /* Check SL */
                     double   _OrderStopLoss = OrderStopLoss();

                     if(_OrderStopLoss != 0) {
                        //Runner

                        if(cnt_Sel == 1) {
                           TPT_Sell.Price_Runner_ = _OrderStopLoss;
                           TPT_Sell.Counter_Runner_++;
                        }
                        if(cnt_Sel >= 2 && TPT_Sell.Eq_Runner_)  {
                           if(TPT_Sell.Price_Runner_ == _OrderStopLoss) {
                              TPT_Sell.Counter_Runner_++;
                           } else {
                              TPT_Sell.Eq_Runner_   =  false;
                           }
                        }

                     }
                     if(_OrderStopLoss == 0) {
                        //Standby
                        TPT_Sell.Counter_Standby++;
                     }

                  }
                  {
                     double   _OrderTakeProfit   =  OrderTakeProfit();
                     if(_OrderTakeProfit == 0) {
                        TPT_Sell.IsPrice_FixTP = false;
                     }

                  }
                  {
                     Older_Sell.Last = MathMax(Older_Sell.Last, OrderOpenTime());
                  }
               }

               if(OrderType_ == OP_SELLSTOP || OrderType_ == OP_SELLLIMIT) {
                  cnt_SelPen++;
               }

            }
         }
         //---
         {
            /* v1.64 */
            //Global.Price_Master
            if(cnt_All > 0) {

               ActivePoint_TOP = int((ActivePlace_TOP - Ask) / Point); //Sell
               ActivePoint_BOT = int((Bid - ActivePlace_BOT) / Point); //Buy

               Draw_SumProduct(5, ActivePlace_TOP, clrYellow, "_ActivePlace_TOP");
               Draw_SumProduct(5, ActivePlace_BOT, clrYellow, "_ActivePlace_BOT");


               double   RimInsert = (exOrder_InDistancePoint_Get() * Point) * -1;

               if(cnt_Sel > 0) {
                  Point_Distance = ActivePoint_TOP;

                  Draw_SumProduct(5, ActivePlace_TOP + RimInsert, clrTan, "_ActivePlace_TOP_RimInsert");
               }
               if(cnt_Buy > 0) {
                  Point_Distance = ActivePoint_BOT;

                  Draw_SumProduct(5, ActivePlace_BOT - RimInsert, clrTan, "_ActivePlace_BOT_RimInsert");
               }

            } else {
               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_TOP");
               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_BOT");

               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_TOP_RimInsert");
               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_BOT_RimInsert");
            }
         }

         cnt_AllPen  =  cnt_BuyPen + cnt_SelPen;

         if(cnt_Buy >= 1) {
            sumProd_Buy = NormalizeDouble(sumProd_Buy / sumLot_Buy, Digits);

         }
         if(sumProd_Buy != 0) {
            Draw_SumProduct(OP_BUY, sumProd_Buy, clrRoyalBlue);
            Point_Buy = (Bid - sumProd_Buy) * MathPow(10, Digits);

         } else {
            //ObjectsDeleteAll(0, EA_Identity_Short + "_SumProduct" + string(OP_BUY), 0, OBJ_HLINE);
         }
         //--
         if(cnt_Sel >= 1) {
            sumProd_Sel = NormalizeDouble(sumProd_Sel / sumLot_Sel, Digits);

         }
         if(sumProd_Sel != 0) {
            Draw_SumProduct(OP_SELL, sumProd_Sel, clrTomato);
            Point_Sel = (sumProd_Sel - Ask) * MathPow(10, Digits);

         } else {
            //ObjectsDeleteAll(0, EA_Identity_Short + "_SumProduct" + string(OP_SELL), 0, OBJ_HLINE);
         }
         //--

         sumHold_All = sumHold_Buy + sumHold_Sel;

         {/* Profit taillng */

            {/* Buy */
               if(cnt_Buy > 0) {

                  if(cnt_Buy == TPT_Buy.Counter_Standby &&
                     TPT_Buy.Counter_Runner_ == 0 ) {

                     TPT_Buy.State  =  0;
                     TPT_Buy.Price_SL = sumProd_Buy;
                     TPT_Buy.Eq_Standby    =  true;


                  }
                  if(cnt_Buy == TPT_Buy.Counter_Runner_ &&
                     TPT_Buy.Counter_Standby == 0 ) {

                     TPT_Buy.State  =  1;
                     TPT_Buy.Price_SL =  TPT_Buy.Price_Runner_;

                     if(TPT_Buy.Eq_Runner_ == false) {
                        TPT_Buy.FoceModify = true;
                     }

                  }

                  if(cnt_Buy > 0 && TPT_Buy.Counter_Standby > 0 && TPT_Buy.Counter_Runner_ > 0) {
                     TPT_Buy.FoceModify = true;
                  }

               }
            }
            {/* Sell */
               if(cnt_Sel > 0) {

                  if(cnt_Sel == TPT_Sell.Counter_Standby &&
                     TPT_Sell.Counter_Runner_ == 0 ) {

                     TPT_Sell.State    =  0;
                     TPT_Sell.Price_SL = sumProd_Sel;
                     TPT_Sell.Eq_Standby    =  true;

                  }
                  if(cnt_Sel == TPT_Sell.Counter_Runner_ &&
                     TPT_Sell.Counter_Standby == 0 ) {

                     TPT_Sell.State  =  1;
                     TPT_Sell.Price_SL =  TPT_Sell.Price_Runner_;

                     if(TPT_Sell.Eq_Runner_ == false) {
                        TPT_Sell.FoceModify = true;
                     }

                  }

                  if(cnt_Sel > 0 && TPT_Sell.Counter_Standby > 0 && TPT_Sell.Counter_Runner_ > 0) {
                     TPT_Sell.FoceModify = true;
                  }
               }
            }

         }

         {

            Older_Lasted = MathMax(Older_Buy.Last, Older_Sell.Last);

         }
      }
   }
private:
   void              Draw_SumProduct(int OP, double Price, color Clr, string   name = "_SumProduct", bool  IsAdd_IdName = true)
   {
      string ObjTag = (IsAdd_IdName) ?
                      EA_Identity_Short + name + string(OP) :
                      name + string(OP);

      if(!ObjectCreate(ObjTag, OBJ_HLINE, 0, 0, Price)) {

      }
      if(ObjectMove(0, ObjTag, 0, 0, Price)) {
      }
      ObjectSet(ObjTag, OBJPROP_BACK, false);
      ObjectSet(ObjTag, OBJPROP_COLOR, Clr);
   }

};
CPort Port  =  new CPort;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderSend_Active(int OP_Commander, int CountOfHold)
{
   Print(__FUNCSIG__);

   double   PricePlace = (OP_Commander == OP_BUY) ? Ask : Bid;

   double   Order_Lots = getOrder_LotStart() * (MathPow(exOrder_LotMulti, CountOfHold));
   Order_Lots = NormalizeDouble(Order_Lots, 2);

   Print(__LINE__, "# Order_Lots: ", Order_Lots);

   int ticket = OrderSend(Symbol(), OP_Commander, Order_Lots, PricePlace, 3, 0, 0,
                          EA_Identity_Short + "[" + string(CountOfHold) + "]",
                          exMagicnumber);

   if(ticket < 0) {
      Print("OrderSend failed with error #", GetLastError());
      return   false;
   } else
      Print("OrderSend placed successfully");

   Port.Calculator();

   Profit_Endure.Season_Maker(Port.Older_Lasted);

   return   true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   getOrder_LotStart()
{
   if(!eaOrder_LotStartByBalance) {
      return NormalizeDouble(exOrder_LotStart, 2);
   }

   double   rate  =  AccountInfoDouble(ACCOUNT_BALANCE) / eaCapital;
   rate = rate - MathMod(rate, 1);

   return NormalizeDouble(exOrder_LotStart * rate, 2);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderModifys_SL(int  OP, double  PortSL_Price = -1)
{
   if(!exProfit_Tail) {
      return   exProfit_Tail;
   }

   Print(__FUNCSIG__, __LINE__, "# ", "OP: ", OP);

   double   __SL_New = -1;
   if(OP == OP_BUY) {
      __SL_New   = NormalizeDouble(Bid - (Tailing.Tail_Point * Point), Digits);

      if(PortSL_Price != -1 && __SL_New < PortSL_Price) {
         return   false;
      }

      if(Port.sumProd_Buy > __SL_New) {
         return   false;
      }
      Draw_HLine(OP_BUY, Bid, clrWhite, "SL_New*Bid");
   } else {
      __SL_New   = NormalizeDouble(Ask + (Tailing.Tail_Point * Point), Digits);

      if(PortSL_Price != -1 && __SL_New > PortSL_Price) {
         return   false;
      }

      if(Port.sumProd_Sel < __SL_New) {
         return   false;
      }

      Draw_HLine(OP_SELL, Ask, clrWhite, "SL_New*Ask");
   }
//---

   int   __OrdersTotal   =  OrdersTotal();
   for(int icnt = 0; icnt < __OrdersTotal; icnt++) {

      if(OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == exMagicnumber &&
         OrderType() == OP) {

         double   OrderStopLoss_ = OrderStopLoss();

         if(OrderStopLoss_ != __SL_New) {

            int      OrderTicket_      = OrderTicket();
            double   OrderTakeProfit_  = OrderTakeProfit();
            bool res = OrderModify(OrderTicket_, OrderOpenPrice(), __SL_New, OrderTakeProfit_, 0);
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
//|                                                                  |
//+------------------------------------------------------------------+
int   exOrder_InDistancePoint_Get(int  OrederCNT = 0)
{
   double   res_   = exOrder_InDistancePoint;// * MathPow(1.15, OrederCNT);

   if(exIn_BB) {

      double BandSize[1][3];
      if(BBand_getValue(exIn_BB_TF, exIn_Period, exIn_Deviation, exIn_Applied_price)) {
         int res = ArrayCopy(BandSize, BBand_getValue_Result);

         //double res_   =  -1;

         if(exIn_PriceTest == ENUM_OrderInsertBB_MidBand) {
            res_   =  (BandSize[0][MODE_UPPER] - BandSize[0][MODE_MAIN]) / Point;
         }
      }

   }


   return   int(res_ * -1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Draw_HLine(int OP, double Price, color Clr, string   name = "_SumProduct", bool  IsAdd_IdName = true)
{
   string ObjTag = (IsAdd_IdName) ?
                   EA_Identity_Short + "_" + name + "_" + string(OP) :
                   name + "_" + string(OP);

   if(!ObjectCreate(ObjTag, OBJ_HLINE, 0, 0, Price)) {

   }
   if(ObjectMove(0, ObjTag, 0, 0, Price)) {
   }
   ObjectSet(ObjTag, OBJPROP_BACK, false);
   ObjectSet(ObjTag, OBJPROP_COLOR, Clr);
}
//+------------------------------------------------------------------+
