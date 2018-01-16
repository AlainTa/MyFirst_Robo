
//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq4 |
//|                                    Copyright 2016, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Hossein Nouri"
#property description "Fully Coded By Hossein Nouri"
#property description "Email : hsn.nouri@gmail.com"
#property description "Skype : hsn.nouri"
#property description "MQL5 Profile : https://www.mql5.com/en/users/hsnnouri"
#property description " "
#property description "Feel free to contact me for MQL4/MQL5 coding."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.1"

#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5

//--- plot UpperGrowing
#property indicator_label1  "UpperGrowing"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot UpperFalling
#property indicator_label2  "UpperFalling"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot LowerGrowing
#property indicator_label3  "LowerGrowing"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrMaroon
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot LowerFalling
#property indicator_label4  "LowerFalling"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- moving average
#property indicator_label5  "MA"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_style5  STYLE_DOT
#property indicator_width5  1



#property  indicator_level1     0.0
#property  indicator_levelcolor clrSilver
#property  indicator_levelstyle STYLE_DOT

//--- input parameters
input int                  InpFastMA=5;                                    //Fast Period
input int                  InpSlowMA=35;                                   //Slow Period
input ENUM_APPLIED_PRICE   InpPriceSource=PRICE_MEDIAN;                    //Apply to
input ENUM_MA_METHOD       InpSmoothingMethod=MODE_SMA;                    //Method
input string               Desc="*** Moving Average of Values ***";        //Description
input bool                 InpShowMA=true;                                 //Show MA
input int                  InpMaPeriod=5;                                  //Period
input ENUM_MA_METHOD       InpMaMethod=MODE_SMA;                           //Method
//--- indicator buffers
double         UpperGrowingBuffer[];
double         UpperFallingBuffer[];
double         LowerGrowingBuffer[];
double         LowerFallingBuffer[];
double         MABuffer[];
double         MATemp[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string ShortName;
   int Begin= MathMax(InpFastMA,InpSlowMA);
   ShortName="EWO("+(string)InpFastMA+","+(string)InpSlowMA+")";
//--- indicator buffers mapping
   if(!InpShowMA)
      IndicatorBuffers(4);
   else  IndicatorBuffers(6);
   SetIndexBuffer(0,UpperGrowingBuffer);
   SetIndexBuffer(1,UpperFallingBuffer);
   SetIndexBuffer(2,LowerGrowingBuffer);
   SetIndexBuffer(3,LowerFallingBuffer);
   SetIndexBuffer(4,MABuffer);
   SetIndexBuffer(5,MATemp);
   SetIndexDrawBegin(0,Begin);
   SetIndexDrawBegin(1,Begin);
   SetIndexDrawBegin(2,Begin);
   SetIndexDrawBegin(3,Begin);
   SetIndexDrawBegin(4,Begin+InpMaPeriod);
   IndicatorDigits(6);
   IndicatorShortName(ShortName);

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
//---
   if(rates_total < MathMax(InpSlowMA,InpFastMA)+InpMaPeriod)    return(0);
   int limit;
   if(prev_calculated==0)
      limit=rates_total-MathMax(InpFastMA,InpSlowMA);
   else limit=rates_total-prev_calculated+1;

   for(int i=0;i<limit;i++)
     {
      calculateValue(i);
     }
   if(InpShowMA==true)
     {
      for(int i=0;i<limit;i++)
        {
         MABuffer[i]=iMAOnArray(MATemp,0,InpMaPeriod,0,InpMaMethod,i);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void calculateValue(int index)
  {
   double value=FastMA(index)-SlowMA(index);
   double valuePrev=FastMA(index+1)-SlowMA(index+1);
   if(InpShowMA==true) MATemp[index]=value;
   if(value>0)
     {
      LowerGrowingBuffer[index]=EMPTY_VALUE;
      LowerFallingBuffer[index]=EMPTY_VALUE;
      if(value>=valuePrev)
        {
         UpperGrowingBuffer[index]=value;
         UpperFallingBuffer[index]=EMPTY_VALUE;
         return;
        }
      if(value<=valuePrev)
        {
         UpperFallingBuffer[index]=value;
         UpperGrowingBuffer[index]=EMPTY_VALUE;
         return;
        }
     }
   if(value<0)
     {
      UpperGrowingBuffer[index]=EMPTY_VALUE;
      UpperFallingBuffer[index]=EMPTY_VALUE;
      if(value>=valuePrev)
        {
         LowerGrowingBuffer[index]=value;
         LowerFallingBuffer[index]=EMPTY_VALUE;
         return;
        }
      if(value<=valuePrev)
        {
         LowerFallingBuffer[index]=value;
         LowerGrowingBuffer[index]=EMPTY_VALUE;
         return;
        }
     }

  }
//+------------------------------------------------------------------+
double FastMA(int _index)
  {
   return iMA(Symbol(), PERIOD_CURRENT,InpFastMA,0,InpSmoothingMethod,InpPriceSource,_index);
  }
//+------------------------------------------------------------------+
double SlowMA(int _index)
  {
   return iMA(Symbol(), PERIOD_CURRENT,InpSlowMA,0,InpSmoothingMethod,InpPriceSource,_index);
  }
//+------------------------------------------------------------------+