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
   int               SeasonLeng;
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
      OrderDateLast  = _OrderDateLast;
      SeasonLeng     =  ArraySize(Season) / 2;

      double   EndureNeg = NormalizeDouble((100 - Endure) / 100, 2);


      datetime    temp     =   datetime(exEndure_HourMax * 3600);
      datetime    DateLast = OrderDateLast + temp;

      for(int i = 0; i < SeasonLeng; i++) {

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

      for(int i = 0; i < SeasonLeng; i++) {

         if(Season[i][BOX_Stamp] == 0) {
            if(Season[i][BOX_Time] <= Now) {
               return   i;
            }
         } else {
            if(i == SeasonLeng - 1) {
               return  SeasonLeng - 1;
            }
         }

      }

      return   -1;
   }

   void              Season_Book(int   room)
   {
      Season[room][BOX_Stamp] = 1;
   }

   string            Season_TextToComment()
   {
      string   cmm = "Season-Table\n";


      cmm += TimeToStr(OrderDateLast, TIME_DATE | TIME_MINUTES) + " | Last ** \n";

      //---
      VLineCreate(0, OrderDateLast);
      //---

      for(int i = 0; i < SeasonLeng; i++) {

         //---
         VLineCreate(i + 1, Season[i][BOX_Time], clrSaddleBrown);
         //---

         cmm += TimeToStr(Season[i][BOX_Time], TIME_DATE | TIME_MINUTES) + " | " + bool(Season[i][BOX_Stamp]) + "\n";

      }
      cmm += "\n";
      return   cmm;
   }
   //---

private:
   datetime          TimeDuration(datetime   _OrderDateLast)
   {
      return   0;
   }

   bool              VLineCreate(string      name2,
                                 datetime    time,
                                 color       clr = clrRed      // line color
                                )          // line time)

   {

      long            chart_ID = 0;      // chart's ID
      string          name = "Endure_" + name2;  // line name
      int             sub_window = 0;    // subwindow index

      ENUM_LINE_STYLE style = STYLE_DOT; // line style
      int             width = 1;         // line width
      bool            back = true;      // in the background
      bool            selection = false;  // highlight to move
      bool            hidden = false;     // hidden in the object list
      long            z_order = 0;       // priority for mouse click

      if(!time)
         time = TimeCurrent();
      ResetLastError();
      if(!ObjectCreate(chart_ID, name, OBJ_VLINE, sub_window, time, 0)) {

         ObjectSetInteger(chart_ID, name, OBJPROP_TIME, time);

         ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
         ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
         ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);

      }
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
      ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);

      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
      return(true);
   }
};

CProfit_Endure Profit_Endure;
//+------------------------------------------------------------------+
