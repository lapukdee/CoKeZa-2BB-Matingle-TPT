//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class CTailing
{
public:
   double   Priofit_Static_Point;
   int      Tail_Point;
   int      Tail_Start;
   int      Tail_Step;


   CTailing()
   {
      Print(__FUNCSIG__, __LINE__);

      //SetValue();
   }

   ~CTailing() {};

   void  SetValue(int   Profit_TP_Point__)
   {
      Priofit_Static_Point = Profit_TP_Point__;
      //Print(__FUNCSIG__, __LINE__, "# Priofit_Static_Point: ", Priofit_Static_Point);

      Tail_Point = int(Priofit_Static_Point * toPer(exProfit_Tail_Point_P));
      //Print(__FUNCSIG__, __LINE__, "# Tail_Point: ", Tail_Point);

      Tail_Start = int(Priofit_Static_Point * toPer(exProfit_Tail_Start_P));

      Tail_Step = int(Priofit_Static_Point * ((100 - Tail_Start) * toPer(Tail_Step)));
   }
private:
   double   toPer(int   v)
   {
      return NormalizeDouble(double(v) / 100, 2);
   }
};
CTailing Tailing;
//+------------------------------------------------------------------+
