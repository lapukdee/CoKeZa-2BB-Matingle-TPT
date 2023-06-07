//+------------------------------------------------------------------+
//|                                                     Megalots.mq4 |
//|                                        Copyright 2020, ThongEak. |
//|                               https://www.facebook.com/lapukdee/ |
//+------------------------------------------------------------------+
#include "../2BB-Matingle-TPT.mq4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProductLock
{
   string            Account[];
   bool              EA_OrderRem;
public:
   bool              EA_Allow, EA_AllowAccount, EA_AllowDate;
   int               EA_Point, EA_AllowPoint;

   void              CProductLock()
   {
      EA_AllowPoint = 4;
      //Print(__FUNCTION__,"#",__LINE__);
      Checker();
   };

                    ~CProductLock(void) {};

   bool              Passport(bool  action = true)
   {
      if(EA_Point >= EA_AllowPoint) {

         {/* hotfix/CutloseByEQ [v1.644] */

            if(IsOptimization() || IsTesting())
               return   true;

            if(action)
               return   true;
         }

      } else {
         if(action) {
            if(Port.cnt_AllPen > 0) {
               //Order_PendingDelete();
            }
         }
      }
      return   false;
   }
   bool              PassportIsTemp()
   {
      if(EA_Point == EA_AllowPoint) {
         return   true;
      }
      return   false;
   }
   bool              Checker()
   {
      EA_AllowAccount = IsEA_AllowAccount();
      Print(__FUNCTION__, "#", __LINE__, " EA_AllowAccount : ", EA_AllowAccount);
      //---
      EA_AllowDate   = IsEA_AllowDate();
      Print(__FUNCTION__, "#", __LINE__, " EA_AllowDate : ", EA_AllowDate);
      //---
      EA_OrderRem = Port.cnt_All > 0;
      Print(__FUNCTION__, "#", __LINE__, " EA_OrderRem : ", EA_OrderRem);
      CheckerPoint();

      Print("");
      EA_Allow =  EA_AllowAccount && (EA_AllowDate || EA_OrderRem);
      Print(__FUNCTION__, "#", __LINE__, " ** EA_Allow ** : ", EA_Allow);
      Print("");

      return   EA_Allow;
   }
private:
   int               CheckerPoint()
   {
      EA_Point = 0;

      if(EA_AllowAccount)
         EA_Point += 3;
      if(EA_AllowDate)
         EA_Point += 2;
      if(EA_OrderRem)
         EA_Point += 1;

      Print(__FUNCTION__, "#", __LINE__, " EA_Point : ", EA_Point, "/", EA_AllowPoint, " = ", EA_Point >= EA_AllowPoint);
      return   EA_Point;
   }
   bool              IsEA_AllowAccount()
   {

      string   numm  = string(AccountNumber());
      Print("");

      int   k  =  StringSplit(eaLOCK_Account, StringGetCharacter(",", 0), Account);
      if(k > 0) {

         Print(__FUNCTION__, "#", __LINE__, " Account Allow : ", eaLOCK_Account);
         Print(__FUNCTION__, "#", __LINE__, " AccountNumber : ", numm);

         for(int i = 0; i < k; i++) {
            if(Account[i] == numm) {
               return   true;
            }
         }

      } else {
         //--- k=0 :: Account free
         Print(__FUNCTION__, "#", __LINE__, " Account Allow : Unlimited");
         return   true;
      }
      return   false;
   }

   bool              IsEA_AllowDate()
   {
      Print("");
      if(eaLOCK_Date == "") {
         Print(__FUNCTION__, "#", __LINE__, " Exprie : Unlimited");
         return   true;
      }
      datetime exprie   =  StringToTime(eaLOCK_Date);
      //TimeGMT();
      Print(__FUNCTION__, "#", __LINE__, " Exprie : ", exprie);
      Print(__FUNCTION__, "#", __LINE__, " TimeGMT : ", TimeGMT());

      EA_AllowDate   =  TimeGMT() < exprie;
      return   EA_AllowDate;
   }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProductLock ProduckLock  =  new CProductLock;
//+------------------------------------------------------------------+
