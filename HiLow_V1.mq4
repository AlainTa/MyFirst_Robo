//+------------------------------------------------------------------+
//|                                                     HiLow_V1.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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

   double mOpen=Open[1];
   double mClose=Close(NULL,PERIOD_MN1,1);
         
   double wOpen=Open(NULL,PERIOD_W1,1);
   double wClose=Close(NULL,PERIOD_W1,1)
 
      
   double dOpen=Open(NULL,PERIOD_D1,1);
   double dClose=Close(NULL,PERIOD_D1,1)
   
   double h4Open=Open(NULL,PERIOD_H41,1);
   double h4Close=Close(NULL,PERIOD_H4,1)
   
   double h1Open=Open(NULL,PERIOD_H1,1);
   double h1Close=Close(NULL,PERIOD_H1,1)
   
   extern int takeprofit=50;
   extern int stoploss=30;
   
   
   
void OnTick()
  {
//---
   
   double takeprofitlevel;
   double stoplosslevel;
   
   takeprofitlevel=Bid+takeprofit*Point;
   stoplosslevel=Bid+stoploss*Point;

   //if(mOpen >= mClose && wOpen >= wClose && dOpen >= dClose && h4Open >= h4Close && h1Open >= h1Close)
   
   if(dOpen >= dClose)
      {
         int ticketb=OrderSend(NULL,OP_BUY,1.0, Ask,5, stoplosslevel,takeprofitlevel,"My 1First Order");
         
         //Alert("Make an Long Order");
      }
   else if(dOpen <= dClose)
      {
         
         int tickets=OrderSend(NULL,OP_SELL,1.0, Bid,5, stoplosslevel,takeprofitlevel,"My 1First Order");
         
         //Alert("Make an Short Order");
      }
   else
      {
         Print("Nothing Happen");
      }
  }
//+------------------------------------------------------------------+
