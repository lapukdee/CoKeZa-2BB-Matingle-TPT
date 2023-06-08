//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern   double   exEndure_Rate     =  20;
extern   double   exEndure_HourMax  =  6;

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

   datetime          Season[4][2];  //eBOX

//---

                     CProfit_Endure()
   {
      Endure = exEndure_Rate;   //%
   };
                    ~CProfit_Endure() {};

   //---
   void              Season_Maker(datetime   _OrderDateLast)
   {
      OrderDateLast = _OrderDateLast;

      double   EndureNeg = NormalizeDouble((100 - Endure) / 100, 2);


      datetime    temp     =   datetime(exEndure_HourMax * 3600);
      datetime    DateLast = OrderDateLast + temp;

      for(int i = 0; i < 4; i++) {

         Print("DateLast: ", DateLast, " | temp: ", double(temp / 3600));

         Season[i][BOX_Time]  =  DateLast;
         Season[i][BOX_Stamp] = 0;

         temp  =  datetime(temp * EndureNeg);
         DateLast += temp;

      }

   }

   int               Season_Check()
   {
      datetime Now   =  TimeCurrent();

      for(int i = 0; i < 4; i++) {

         if(Season[i][BOX_Stamp] == 0) {
            if(Season[i][BOX_Time] <= Now) {
               return   i;
            }
         } else {
            if(i == 3) {
               return  3;
            }
         }

      }

      return   -1;
   }

   void              Season_Book(int   room)
   {
      Season[room][BOX_Stamp] = 1;
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
