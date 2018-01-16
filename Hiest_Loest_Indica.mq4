
//+------------------------------------------------------------------+
//|                                     LastManStandingIndicator.mq4 |
//|                                        Copyright 2016, Jay Davis |
//|                                         https://www.tidyneat.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Jay Davis"
#property link      "https://www.tidyneat.com"
#property version   "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 5


extern color MajorSwingColor=clrPurple;
extern int MajorSwingSize=3;
extern int PeriodsInMajorSwing=13;

extern color MinorSwingColor=clrCornflowerBlue;
extern int MinorSwingSize=1;
extern int PeriodsInMinorSwing=5;

extern ENUM_MA_METHOD MovingAveragMethod=MODE_EMA;
extern int MovingAveragePeriods= 55;
extern color MovingAvergeColor = clrDarkGoldenrod;

extern color fiftyPercentLineColor=clrAliceBlue;

int lookBack=PeriodsInMajorSwing*2;

double majorSwingHigh[];
double minorSwingHigh[];
double majorSwingLow[];
double minorSwingLow[];
double EMA[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,majorSwingHigh);  //associates array with buffer
   SetIndexStyle(0,DRAW_ARROW,EMPTY,MajorSwingSize,MajorSwingColor);
   SetIndexArrow(0,108); // drawing wingding 108
   SetIndexLabel(0,"Major Swing High");

   SetIndexBuffer(1,minorSwingHigh);  //associates array with buffer
   SetIndexStyle(1,DRAW_ARROW,EMPTY,MinorSwingSize,MinorSwingColor);
   SetIndexArrow(1,108); // drawing wingding 108
   SetIndexLabel(1,"Minor Swing High");

   SetIndexBuffer(2,majorSwingLow);  //associates array with buffer
   SetIndexStyle(2,DRAW_ARROW,EMPTY,MajorSwingSize,MajorSwingColor);
   SetIndexArrow(2,108); // drawing wingding 108
   SetIndexLabel(2,"Major Swing Low");

   SetIndexBuffer(3,minorSwingLow);  //associates array with buffer
   SetIndexStyle(3,DRAW_ARROW,EMPTY,MinorSwingSize,MinorSwingColor);
   SetIndexArrow(3,108); // drawing wingding 108
   SetIndexLabel(3,"Minor Swing Low");

   SetIndexBuffer(4,EMA);  //associates array with buffer
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,EMPTY,MovingAvergeColor);
   SetIndexLabel(4,"Moving Average");


//---
   return(INIT_SUCCEEDED);
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

   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors 
   if(counted_bars<0) return(-1);
//---- the last counted bar will be recounted 
//if(counted_bars>0) counted_bars--; 
   limit=Bars-counted_bars;
//---- main loop 
// First Run Through Rule
   if(counted_bars==0)
     {
      if(lookBack>=MovingAveragePeriods)
        {
         limit-=lookBack;
        }
      else
        {
         limit-=MovingAveragePeriods;
        }
     }


//---
   for(int i=1; i<limit; i++)
     {
      // Draw Moving Average
      EMA[i]=iMA(NULL,0,MovingAveragePeriods,0,MovingAveragMethod,PRICE_CLOSE,i);

      // Minor Swing High Logic
      if(iHighest(NULL,0,MODE_HIGH,PeriodsInMinorSwing*2,i)==i+PeriodsInMinorSwing)
        {
         minorSwingHigh[i+PeriodsInMinorSwing]=High[i+PeriodsInMinorSwing];
        }

      // Major Swing High Logic
      if(iHighest(NULL,0,MODE_HIGH,PeriodsInMajorSwing*2,i)==i+PeriodsInMajorSwing)
        {
         majorSwingHigh[i+PeriodsInMajorSwing]=High[i+PeriodsInMajorSwing];
        }

      // Minor Swing Low Logic
      if(iLowest(NULL,0,MODE_LOW,PeriodsInMinorSwing*2,i)==i+PeriodsInMinorSwing)
        {
         minorSwingLow[i+PeriodsInMinorSwing]=Low[i+PeriodsInMinorSwing];
        }

      // Major Swing Low Logic
      if(iLowest(NULL,0,MODE_LOW,PeriodsInMajorSwing*2,i)==i+PeriodsInMajorSwing)
        {
         majorSwingLow[i+PeriodsInMajorSwing]=Low[i+PeriodsInMajorSwing];
        }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+