//+--------------------------------------------------------------------------+
//| MT4 Indicator:                                     P4L CandleTime.mq4    |
//| Revised: v1_3 2011-Mar-22 by pips4life, a user at forexfactory.com       |
//|                                                                          |
//| For lastest version: http://www.forexfactory.com/showthread.php?t=109305 |
//|  (See Version History below)                                             |
//|                                                                          |
//| Previous names: b-Clock.mq4, CandleTime.mq4...                           |
//|                                          Core time code by Nick Bilak    |
//|             http://metatrader.50webs.com/         beluck[at]gmail.com    |
//|                                       modified by adoleh2000 and dwt5    | 
//|                                                                          | 
//|                                    ���������� ����� �� �������� �����    |
//+--------------------------------------------------------------------------+
//
// Instructions:
// Copy this file to to your MT4 indicators folder:
// On XP, usually:  C:\Program Files\__your_MT4_broker__\experts\indicators\
//
// Review the "extern" variable settings below. Change as desired, then restart MT4 or do "Compile" in MetaEditor.
// Open a chart and add this indicator.   NOTE:  You MUST use the "Chart Shift" option to display blank space
// to the right of the current bar.  FYI, with "Chart Shift" on, there is a triangle on the top edge which you
// can drag further left to create more blank space (or drag right to create less).

// Version History: 
// NOTE: For latest official version, always check:  http://www.forexfactory.com/showthread.php?t=109305
//
// v1_3 2011-Mar-22 by pips4life, a user at forexfactory.com
// DEV NOTE:  Remove or comment "Debug" lines before release.
//   NOTE: To use this newer version, you may have to "Reset" the variables to get the new defaults that
//     are now different from previous versions, or, you can delete and re-add this indicator to each chart.
//   Previous v1_2 had some problems to display "WAIT4BARS" (which is rare anyway) for timeframes > H1.
//   Changed to a fixed-size font, "Lucida Console", which is necessary to handle the longest string displayed.
//   New variable "TextUsuallyAbovePriceLine" is set to "FALSE" by default.  If False, the time label now 
//     appears BELOW the price line, and very close to the line.  The old versions were above, however,
//     it was sometimes WAY too far away (offscreen) for closeups on charts like M1.  Oftentimes, the label
//     would appear on top of the price line which is harder to read, but with "False", that problem is fixed.
//   New variable "SpreadFactor" (1.0) if changed to > 1 moves the time label farther away from the Bid price line.
//   This version runs every tick, however, for the 2nd-Nth ticks within a single second, the only action taken
//     is to move the existing label, since none of the other calculations need to be redone.
//   This version handles offline charts > 1Month as generated by "P4L PeriodCon.mq4".  The symbol name 
//     and/or period and/or timeshift need to be derived from the chartname.
//     DEV NOTE: VERIFY THE ABOVE
//   New external variable "AdjustWeeklyTimeRemainBy_min" is a hack to fix at least one broker's error with
//     the true start time of weekly bars.  The broker feed SAYS the bars start Sunday 00:00:00 but in fact
//     new bars form on Monday 00:00:00.   A value of 1440 minutes is needed to provide the true countdown left.
//     A possible alternative use for this is to subtract time remaining such that the weekly bar will SAY it
//     will end when the broker closes their feed with Friday's market close.  However, this won't work with every
//     broker, because some of them would report "WAIT4BAR" (negative time) for the beginning of the week.
//
// v1_2 2009-11-13 by pips4life, a user at forexfactory.com
//   Added new "d" for "days" variable. Times on Weekly/Monthly charts now
//     limit "h" (hours) to under 24. New display is:  d_h:mm:yy  (only if d>0).
//     Whereas the old version displayed "387:15:27", the new version is now "16_3:15:27"
//   Added new AutoTimeShiftAdjust feature to support Symbol() names generated by
//     "P4L PeriodCon.mq4".   That other program can generate offline charts with a
//     timeshift (i.e. offset).   When "true", this indicator looks for Symbol() names 
//     using the format "EURUSD+1H" or "EURUSD-2H" where "+1H", "-2H", (or +/- any 
//     number of M/H/D/W/MN) is used as an adjustment to get the correct secondsleft.
// v1_1 2008-10-02 by pips4life, a user at forexfactory.com
//   For H4 and above, display #hours:MM:SS left for the bar. W1 and MN
//   bar times are not accurate though because the weekend hours are included, and
//   Period() does not report an accurate number of seconds/week or seconds/month.
// v1_0 2008-09-24 by pips4life, a user at forexfactory.com
//   A rewrite of CandleTime.mq4 to improve display of MM:SS



//#property copyright "Copyright � 2005, Nick Bilak" // previous author
//#property link      "http://metatrader.50webs.com/"
#property copyright "pips4life"
#property link      "Search http://forexfactory.com for P4L CandleTime.mq4"
#property indicator_chart_window

extern color  TextColor = Chocolate;
extern int    FontSize  = 10; 
extern string FontName = "Lucida Console"; // Was 9,Verdana but spaces were too narrow.  Must have fixed font. Alt: Fixedsys
extern bool   DisplayTimeByTheBar = true ;
extern bool   DisplayTimeComment  = false;
extern bool   TextUsuallyAbovePriceLine  = false; // 
extern double SpreadFactor  = 1.0; // 1.0 is normal. If >1, text is farther away from price line.
extern bool   AutoTimeShiftAdjust = true; // Necessary when used with "P4L PeriodCon.mq4". It adjusts for Symbol() names like: "EURUSD+1H"
                                          // However, change to "false" if your Symbol() name DOES contain a natural "-" or "+" sign.
extern int    AdjustWeeklyTimeRemainBy_min = 0; // At least one broker's Weekly feed has a flakey error.  The weekly bars SAY they begin
                                                // on calendar Sunday at 00:00:00 but in fact the first few hours of Sunday trades are applied to the
                                                // *previous* weekly bar, and then a new weekly bar occurs starting Monday 00:00:00.  The broker's
                                                // weekly bar start time is a lie by exactly 1 day.  Adding a single day of minutes (1440) to the 
                                                // timer provides the true time remaining.  This variable is a hack to fix the broker's error.
                                                // Alternatively, this variable could be used for a different purpose:
                                                // The weekly transition may occur over a weekend.  This adjustment *might* be able to be
                                                // used to count down to the broker's Friday close.  However, that may result in "negative"
                                                // seconds at the beginning of the week.

bool Debug = false;
datetime timeshiftsec = 0;
int period;
double offset;
int AdjustWeeklyTimeRemainBy_sec;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   AdjustWeeklyTimeRemainBy_sec = AdjustWeeklyTimeRemainBy_min*60;
      
   period = Period();
   
   offset = -0.25*Point * SpreadFactor;  //0 appears very close below. Better: "-0.25*Point" is a quarter pip lower.
   
   if (AutoTimeShiftAdjust)
     {
      // The following detects symbol names like "EURUSD+1H,Daily" as generated by "P4L PeriodCon.mq4"
      // The "+1H" string is a timeshift (i.e. offset) that must be factored in.
      // There are extremely few regular "Symbol()" names that have a true "+" or "-" in
      // them, so this method should be sufficient. However, if there's a problem, turn off AutoTimeShiftAdjust.
   
      string symbolOffset;
      string xmult = "";
      int plus = StringFind(Symbol(),"+",0);
      int minus = StringFind(Symbol(),"-",0);
      int uslcx = StringFind(Symbol(),"_x",0);
      int lcx = StringFind(Symbol(),"x",0);
      int secmult = 60;
      
      if ( plus > 0) symbolOffset = StringSubstr(Symbol(),plus);      // The "+" is kept if "plus", dropped if "plus+1".
      else if ( minus > 0) symbolOffset = StringSubstr(Symbol(),minus); // The "-" stays with the string.
      
      // The following is to find the correct period, typically for timeframes > 1-month, as generated by "P4L PeriodCon.mq4".
      if (lcx > 0 && ( plus > 0 || minus > 0 || uslcx > 0)) 
      {
         // Whatever is after the "x" (which includes "_x") is the xmult value:
         xmult = StringSubstr(Symbol(),lcx+1);      // The "x" is dropped using "lcx+1".
         if (StringLen(xmult) >= 1) period = period * StrToInteger(xmult);
      }
      else
      {
         if (period < PERIOD_MN1 && PERIOD_MN1-period < 240) period = PERIOD_MN1 * (PERIOD_MN1-period);
         else if (period < PERIOD_W1 && PERIOD_W1-period < 1040) period = PERIOD_W1 * (PERIOD_W1-period);
         else if (period < PERIOD_D1 && PERIOD_D1-period < 480) period = PERIOD_D1 * (PERIOD_D1-period);
      }
   
      
      if (Debug) Print("Symbol(): ",Symbol()," plus: ",plus," minus: ",minus," symbolOffset: ",symbolOffset," xmult: ",xmult," period: ",period);
      
      if (StringLen(symbolOffset) <= 1) return(0); // str is at least 2 chars, normally would be min, e.g. "+1M"
      
      if (StringFind(symbolOffset,"MN",0) > 0)
        timeshiftsec = secmult * PERIOD_MN1 * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"MN",0)));
      else if (StringFind(symbolOffset,"N",0) > 0)
        timeshiftsec = secmult * PERIOD_MN1 * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"N",0)));
      else if (StringFind(symbolOffset,"W",0) > 0) 
        timeshiftsec = secmult * PERIOD_W1 * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"W",0)));
      else if (StringFind(symbolOffset,"D",0) > 0) 
        timeshiftsec = secmult * PERIOD_D1 * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"D",0)));
      else if (StringFind(symbolOffset,"H",0) > 0) 
        timeshiftsec = secmult * PERIOD_H1 * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"H",0)));
      else if (StringFind(symbolOffset,"M",0) > 0) 
        timeshiftsec = secmult * StrToInteger(StringSubstr(symbolOffset,0,StringFind(symbolOffset,"M",0)));
      //else
      //  timeshiftsec = secmult * StrToInteger(StringSubstr(symbolOffset,0)); //Probably not a good idea to do this.
      
      if (Debug && StringLen(symbolOffset) > 0) Print("timeshiftsec: ",timeshiftsec);
     }
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() 
  {
   ObjectDelete("time");
   return(0);
  } 
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if (TextUsuallyAbovePriceLine) offset = SpreadFactor * MathMax(1*Point, 0.04 * (WindowPriceMax(0) - WindowPriceMin(0))); // To put text ABOVE price-line, BUT, sometimes on top of the line!
   else offset = -1 * SpreadFactor * MathMax(0.25*Point, 0.005 *  (WindowPriceMax(0) - WindowPriceMin(0)));
   
   static datetime last_timecurrent;
   if (TimeCurrent() - last_timecurrent == 0) 
   {
      // Since not even 1 full second has passed since the last tick, just move the existing text to save CPU cycles.
      if (DisplayTimeByTheBar) ObjectMove("time", 0, Time[0], Close[0]+offset);
      //if (DisplayTimeByTheBar && ObjectFind("time") == 0) ObjectMove("time", 0, Time[0], Close[0]+offset);
      return;
   }
   last_timecurrent = TimeCurrent();
   
   int secondsleft = Time[0]+period*60-TimeCurrent()-timeshiftsec;
   if (period == PERIOD_W1) secondsleft = secondsleft + AdjustWeeklyTimeRemainBy_sec;
   
   if (Debug) Print("Time[0]=",Time[0], "  period=",period,"  TimeCurrent()=",TimeCurrent(),"  secondsleft=",secondsleft," timeshiftsec: ",timeshiftsec);
   
   int d,h,m,s;
   s=secondsleft%60;
   m=((secondsleft-s)/60)%60;
   //h=(secondsleft-s-m*60)/3600;
   h=((secondsleft-s-m*60)/3600)%24;
   d=(secondsleft-s-m*60-h*3600)/86400; //1day=86400sec
   
   if( DisplayTimeComment) 
     {
      if (d!=0) Comment( d + " days " + h + " hours " + m + " minutes " + s + " seconds left to bar end");
      else if (h!=0) Comment( h + " hours " + m + " minutes " + s + " seconds left to bar end");
      else Comment( m + " minutes " + s + " seconds left to bar end");
     }
	
	ObjectDelete("time"); // The only reason to delete every time, AFAIK, is to unselect the object in case it was selected by accident.
   
   string displaystr;
   // Note, the prefix of spaces below is intentional and necessary to keep the top-middle-anchored text off of Bar[0]!
   if (secondsleft >= 0 && h==0 && d==0) 
     {
      // FYI, max of ~62 characters
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //            <--00:01
      displaystr = StringConcatenate("            <--",StringSubstr(TimeToStr(secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (secondsleft >= 0 && d>0) 
     {
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //                    <--123_23:00:01
      displaystr = StringConcatenate("                    <--",d,"_",h,":",StringSubstr(TimeToStr(secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (secondsleft >= 0 && h>0) 
     {
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //               <--23:00:01
      displaystr = StringConcatenate("               <--",h,":",StringSubstr(TimeToStr(secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (h==0 && d==0)
     {// When 1 bar is complete, before a new bar is formed the old version displayed hard-to-read negative values. The new is very explicit:
      // FYI, max of ~62 characters
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //                       <--WAIT4BAR:-00:01
      displaystr = StringConcatenate("                       <--WAIT4BAR:-",StringSubstr(TimeToStr(-1*secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (d==0) //h<0
     {
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //                          <--WAIT4BAR:-23:00:01
      displaystr = StringConcatenate("                          <--WAIT4BAR:-",-1*h,":",StringSubstr(TimeToStr(-1*secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else //d<0 AND h<0
     {
      // FYI, max of ~62 characters
      //                            //12345678901234567890123456789012345678901234567890123456789012
      //                            //                              <--WAIT4BAR:-123_23:00:01
      displaystr = StringConcatenate("                              <--WAIT4BAR:-",-1*d,"_",-1*h,":",StringSubstr(TimeToStr(-1*secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   
   if(DisplayTimeByTheBar && ObjectFind("time") < 0) // -1 is < 0 if object does not exist.  FYI, if it was just deleted, might not need to "ObjectFind" it first.
     {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+offset);
      ObjectSetText("time", displaystr, FontSize, FontName, TextColor);
     }
   else if (DisplayTimeByTheBar && ObjectFind("time") == 0)
     {
      ObjectMove("time", 0, Time[0], Close[0]+offset);
      ObjectSetText("time", displaystr, FontSize, FontName, TextColor);
     }


   return(0);
  }
//+------------------------------------------------------------------+

