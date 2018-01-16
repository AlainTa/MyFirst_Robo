
//+------------------------------------------------------------------+
//|                                   Stochastic Buy Sell Arrows.mq4 |
//|                      Copyright 2016, ACB Forex Trading Solutions |
//|                                  https://www.acbforextrading.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, ACB Forex Trading Solutions"
#property link      "https://www.acbforextrading.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LawnGreen
#property indicator_color2 DeepPink
#property indicator_width1 1
#property indicator_width2 1
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern string Stochastic = "Configure Stochastic Settings";
extern int KPeriod = 5;
extern int DPeriod = 3;
extern int Slowing = 3;
extern int OverBought = 80;
extern int OverSold = 20;
extern string Alerts  = "Configure Alerts";
extern bool PopUpAlert = true;    //Popup Alert
extern bool EmailAlert = true;   //Email Alert
extern bool PushAlert  = true;  //Push Notifications Alert
// UP and DOWN Buffers
double UP[];
double DOWN[];
// Distance of arrows from the high or low of a bar
int distance = 3;
double MyPoint;
datetime CTime;

int OnInit()
  {
//--- indicator buffers mapping
  //UP Arrow Buffer
  SetIndexEmptyValue(0,0.0);
  SetIndexStyle(0,DRAW_ARROW,0,EMPTY);
  SetIndexArrow(0,233);
  SetIndexBuffer(0,UP);
  
  //DOWN Arrow Buffer
  SetIndexEmptyValue(1,0.0);
  SetIndexStyle(1,DRAW_ARROW,0,EMPTY);
  SetIndexArrow(1,234);
  SetIndexBuffer(1,DOWN);
  
  //Auto Adjustment for broker digits
  if (Digits()==5||Digits()==3){MyPoint=Point*10;} else{MyPoint=Point;}
  CTime=Time[0];
//---
   return(INIT_SUCCEEDED);
  }
  
  void OnDeinit(const int reason)
  {
//--- delete an object from a chart 
   Comment("");
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
Comment("www.ACBForexTrading.com");
int limit = rates_total;
int count=prev_calculated;
//Main function
for(int i=limit-count; i>=1;i--)
{
//Getting Stochastic buffer values using the iCustom function
  double Stoch1 = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_MAIN,i);
  double Stoch2 = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_MAIN,i+1);
  
  if(Stoch1>OverSold && Stoch2<OverSold)
  {
   UP[i]=Low[i]-distance*MyPoint;
   if(CTime!=Time[0])
    {
     if(PopUpAlert){Alert(Symbol()," ","Buy Arrow");}
     if(EmailAlert){SendMail(Symbol()+" Buy Arrow"+"","Buy Signal");}
     if(PushAlert){SendNotification(Symbol()+" Buy Arrow"+"");}
     CTime=Time[0];
    }
  }
  if(Stoch1<OverBought && Stoch2>OverBought)
  {
   DOWN[i]=High[i]+distance*MyPoint;
   if(CTime!=Time[0])
    {
     if(PopUpAlert){Alert(Symbol()," ","Sell Arrow");}
     if(EmailAlert){SendMail(Symbol()+" Sell Arrow"+"","Sell Signal");}
     if(PushAlert){SendNotification(Symbol()+" Sell Arrow"+"");}
     CTime=Time[0];
    }
  }
} 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+