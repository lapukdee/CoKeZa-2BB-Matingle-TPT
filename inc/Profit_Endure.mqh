//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProfit_Endure
{
   enum eBOX {
      BOX_Time,
      BOX_Stamp
   };

   double            Endure;
   datetime          OrderDateLast;
public:

   datetime          BOX[4][2];  //eBOX

//---

                     CProfit_Endure()
   {
      Endure = 25;
   };
                    ~CProfit_Endure() {};

   //---
   void              Box_Maker(datetime   _OrderDateLast)
   {
      OrderDateLast = _OrderDateLast;

      double   EndureNeg = NormalizeDouble((100 - Endure) / 100, 2);


      datetime    temp     =   3 * 3600;
      datetime    DateLast = OrderDateLast + temp;

      for(int i = 0; i < 4; i++) {

         Print("DateLast: ", DateLast, " | temp: ", double(temp / 3600));

         BOX[i][BOX_Time]  =  DateLast;
         BOX[i][BOX_Stamp] = 0;

         temp  =  temp * EndureNeg;
         DateLast += temp;

      }

   }
   //---

private:
   datetime          TimeDuration(datetime   _OrderDateLast)
   {
      return   0;
   }
};

CProfit_Endure Profit_Endure;
//+------------------------------------------------------------------+
