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
   double               ActivePoint_TOP, ActivePoint_BOT;

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

      //Docker_total   = -1;
      Point_Distance = -1;

      ActivePlace_TOP = -1;
      ActivePlace_BOT = 9999999999;

      ActivePoint_TOP = 0;
      ActivePoint_BOT = 0;

   }
   void              Calculator()
   {
      //if(OrdersTotal() >= 1)
      {
         //         cnt_Buy = cnt_Sel = cnt_All = 0;
         //         cnt_BuyPen = cnt_SelPen = 0;
         //         Point_Buy = Point_Sel = 0;
         //         sumProd_Buy = sumLot_Buy = 0;
         //         sumProd_Sel = sumLot_Sel = 0;
         //         //
         //         sumHold_Buy =  sumHold_Sel = sumHold_All = 0 ;
         //
         //         Price_Master   = -1;
         //         Docker_total   = -1;
         //         Point_Distance = -1;

         Init();

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

               ActivePoint_TOP = (ActivePlace_TOP - Ask) / Point;
               ActivePoint_BOT = (Bid - ActivePlace_BOT) / Point;

               Draw_SumProduct(5, ActivePlace_TOP, clrYellow, "_ActivePlace_TOP");
               Draw_SumProduct(5, ActivePlace_BOT, clrYellow, "_ActivePlace_BOT");

            } else {
               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_TOP");
               Draw_SumProduct(5, 0, clrYellow, "_ActivePlace_BOT");
            }
         }

         cnt_AllPen  =  cnt_BuyPen + cnt_SelPen;

         if(cnt_Buy >= 1) {
            sumProd_Buy = NormalizeDouble(sumProd_Buy / sumLot_Buy, Digits);

         }
         if(sumProd_Buy != 0) {
            //Draw_SumProduct(OP_BUY, sumProd_Buy, clrRoyalBlue);
            Point_Buy = (Bid - sumProd_Buy) * MathPow(10, Digits);
         } else {
            ObjectsDeleteAll(0, EA_Identity_Short + "_SumProduct" + string(OP_BUY), 0, OBJ_HLINE);
         }
         //--
         if(cnt_Sel >= 1) {
            sumProd_Sel = NormalizeDouble(sumProd_Sel / sumLot_Sel, Digits);

         }
         if(sumProd_Sel != 0) {
            //Draw_SumProduct(OP_SELL, sumProd_Sel, clrTomato);
            Point_Sel = (sumProd_Sel - Ask) * MathPow(10, Digits);
         } else {
            ObjectsDeleteAll(0, EA_Identity_Short + "_SumProduct" + string(OP_SELL), 0, OBJ_HLINE);
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
