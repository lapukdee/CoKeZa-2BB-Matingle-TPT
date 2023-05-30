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
   }

   struct sPortIsHave_TP {
      int            Counter;
      double         Price;
      bool           IsSL_Eq;

      bool           IsResult;

      void           Clear()
      {
         Counter = 0;
         Price   = -1;
         IsSL_Eq = true;
         IsResult =  false;
      }
   };
   sPortIsHave_TP    PortIsHaveTP_Buy;
   sPortIsHave_TP    PortIsHaveTP_Sell;

   void              Calculator()
   {
      //if(OrdersTotal() >= 1)
      {
         Init();

         {
            PortIsHaveTP_Buy.Clear();
            PortIsHaveTP_Sell.Clear();
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
                        PortIsHaveTP_Buy.Counter++;

                        if(PortIsHaveTP_Buy.Price == -1) {
                           PortIsHaveTP_Buy.Price = _OrderStopLoss;
                        } else {
                           if(PortIsHaveTP_Buy.Price != _OrderStopLoss) {
                              PortIsHaveTP_Buy.IsSL_Eq = false;
                           }
                        }
                     } else {
                        PortIsHaveTP_Buy.Counter   = cnt_Buy;
                        PortIsHaveTP_Buy.IsSL_Eq   = true;
                        PortIsHaveTP_Buy.Price     = OrderOpenPrice();
                     }
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
                        PortIsHaveTP_Sell.Counter++;

                        if(PortIsHaveTP_Sell.Price == -1) {
                           PortIsHaveTP_Sell.Price = _OrderStopLoss;
                        } else {
                           if(PortIsHaveTP_Sell.Price != _OrderStopLoss) {
                              PortIsHaveTP_Sell.IsSL_Eq = false;
                           }
                        }
                     } else {
                        PortIsHaveTP_Sell.Counter  = cnt_Sel;
                        PortIsHaveTP_Sell.IsSL_Eq  = true;
                        PortIsHaveTP_Sell.Price    = OrderOpenPrice();
                     }
                  }
               }

               if(OrderType_ == OP_SELLSTOP || OrderType_ == OP_SELLLIMIT) {
                  cnt_SelPen++;
               }

            }
         }
         {

            if(cnt_Buy > 0) {
               PortIsHaveTP_Buy.IsResult = (cnt_Buy == PortIsHaveTP_Buy.Counter) &&
                                           PortIsHaveTP_Buy.IsSL_Eq;
            } else {
               PortIsHaveTP_Buy.IsResult = true;
            }

            if(cnt_Sel > 0) {
               PortIsHaveTP_Sell.IsResult = (cnt_Sel == PortIsHaveTP_Sell.Counter) &&
                                            PortIsHaveTP_Sell.IsSL_Eq;
            } else {
               PortIsHaveTP_Sell.IsResult = true;
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


               double   RimInsert = (exOrder_InDistancePoint_Get () * Point) * -1;

               if(cnt_Sel > 0) {
                  Point_Distance = ActivePoint_TOP;

                  Draw_SumProduct(5, ActivePlace_TOP + RimInsert, clrMidnightBlue, "_ActivePlace_TOP_RimInsert");
               }
               if(cnt_Buy > 0) {
                  Point_Distance = ActivePoint_BOT;

                  Draw_SumProduct(5, ActivePlace_BOT - RimInsert, clrMidnightBlue, "_ActivePlace_BOT_RimInsert");
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

   double   Order_Lots = exOrder_LotStart * (MathPow(exOrder_LotMulti, CountOfHold));
   Order_Lots = NormalizeDouble(Order_Lots, 2);

   Print(__LINE__, "# Order_Lots: ", Order_Lots);

   int ticket = OrderSend(Symbol(), OP_Commander, Order_Lots, PricePlace, 3, 0, 0,
                          EA_Identity_Short + "[" + string(CountOfHold) + "]",
                          exMagicnumber);

   return   true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  OrderModifys_SL(int  OP)
{
   Print(__FUNCSIG__, __LINE__, "# ", "OP: ", OP);

   double   __SL_New = -1;
   if(OP == OP_BUY) {
      __SL_New   = NormalizeDouble(Bid - (exProfit_Tail * Point), Digits);

      if(Port.sumProd_Buy > __SL_New) {
         return   false;
      }
      Draw_HLine(OP_BUY, Bid, clrWhite, "SL_New*Bid");
   } else {
      __SL_New   = NormalizeDouble(Ask + (exProfit_Tail * Point), Digits);

      if(Port.sumProd_Sel < __SL_New) {
         return   false;
      }
      Draw_HLine(OP_SELL, Ask, clrWhite, "SL_New*Ask");
   }

   int   __OrdersTotal   =  OrdersTotal();
   for(int icnt = 0; icnt < __OrdersTotal; icnt++) {

      if(OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES) &&
         OrderSymbol() == Symbol() &&
         OrderMagicNumber() == exMagicnumber &&
         OrderType() == OP) {

         double   OrderStopLoss_ = OrderStopLoss();

         if(OrderStopLoss_ != __SL_New) {

            int   OrderTicket_   = OrderTicket();

            bool res = OrderModify(OrderTicket_, OrderOpenPrice(), __SL_New, 0, 0);
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
   double   res   = exOrder_InDistancePoint;// * MathPow(1.15, OrederCNT);
   return   int(res * -1);
}
//+------------------------------------------------------------------+


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
