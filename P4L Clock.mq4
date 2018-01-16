//+--------------------------------------------------------------------------+
//|                                                            P4L Clock.mq4 |
//| New rewrite by: Pips4life, a user at forexfactory.com                    |
//| 2014-Mar-19: v2_12  P4L Clock.mq4                                         |
//|                                                                          |
//| Donations welcome!  Please send via PayPal to pips4life@yahoo.com        |                                                                   |
//|                                                                          |
//| For lastest version: http://www.forexfactory.com/showthread.php?t=109305 |
//|  (See Version History below)                                             |
//|                                                                          |
//| Previous names: Clock_v1_3.mq4, Clock.mq4, ...                           |
//| Previous version:   Jerome,  4xCoder@gmail.com, ...                      |
//|                                                                          |
//+--------------------------------------------------------------------------+
//
// Description:
//    This indicator displays world timezones on a chart, and will change
//    the display color when each market zone is open.  Unlike other versions,
//    this version will correctly account for worldwide ST/DST changes 
//    unique to each timezone.  For example, New York, London, Sydney, etc. 
//    each observe DST on a different calendar, while Tokyo doesn't use 
//    DST at all.  Furthermore, your Local timezone has it's own DST
//    schedule.   None of that matters to this indicator, which handles
//    all the ST/DST changes automatically (Program updates will be necessary
//    if any government legislatively changes the annual ST/DST changeover
//    formula, such as Tokyo which is *considering* observing DST).
//    

#property indicator_chart_window       //Uncomment this line if you prefer a MAIN-window display, AND... change "DrawInWindowNumber = 0" below!
//#property indicator_separate_window  //OR, for SUB-window, comment the above, AND UN-Comment this line for subwindow display, AND... change "DrawInWindowNumber = 1" below!

// Version History:
// NOTE: For latest official version, always check:  http://www.forexfactory.com/showthread.php?t=109305
//
// NOTE to developer: With each new release, update the "_INFO_Version*" external variable below. Search for "DEV" tag below.
// 2014-Mar-19: v2_12 pips4life:
//    Fixed bug related to use of templates in new MT4 builds >=600.  The first tick now deletes any pre-existing background labels
//      which a template might have loaded before or after the indicator.  The proper order-of-label-creation is critical for background labels to work.
//      (The bug cause the background labels to actually cover up the info labels.  Changing chart timeframes was a workaround.  This is an actual fix.)
//    
//    Changed version variable to unique name per release, because templates might have stored old values, masking the fact it's a new release.
//
//    Added a free-will "Donations Welcome" message (PayPal to pips4life@yahoo.com), to offset the considerable effort it takes to maintain 
//      this and other free programs, especially since the new release of (buggy) MT4 builds>=600, which I myself do not even use yet.
//
// 2014-01-30: v2_11 pips4life:
//    New MT4 build 579 (an MT4/5 hybrid) no longer processes labels in alphabetical order, but rather the order of being created.  Therefore, 
//      the "Background_Under_Labels"(true) was covering up all the info labels.  This version should be compatible with both old(v509) and new MT4, but 
//      as the update is still very new, we'll see what happens.  There could be other bugs(??).
//  
//    The 579 compiler gives a "sign mismatch" warning message but this code still works.  To prevent the warning, search below for "sign mismatch" 
//      to find the two lines you can swap, but the change is not backward compatible with <=509.  (Fyi, NO >=579 ex4 files are backward compatible to <=509).
//
// 2011-09-20: v2_10 pips4life:
//    Fixed an error with "Berlin" time introduced by v2_9 changes.
//
// 2011-09-18: v2_9 pips4life:
//    Tokyo market Open/Close hours changed to 9AM-6PM (These are user controllable using variables TokyoLocalOpenHour and TokyoLocalCloseHour)
//    Moscow TZ was updated because it no longer observes any change for ST/DST.  
//    (The commented out values for Cairo -- which is not a supported timezone yet -- were also updated).
//
// 2011-03-22: v2_8 pips4life:
//    Double-checked ST/DST changover dates. Israel was updated, others unchanged.  (Dates do change on occasion).
//    Default LabelCorner changed to 2 (bottom-left).  Was 1 (top-right).   NOTE: THE USER MAY EDIT AND CHANGE BELOW AS DESIRED!
//      The bottom-left covers OLD price bars on occasion.  The top-right tended to cover recent price bars as well as fibo-lines
//      that extended to the far right making them unreadable.
//
//    Default "DoLowSpreadArrows" is now false.  On EURUSD, for example, 0.0 spreads occur frequently with some brokers.
//    Fixed bug that ShowAvgDailyRange was forced to false if ShowAvgPeriodRange was false.  They are now independent,
//      although as before, if both of them are displaying the same identical ADR measurement, one is suppressed.
//
//    Added Bid price to low-spread alert.
//    LowSpread arrows have Background=false, and now occur at the exact current price.
//    Every LowSpread event now creates an arrow.  (Used to be one-arrow-per-bar storing only the last event per bar)
//
// 2010-02-23: v2_7 pips4life:
//    Added "Dubai" timezone.
//    New "ShowRange" to show current bar "High-Low" (in pips)
//    New "ShowPips2open" to show current bar "Close-Open" (in pips) (Here, Close is always the current bar price)
//    New "ShowAvgPeriodRange" (true) to display APR (or A#R, where # is either #minutes, or "H1" or "H4" or...)
//       APR_Period ("Current") can be changed to another Period()
//       APR_Bars (5) can be changed to another lookback-period number
//       APR_LabelShowsMinutes (true) True uses label "A#R" (# is minutes, unless chart-period is H,H4,D,W,MN or non-standard H2,H8)
//            False displays "APR" (unless H,H4,D,W,MN which are then: AHR, AH4, ADR, AWR, AMNR)
//    New "ShowAvgDailyRange" (true) to display ADR. Also, set lookback-period with "ADR_Bars"
//       Note, the ADR display is suppressed IF the APR is already the Daily with the same lookback-period.
//    Note: Both APR and ADR display the lookback-period between parenthesis. Examples:
//          APR(5)  (if APR_LabelShowsMinutes=false) 
//      or: A15R(5) (if APR_LabelShowsMinutes=true on M15 chart)
//      Daily:  ADR(5)
//    Renamed unclear "Background_Name_Pixels" to "Background_AddWidth_Pixels" (controls the width)
//    Fixed bugs:
//    * Removed a "DEBUG" popup Alert accidentally left in last version.
//    * Reverse of labels had improper count which put the new labels 
//        offscreen IF OverrideShowALL && ReverseLabelOrder were both true.
//    * Some of the new values were blank if their individual Show... vars. were false but OverrideShowALL=true
//    Known-issue(s):
//    * The ADR (or APR if timeframe is not "Current") may give the wrong value if the
//    history data is stale.  Might need to force a refresh of the data in the OTHER timeframes (Daily, and the APR_Period)
//    
// 2010-01-21: v2_6 pips4life:
//    New "ShowPipSpread" (Ask-Bid) (true) in pips was added per request from FF user Peter-FX.
//    Variable "AutoPipTenthsFor5DigitBroker" (true) auto-multiplies extra-digit-broker pips by 1/10th.
//    Variable "LowSpreadHighlightThreshold=0.0".  If spread <= threshold, LOW-spread is highlighted.
//    If DLL's are not enabled, an alert is issued before the indicator is stopped by MT4.
//    New "ShowBidPrice" (true) will display the current Bid price. Color indicates price vs. lastprice.
//    New "ShowVolume" (true) will display the most recent bar's volume. Value indicates vol vs. last-bar-vol.
//      Also, the label changes to "*HiVol*" (and the color changes) whenever the volume 
//      is >= to (external variables) "Above_The_Nth_Highest_Volume" (12) out of the last "HighVolumeBarsCompared" (120)
//    Variables HigherPriceVolumeColor & LowerPriceVolumeColor control what colors the price 
//      and volume values use.
//    New Alert!  Variable "DoHighVolumeAlerts" (false).  If true and if *HiVol*, then a popup alert occurs (once per bar)
//    New Alert!  Variable "DoLowSpreadAlerts" (true).  If true and if spread <= LowSpreadHighlightThreshold, then a
//       popup alert occurs (once per bar). 
//    New Arrows!  Variable "DoLowSpreadArrows" (true).  If true and if spread <= LowSpreadHighlightThreshold, then a
//       single-Arrow-per-bar is created, however, it is adjusted with each new tick.
//    Note: Regardless of DoLowSpreadArrows or DoLowSpreadAlerts, you are expected to ALSO change
//        the LowSpreadHighlightThreshold value to above 0.0 in order to get low-spread Alerts and/or Arrows.
//    Since LowSpread arrows cannot be recreated from history, they do NOT delete from the chart unless
//       you change variable "Delete_Old_SpreadArrows" to true.
//
//    NOTE: As always, users can customize this code and change the variable defaults as you prefer.
//      Display only what you want to see, in the format you want to see it.
//
// 2010-01-14: v2_5 pips4life:
//    New feature, "Background_Under_Labels" (true) creates a rectangle (actually several) beneath the
//       labels.  If your F8 chart property "Chart on foreground" is un-checked, then the background
//       rectangle will hide the price info and many other lines/objects that make the labels hard
//       to read.  Note: Other objects with their Background property = false are at the same priority
//       as these labels, so they might still clutter the labels. Change those others to "true" to resolve.
//       With this new Background=true, consider using LabelCorner=2 (bottom-left). Hiding past price info
//       is usually not a problem yet the clock labels are readable.  
//       (The idea to create "rectangles" using OBJ_LABEL with the Webdings font, the letter "g" and a
//       large fontsize was suggested by Traderathome of FF. (Thanks) ).
//    Variable "Background_Color" controls the color.  It is suggested to NOT be the same as your normal 
//       background color so as to make it obvious when price bars/info may be obscured.
//    Variable "Background_AddWidth_Pixels" controls the width of the rectangle but may need some fine tuning
//       depending on which options you use as defaults, or, if you rename a timezone name to a fairly 
//       long name (which may require enlarging the rectangle). (e.g. "China" -> "Hong Kong").
// 2009-11-29: v2_4 pips4life:
//    Made several changes suggested by Traderathome of FF. (Thanks).
//    New "Indicator_On" variable to turn off labels without removing indicator.
//    Added "DrawInWindowNumber" variable.  User *might* want to use "indicator_separate_window" above
//       AND change default DrawInWindowNumber = 1 (instead of 0, main window). (See below).
//    Added variables: FontName, TimezoneFontSize, ClockFontSize, LineSpacing
//    Added variables to control horizontal offset of clock and timezone labels, and vertical offset.
//    Reworked auto-horizontal adjustment based on: ShowBarTime, AM/PM, bar-seconds, time-seconds, and Period()
//    The order of labels is the same regardless of LabelCorner, however, ReverseLabelOrder can swap if desired.
//    Renamed "Seattle" to "Pacific".
//    Added TZ info for Central(US), and Mountain(US).
//    Added TZ info for China (same TZ as Hong Kong, Singapore, Taipei, and Perth)
//    Added TZ info for Brazil, Mexico, Israel, Helsinki, India, Jakarta
//    NOTE: Brazil's ST/DST appears to be a specific date, not an annual formula. Update the data EVERY YEAR! (last done Nov 2009)
//    New "OverrideShowALL" variable to turn on every timezone.
//    Made some trivial hour-of-day corrections to Moscow, Berlin TZ's (ST/DST changeover was off by an hour).
//       All other TZ data was verified unchanged since last release.
//    Turned several uncommon timezones off by default.
//    Changed colors.  Compatible with either very light or very dark. Alternate choices are given.
//    Turned on display of seconds by default.  It's very helpful to calibrate your localtime vs. Broker time.
//    MM:30 timezones can now use Broker_MMSS_Is_Gold_Standard (e.g. India).
//    Timezones and clocks are generally closer together and closer to the chart edges than before. User can customize if needed.
// 2008-09-28: v2_3  pips4life:
//    Added Auckland, Moscow, Berlin, Pacific (was Seattle) for Jodie(jhp2025). Default VerticalOffsetPixels is now 10.
// 2008-09-28: v2_2  pips4life: Turns out the ST/DST crossover dates are good
//    until any market zone country legistlatively changes their dates.
//    No annual update is necessary!  I updated the comments accordingly.
//    I moved the init() block before start for easier readability of the flow.
//    Mostly cosmetic changes.
// 2008-09-27: v2_1  pips4life: 
//    Modified Sydney changes NuckingFuts made. (Thx for the prelim work).
//    The original world time ST/DST calculation method which I had not looked
//    at enough to understand is fatally flawed, so...all that is rewritten! 
//    The new method uses true clock data and  *should* work from every timezone, 
//    and *should* handle ST/DST changes for each TZ, independently,
//    regardless of your Local TS and/or ST/DST status. (Depends on Windows
//    being correct, however). CONSEQUENTLY, the changes require ANNUAL UPDATES
//    to get the world ST/DST changeover dates!! Check this thread for updates:
//       http://forexfactory.com/showthread.php?t=109305
//    If no update, in JUST ONE CHART (!!), set If_TZ_ChangesSetTrueOn_ONE_chart=TRUE 
//    and follow the directions...  Do NOT compile the code with that variable=TRUE!!
//    Added Weekend_Test_Mode so simulated ticks show true times over the weekend.
// 2008-09-25:  mods by NuckingFuts
//    Fixed timezones with no daylight savings
//    Added Sydney
// 2008-09-24:  v2_0 "P4L Clock.mq4" by pips4life @ forexfactory.com 
//    Different highlight color(s) used for Market Open hours (Assuming 8AM - 5PM Local market hours)
//    Added seconds display, and used method such that single digits look better (":09" not ":9")
//    Added "Broker_MMSS_Is_Gold_Standard" to adjust (by a few seconds or minutes) the market hours, because
//      as if often the case, the Local computer clock may be off by a small amount.
//    Two extern variables to control display of seconds: bool Display_Time_With_Seconds, int Display_Bar_With_Seconds.
//    When Display_Bar_With_Seconds=2 (Auto mode), seconds display when < 2min, OR, if Display_Time_With_Seconds=True.
//    "Bar:" changed to "Bar Left:" (remaining time). Also, it will say "wait4bar" (rather than to display
//      a negative number as would have occurred) during periods of low activity until a new bar is formed.
//    "Suppress_Bar_HH_Below_H1" displays only [MM:SS] for H1 and below since HH in [HH:MM:SS] is always "00" 
//    Adjusted pixel distance between labels depending on options.
//    "Bar Left:" time does not display above D1 charts.  A future enhancement (not planned) could report DD_HH:MM[:SS]
//    Added Show_DIBS_London clock with user-setable start/stop hour relative to London (6AM and 7PM at present).
//
// 2008-??   v1_4  Was NOT an indicator, rather a script; however, it didn't handle new barstr (Time[0] stuck), nor could
//    one change timeframes without having to "Disable" and re-add the script. May have been more CPU intensive??
// 2008-??   v1_3 and earlier.  Details can be found on the web.

// FUTURE PLANS:
//

//#property copyright "Jerome" //previous author
//#property link      "4xCoder@gmail.com"
#property copyright "pips4life" //P4L Clock.mq4 is rewrite of Clock.mq4, Clock_v1_3.mq4
#property link      "http://www.forexfactory.com/pips4life"

#include <stdlib.mqh>

#import "kernel32.dll"
// For function documentation, see: http://msdn.microsoft.com/en-us/library/ms725473(VS.85).aspx
void GetLocalTime(int& LocalTimeArray[]);
void GetSystemTime(int& systemTimeArray[]);
int  GetTimeZoneInformation(int& LocalTZInfoArray[]);
bool SystemTimeToTzSpecificLocalTime(int& targetTZinfoArray[], int& systemTimeArray[], int& targetTimeArray[]);
//bool TzSpecificLocalTimeToSystemTime(int& targetTZinfoArray[], int& LocalTimeArray[], int& targetTimeArray[]);
#import

//------------------------------------------------------------------
// Instructions
//    Copy this file to:  C:\Program Files\--your-MT4-directory-here---\experts\indicators
//    Review the "extern" variable settings below. Change as desired, then restart MT4 or do "Compile" in MetaEditor.
//    
//    Open a chart and add this indicator. Assuming you compiled with the "extern" defaults you prefer,
//    you shouldn't need to change any of the defaults, *except* one: (FOR "P4L Clock.mq4" ONLY!) 
//    This Version *requires* "Allow DLL Imports" to be set under the Common Tab when you add this to a chart!
//    FYI, the DLLs retrieve the Local CPU clock time and timezone info as well as world timezone info.
//    A word of caution: You can see my entire source code and what the DLL's do which should be harmless.
//    Personally, I *never* enable DLL's on any binary .EX4 file because I don't trust what the program might do.  
//    For all I know, it could be sending out very private information about me or my account! 
//
//    NOTE! The world timezone times are only as accurate as your LOCAL CPU CLOCK or, if variable
//    Broker_MMSS_Is_Gold_Standard=True, your Broker's clock! At least verify your own clock and set it accurately!
//    NOTE! Your Broker time is independent of your Local CPU clock and, though unlikely, may change at any time.
// DISCLAIMER: Use completely at your own risk!! Author(s) accept no liabilities whatsoever!


//---- input parameters -- FYI, THE USER MAY CUSTOMIZE THESE EXTERN VARIABLE SETTINGS AS DESIRED:
extern string   _Version_v2_12__2014_Mar_19   = "Donations welcome! PayPal pips4life@yahoo.com"; // DEV code version
extern bool     Indicator_On                  = true;       // Easy method to disable without removing indicator.
extern string   _INFO_Set_your_computer_clock = "Accuracy depends on YOUR CPU CLOCK!!";
extern string   _INFO_Verify_times_with_URL   = "www.worldtimezone.net/index24.php";
extern string   _INFO_Re_LabelCorner          = "0=Top-left, 1=TR, 2=BL, 3=BR";
extern int      LabelCorner                   = 2;          // 0=top-left; 1=top-right; 2=bottom-left; 3=bottom-right
                                                            // NEW: 2 may now be best when Background_Under_Labels=true; Also good: top-right but in WindowNumber=1
extern int      DrawInWindowNumber            = 0;          // 0=main chart window. >=1 are sub-windows BUT they must already exist (e.g. add RSI to create a sub-window 1).
extern bool     ReverseLabelOrder             = false;      // false = Normal top-to-bottom order: Bar,Broker, then NZ to Asia to Europe to US
extern int      VerticalOffsetPixels          = 5;          // 5 pixels from top (or bottom) to show the 1st clock. Note (min. of 12 is forced if LabelCorner=0,top-left,due to chart text)
extern int      HorizClockOffsetPixels        = 5;          // 5 pixels from left (or right) to show the 1st clock
extern int      HorizTimezoneOffsetPixels     = 42;         // 42 pixels from left (or right) to show the 1st timezone
//========= v1_4 new colors and fonts
// IMO, these colors and sizes work well for Black AND White background charts. However, alternate colors/fonts/sizes were suggested by Traderathome (see below).
extern color    TimezoneColor                 = Green;      // Green. Color of label, off-hours.  Alt: Blk: LimeGreen      Wht: SlateGray or C'103,118,133'
extern color    ClockColor                    = SteelBlue;  // SteelBlue. Color of clock, off-hours    Blk: CornflowerBlue Wht: Blue
extern color    LabelMktOpenColor             = Red;        // Red. Color of label, market-open        Blk: Red            Wht: MidnightBlue
extern color    ClockMktOpenColor             = OrangeRed;  // OrangeRed. Color of clock, market-open  Blk: DarkOrange     Wht: Crimson
extern color    HigherPriceVolumeColor        = SteelBlue;
extern color    LowerPriceVolumeColor         = Red;
extern color    LowSpreadArrowColor           = HotPink;
extern int      LowSpreadArrowCode            = 119;        // 119 = tiny diamond
//
extern string   FontName                      = "Arial";    // "Arial" Wht-or-Blk: "Arial Bold" or "Arial" are good choices.
extern int      TimezoneFontSize              = 10;         // 10 Wht-or-Blk: 10, or Blk: 9
extern int      ClockFontSize                 = 9;          // 9
extern int      LineSpacing                   = 14;         // 14  or 13
//==========
extern bool     Display_Times_With_AMPM       = false;      // True=show 12 hour AM/PM time, false=show 24 hour time
extern bool 	 Display_Time_With_Seconds     = true ;      // Turn on seconds for timezone clocks.
//==========
extern bool     Highlight_Market_Open         = true ;      // When true, the above market-open colors are used between 8AM - 5PM (market Local) 
extern int      LocalOpenHour                 = 8;          // Almost all local markets are assumed open 8AM to 5PM
extern int      LocalCloseHour                = 17;
extern int      SydneyLocalOpenHour           = 7;          // Sydney market Local is 7am-4pm per FF Aussie user "NuckingFuts"
extern int      SydneyLocalCloseHour          = 16;
extern int      TokyoLocalOpenHour            = 9;          // Tokyo market Local is 9am-6pm per FF MarketHours tool and several users.
extern int      TokyoLocalCloseHour           = 18;
extern string   _INFO_Re_Bar_With_Seconds     = "0=No; 1=Yes; 2=Auto"; // Auto is: if < 120 seconds or if Display_Time_With_Seconds is true -- arguably a bit too clever, so "1" is default.
extern int  	 Display_Bar_With_Seconds      = 1;          // Control "Bar Left:" to display ":SS" independently from other times.
extern bool     Suppress_Bar_HH_Below_H1      = true ;      // For "Bar Left:" on H1 and below, display only [MM:SS] since HH in [HH:MM:SS] is always "00"
extern bool     Broker_MMSS_Is_Gold_Standard  = true ;      // If true, make a correction up to a few seconds/minutes vs. your Local CPU clock. FYI, we don't know Broker TZ/DST info but don't care.
//=========
extern int      HighVolumeBarsCompared        = 120;        // How many bars to consider when looking for high volume. 
extern int      Above_The_Nth_Highest_Volume  = 12;         // Flag if volume is >= the Nth highest volume of the last HighVolumeBarsCompared. Highlighted with red label "*HiVol*"
extern bool     DoHighVolumeAlerts            = false;      // Popup alert if High Volume Bar 
//==========
extern bool     AutoPipTenthsFor5DigitBroker  = true ;      // If true, extra-digit-brokers "pips" multiplied by 1/10th to get standard pips.
extern string   _INFO_MUST_change_LowSpread   = "...threshold to >0 pips for low-spread";
extern double   LowSpreadHighlightThreshold   = 0.0;        // Any pip spread <+ threshold value is highlighted using ClockMktOpenColor.
extern bool     DoLowSpreadAlerts             = false;      // Popup alert if Low Spread if price >= threshold (default 0.0)
extern bool     DoLowSpreadArrows             = false;      // Mark chart with an arrow if Low Spread
extern bool     Delete_Old_SpreadArrows       = false;      // False, because Spread Arrows can NOT be recreated from history! They're based on live tick data only. Once deleted, they're gone!
//==========
extern string   _INFO_Choose_what_to_display  = "=================";
extern bool     OverrideShowALL               = false;
extern bool     ShowBarTime                   = true ; //However, BarTime only shows if <= PERIOD_D1
extern bool     ShowBroker                    = true ;
extern bool     ShowAuckland                  = false;
extern bool     ShowSydney                    = true ;
extern bool     ShowTokyo                     = true ;
extern bool     ShowChina                     = true ;
extern bool     ShowJakarta                   = false;
extern bool     ShowIndia                     = false;
extern bool     ShowDubai                     = false;
extern bool     ShowMoscow                    = false;
extern bool     ShowIsrael                    = false;
extern bool     ShowHelsinki                  = false;
extern bool     ShowBerlin                    = true;
extern bool 	 ShowLondon                    = true ;
extern bool 	 ShowUTC_GMT                   = true ; // FYI, UTC_GMT does not change with Daylight Savings Time. In winter, London=UTC; in summer, London=UTC+1. Also, UTC does not highlight "market" hours.
extern bool     ShowBrazil                    = false;
extern bool 	 ShowNewYork                   = true ;
extern bool     ShowCentral                   = false;
extern bool     ShowMexico                    = false;
extern bool     ShowMountain                  = false;
extern bool 	 ShowPacific                   = false;
extern bool     ShowLocal                     = true ; // FYI, this is your Local computer clock. For accuracy, right-mouse on Clock -> Adjust Date/Time ->Internet Time->Update Now
extern bool     ShowPipSpread                 = true ; 
extern bool     ShowBidPrice                  = true ; // Bid price
extern bool     ShowVolume                    = true ; // Note, in MT4 "tick" volume is not the same as true transaction-volume (which isn't available in FX)
extern bool     ShowRange                     = true ; // Current bar High-Low in pips.
extern bool     ShowPips2open                 = true ; // Current bar Open-to-(current)Close in pips.
extern bool     ShowAvgPeriodRange            = true ; // In pips. Any period, but if THIS period, then the color changes to indicate the range is above/below previous bar.
extern bool     ShowAvgDailyRange             = true ; // In pips. DAILY, but if ShowAvgPeriodRange is already displaying Daily, this one is suppressed.
extern string   APR_Period                    = "Current"; //Current,0  or  D,D1,Daily,M1440,1440  or  H,H1,M60,60  or  M#,#  or  ... etc.
extern int      APR_Bars                      = 5;     // Usually 1,5,10,20,...   Note: A "trick" value of "1" gives the PREVIOUS Bar's range
extern int      ADR_Bars                      = 5;     // Usually 1,5,10,20,...   Note: A "trick" value of "1" gives the PREVIOUS (Daily) Bar's range
extern bool     APR_LabelShowsMinutes         = true ; // For APR, when Period is H,Daily,Weekly,Monthly, the "P" is H,D,W,MN respectively. BUT, for others, if true, "P" is used, else "#" where #=Period()

extern bool     Show_DIBS_London              = false; // FYI, for DIBS method, see http://www.forexfactory.com/showthread.php?t=86766
extern string   _For_DIBS_info_go_to__        = "www.forexfactory.com/showthread.php?t=86766";
extern int      DIBS_LondonOpenHour           = 6;     // DIBS relative to London Local time. 6 ~= 2 hours before London ~= Chicago midnight. (Follows London DST)
extern int      DIBS_LondonCloseHour          = 15;    // MAX is 23!! Subjective choice. Change as desired. 9 hours length?? (Do NOT use # < DIBS_LondonOpenHour). 
extern bool     Weekend_Test_Mode             = false; // Normally false. True forces Broker_MMSS_Is_Gold_Standard=false as well. Clock updates are >=once-per-Broker-second but on weekends the Broker clock freezes
//=========
extern int      Background_AddWidth_Pixels    = 47;    // Controls how wide the background beneath the labels is. "* New York" is the widest so far.
extern color    Background_Color              = Lavender; // Note: I prefer DIFFERENT from regular chart Background to know when prices are obscured!
extern bool     Background_Under_Labels       = true ; // Put a background beneath the labels.  The timezones stand out and are less obscured by price bars, lines, etc.
                                                       // NOTE: Use F8 -> Common tab -> Turn OFF "Chart on foreground". Price bars will then be UNDER the label background!


// FYI: If a market zone changes ST/DST dates (e.g. if Tokyo adopts DST), or, to add a new market timezone to this program,
//   you need to obtain the timezone ST/DST crossover date information.  To do that, add "extern" before this variable but leave it FALSE!
//  Add indicator to one chart and set this variable True ON ONE CHART ONLY, then follow the directions...
//
// WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!
// This variable controls writing information to a file, but we do NOT want multiple chart windows EACH writing to the file!!!! Therefore...
// you should NEVER compile this variable as TRUE!  Rather, follow the directions below...
//extern 
bool  New_DST_SetTrueOnONEchart   = FALSE; // WARNING! Do NOT compile this as TRUE! Rather, insert "extern" before "bool", compile, then change JUST ONE CHART value to TRUE for instructions!


// This was external but really isn't necessary at all. Every "Local" clock ought to be 
//   within 15min of what is expected for Broker time. The freature was removed.
//bool     SupportAlso_HH_30_TimeZones   = true;  // If true a TZ on HH_30 (e.g. India, Caracas) can use Broker_HHMM_Is_Gold_Standard=true-or-false as desired.
                                                       // If false, a NORMAL TZ cannot adjust to Broker time more than 15 minutes different from your Local clock.

//
string backName = "_P4L ClockBackground"; // The leading "_" is critical. It is alphabetically before the other labels on top of the background label.
      
//---- buffers

int    AucklandTZInfoArray[43];
int    SydneyTZInfoArray[43];
int    TokyoTZInfoArray[43];
int    ChinaTZInfoArray[43];
int    JakartaTZInfoArray[43];
int    IndiaTZInfoArray[43];
int    DubaiTZInfoArray[43];
int    MoscowTZInfoArray[43];
int    IsraelTZInfoArray[43];
int    HelsinkiTZInfoArray[43];
int    BerlinTZInfoArray[43];
int    LondonTZInfoArray[43];
int    BrazilTZInfoArray[43];
int    NewYorkTZInfoArray[43];
int    CentralTZInfoArray[43];
int    MexicoTZInfoArray[43];
int    MountainTZInfoArray[43];
int    PacificTZInfoArray[43];
int    LocalTZInfoArray[43];


bool FLAG_LABELEXISTS = false;
bool FLAG_DEINIT = false;

int pipdigits = 0;
string pipstring = " p "; // intentional trailing space makes it more readable, but only for NON-extra-digit-brokers.
double pointdiv10;
double myPoint;
double lastprice = 0;
double lastapr;
datetime lastapradrtime = 0;
double lastadr;
int lastBars=0;
int lastBars_spread=0;
int lastBars_sp_arrows=0;
int lastBars_volume=0;
string periodstr;
bool obj_created=false;
int volarray[];

int apr_timeframe;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   FLAG_DEINIT = false;
   
   if (getPoint(AutoPipTenthsFor5DigitBroker) / Point == 10) 
   {
      pipdigits = 1; // Usually 1, but 10 on extra-digit-brokers.
      //pipstring = " p"; // Possibly use " p" WITHOUT trailing space due to width.
   }
   
   pointdiv10 = Point/10;
   myPoint = getPoint(AutoPipTenthsFor5DigitBroker);
   
   //APR_PeriodTimeframe  CONVERT string to int here:
   apr_timeframe=MathMax(Period(),stringTimeframeToPeriod(APR_Period));
      
   if (Delete_Old_SpreadArrows) deleteArrows();
   
   if ( !IsDllsAllowed() ) 
   {
      Alert( WindowExpertName(),": ERROR. DLLs are disabled. To enable, select 'Allow DLL Imports' in the Common Tab of indicator" );
      //return(1); //NO. With the first DLL call below, the program will exit (and stop) after one alert
   }
   
   // Variable New_DST_SetTrueOnONEchart is used by programmers to add a new timezone to the code.  See above.
   if (New_DST_SetTrueOnONEchart) writeLocalTZInfoToFile("tzdata.csv", false); // False obtains only the limited data which is needed.
   
   GetAllTimeZoneInfo();
      //AucklandTZInfoArray, SydneyTZInfoArray, TokyoTZInfoArray, ChinaTZInfoArray, JakartaTZInfoArray, 
      //IndiaTZInfoArray, DubaiTZInfoArray, MoscowTZInfoArray, IsraelTZInfoArray, HelsinkiTZInfoArray, BerlinTZInfoArray, LondonTZInfoArray, BrazilTZInfoArray, 
      //NewYorkTZInfoArray, CentralTZInfoArray, MexicoTZInfoArray, MountainTZInfoArray, PacificTZInfoArray, LocalTZInfoArray);
   

   ArrayResize(volarray,HighVolumeBarsCompared);
   ArrayInitialize(volarray,0);
   
   int period = Period();
   periodstr = StringConcatenate("M",period); // The default
   int TFlist[] = {60, 120, 240, 480, 1440, 10080, 43200, 43200}; // Common TFs at >= H1 + 1 extra. Compare TFlist[0]... TFlist[#]. Extra in case TFlist[#+1] is referenced
   string TFlistStr[] = {"H1", "H2", "H4", "H8", "Daily", "Weekly", "Monthly", "Monthly"};
   for (int k = 0; k <= 6; k++)
   {
      if (period != TFlist[k]) continue;
      periodstr = TFlistStr[k];
      break;
   }


   string short_name="P4L Clock   ";
   if (Indicator_On == false) short_name=("P4L Clock  -Off   ");
   IndicatorShortName(short_name);   // This only matters if indicator_separate_window was used. 
   //----
   return(0);
} // end of init()

void createLabels()
{
   int top=VerticalOffsetPixels;
   if (LabelCorner == 0) top = MathMax(12,top);  // At least 12 pixels required to get beneath the top-left chart label.
   int left = HorizTimezoneOffsetPixels;
   int right = HorizClockOffsetPixels;
   
   // Below are some auto-adjustments BASED ON ORIGINAL DEFAULTS. User can manually force other values using the 3 Offsets above.
   int adjustLeft = 0; //Basic 5 characters, HH:MM, no adjustment needed when using program defaults.
   if (ShowBarTime && Display_Bar_With_Seconds >= 1 && Period() <= PERIOD_D1 && (Period() > PERIOD_H1 || !Suppress_Bar_HH_Below_H1) ) adjustLeft = 37; // Up to 5+7=12 characters WIDE [ HH:MM:SS ]
   else if (ShowBarTime && Period() <= PERIOD_D1) adjustLeft = 16; // 5+4=9 characters [ HH:MM ]
   else if (ShowBidPrice || ShowVolume) adjustLeft = 14; // 7 characters 1.34567 or 123.567
   if (Display_Times_With_AMPM)
   {
      if (!Display_Time_With_Seconds) adjustLeft = MathMax(adjustLeft,26); // 5+3=8 characters HH:MM AM
      else adjustLeft = MathMax(adjustLeft,40); // 5+6=11 characters HH:MM:SS AM
   }
   else if (Display_Time_With_Seconds) adjustLeft = MathMax(adjustLeft,18); // 5+3=8 characters  HH:MM:SS
   
   if (ShowRange ||ShowPips2open || ShowAvgPeriodRange || ShowAvgDailyRange)
   {
      if (pipdigits == 1) adjustLeft = MathMax(adjustLeft,26);
      else adjustLeft = MathMax(adjustLeft,16);
   }
   
   // User can use a smaller HorizTimezoneOffsetPixels to shrink the width but the default is theoretically the minimum.
   // FYI, getting all the above adjustments right is a big pain because of all the permutations and subtleties.
   // The values are by no means perfect.  If characters overlap, that's a sure sign something needs changing.
   
   //Alert("DEBUG:  adjustLeft: ",adjustLeft); // This helps a LOT when fine-tuning adjustLeft values above.
   
   left = left + adjustLeft;
   
   int offset=0;
   int revoffset=0;
   
   if (OverrideShowALL)
   {
      ShowBarTime = true;
      ShowBroker = true;
      ShowAuckland = true;
      ShowSydney = true;
      ShowTokyo = true;
      ShowChina = true;
      ShowJakarta = true;
      ShowIndia = true;
      ShowDubai = true;
      ShowMoscow = true;
      ShowIsrael = true;
      ShowHelsinki = true;
      ShowBerlin = true;
      Show_DIBS_London = true;
      ShowLondon = true;
      ShowUTC_GMT = true;
      ShowBrazil = true;
      ShowNewYork = true;
      ShowCentral = true;
      ShowMexico = true;
      ShowMountain = true;
      ShowPacific = true;
      ShowLocal = true;
      ShowPipSpread = true;
      ShowBidPrice = true;
      ShowVolume = true;
      ShowRange = true;
      ShowPips2open = true;
      ShowAvgPeriodRange = true;
      ShowAvgDailyRange = true;
   }
     
   if ( (ReverseLabelOrder && LabelCorner <= 1) || (!ReverseLabelOrder && LabelCorner >= 2)) //0=Top-left, 1=TR, 2=BL, 3=BR
   {
      int count = 0;
      if (ShowBarTime) count++;
      if (ShowBroker) count++;
      if (ShowAuckland) count++;
      if (ShowSydney) count++;
      if (ShowTokyo) count++;
      if (ShowChina) count++;
      if (ShowJakarta) count++;
      if (ShowIndia) count++;
      if (ShowDubai) count++;
      if (ShowMoscow) count++;
      if (ShowIsrael) count++;
      if (ShowHelsinki) count++;
      if (ShowBerlin) count++;
      if (Show_DIBS_London) count++;
      if (ShowLondon) count++;
      if (ShowUTC_GMT) count++;
      if (ShowBrazil) count++;
      if (ShowNewYork) count++;
      if (ShowCentral) count++;
      if (ShowMexico) count++;
      if (ShowMountain) count++;
      if (ShowPacific) count++;
      if (ShowLocal) count++;
      if (ShowPipSpread) count++;
      if (ShowBidPrice) count++;
      if (ShowVolume) count++;
      if (ShowRange) count++;
      if (ShowPips2open) count++;
      if (ShowAvgPeriodRange) count++;
      if (ShowAvgDailyRange) count++;
            
      count--; // Decrement by 1 for the first label.
      if (ShowBarTime && Period() > PERIOD_D1) count--; // Decrement if this won't be displayed due to Period()
      if ((ShowAvgPeriodRange && ShowAvgDailyRange) && apr_timeframe == PERIOD_D1 && APR_Bars == ADR_Bars ) count--; // Decrement if APR is already the same ADR
      LineSpacing = MathAbs(LineSpacing); 
      offset = LineSpacing * count;
      revoffset = offset + LineSpacing; //adjust revoffset to 1 more
      LineSpacing = -1 * MathAbs(LineSpacing); //Just in case init() is run twice, use MathAbs to be sure final value is negative.
   } // end of if (... reverselabels)
   
   if (Background_Under_Labels)
   {
      // Worked without this up to build 509, but in >=579, must pre-create the background labels before all others.
      // Further below sets the properties
      if (ObjectFind(backName) == -1) ObjectCreate(backName, OBJ_LABEL, DrawInWindowNumber, 0, 0, 0, 0);
      for (int k=1; k<=8 ; k++ ) { if (ObjectFind(backName+k) == -1) ObjectCreate(backName+k, OBJ_LABEL, DrawInWindowNumber, 0, 0, 0, 0); }
   }
   
   if(ShowBarTime && Period() <= PERIOD_D1)
   {
      ObjectMakeLabel( "barl", left, top+offset );
      ObjectMakeLabel( "bart", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowBroker)
   {
      ObjectMakeLabel( "Brokerl", left, top+offset );
      ObjectMakeLabel( "Brokert", right, top+offset );
     	offset+=LineSpacing;
   }
  	// Begin world timezones, listed IN ORDER!
   if(ShowAuckland)
   {
   	ObjectMakeLabel( "Aucklandl", left, top+offset );
   	ObjectMakeLabel( "Aucklandt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowSydney)
   {
   	ObjectMakeLabel( "Sydneyl", left, top+offset );
   	ObjectMakeLabel( "Sydneyt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowTokyo)
   {
   	ObjectMakeLabel( "Tokyol", left, top+offset );
   	ObjectMakeLabel( "Tokyot", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowChina)
   {
   	ObjectMakeLabel( "Chinal", left, top+offset );
   	ObjectMakeLabel( "Chinat", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowJakarta)
   {
   	ObjectMakeLabel( "Jakartal", left, top+offset );
   	ObjectMakeLabel( "Jakartat", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowIndia)
   {
   	ObjectMakeLabel( "Indial", left, top+offset );
   	ObjectMakeLabel( "Indiat", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowDubai)
   {
   	ObjectMakeLabel( "Dubail", left, top+offset );
   	ObjectMakeLabel( "Dubait", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowMoscow)
   {
   	ObjectMakeLabel( "Moscowl", left, top+offset );
   	ObjectMakeLabel( "Moscowt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowIsrael)
   {
   	ObjectMakeLabel( "Israell", left, top+offset );
   	ObjectMakeLabel( "Israelt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowHelsinki)
   {
   	ObjectMakeLabel( "Helsinkil", left, top+offset );
   	ObjectMakeLabel( "Helsinkit", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowBerlin)
   {
   	ObjectMakeLabel( "Berlinl", left, top+offset );
   	ObjectMakeLabel( "Berlint", right, top+offset );
   	offset+=LineSpacing;
   }
   if ( Show_DIBS_London) 
   {
      ObjectMakeLabel( "dibsl", left, top+offset );
      ObjectMakeLabel( "dibst", right, top+offset );
      offset+=LineSpacing;
   }
   if(ShowLondon)
   {
	   ObjectMakeLabel( "Londonl", left, top+offset );
   	ObjectMakeLabel( "Londont", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowUTC_GMT)
   {
   	ObjectMakeLabel( "utcl", left, top+offset );
   	ObjectMakeLabel( "utct", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowBrazil)
   {
   	ObjectMakeLabel( "Brazill", left, top+offset );
   	ObjectMakeLabel( "Brazilt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowNewYork)
   {
	   ObjectMakeLabel( "NewYorkl", left, top+offset );
   	ObjectMakeLabel( "NewYorkt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowCentral)
   {
   	ObjectMakeLabel( "Centrall", left, top+offset );
   	ObjectMakeLabel( "Centralt", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowMexico)
   {
   	ObjectMakeLabel( "Mexicol", left, top+offset );
   	ObjectMakeLabel( "Mexicot", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowMountain)
   {
   	ObjectMakeLabel( "Mountainl", left, top+offset );
   	ObjectMakeLabel( "Mountaint", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowPacific)
   {
	   ObjectMakeLabel( "Pacificl", left, top+offset );
   	ObjectMakeLabel( "Pacifict", right, top+offset );
   	offset+=LineSpacing;
   }
   if(ShowLocal)
   {
      ObjectMakeLabel( "Locall", left, top+offset );
      ObjectMakeLabel( "Localt", right, top+offset );
      offset+=LineSpacing;
   }
   
   if(ShowPipSpread)
   {
      ObjectMakeLabel( "spreadl", left, top+offset );
      ObjectMakeLabel( "spreadt", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowBidPrice)
   {
      ObjectMakeLabel( "pricel", left, top+offset );
      ObjectMakeLabel( "pricet", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowVolume)
   {
      ObjectMakeLabel( "volumel", left, top+offset );
      ObjectMakeLabel( "volumet", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowRange)
   {
      ObjectMakeLabel( "rangel", left, top+offset );
      ObjectMakeLabel( "ranget", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowPips2open)
   {
      ObjectMakeLabel( "pips2openl", left, top+offset );
      ObjectMakeLabel( "pips2opent", right, top+offset );
      offset+=LineSpacing;
   }

   if(ShowAvgPeriodRange)
   {
      ObjectMakeLabel( "aprl", left, top+offset );
      ObjectMakeLabel( "aprt", right, top+offset );
      offset+=LineSpacing;
   }

   if ( ShowAvgDailyRange && ( !ShowAvgPeriodRange || ( ShowAvgPeriodRange && (apr_timeframe != PERIOD_D1 || APR_Bars != ADR_Bars) ) ) )
   {
      ObjectMakeLabel( "adrl", left, top+offset );
      ObjectMakeLabel( "adrt", right, top+offset );
      offset+=LineSpacing;
   }

   // BACKGROUND must be LAST label added (because of offset value).
   if (Background_Under_Labels)
   {
      // DONE with offset as used above.  Now reset it for background use.
      //int Background_AddWidth_Pixels = 42;  // Long enough for "* New York" to be on top of background.
      offset = MathMax(offset,revoffset) + MathMax(0,VerticalOffsetPixels-5); // Related to total height of background created.
      int yB = MathMax(1,VerticalOffsetPixels - 2);
      if (LabelCorner == 0) yB = MathMax(11,yB); // The top-left corner must be below normal chart label. User can increase vert-offset. 
      int xB = MathMax(1,HorizClockOffsetPixels - 6);
 	   double bfactor = 1.1; // There is some extra pixels above and below the actual character size.
      string btext = "gg"; // A "g" is a simple filled box using the Webdings font. Double "gg" is the width of approx. the bfactor * 2 *  Bfontsize
 	   int Bfontsize = (MathMax(left,right) - HorizClockOffsetPixels + Background_AddWidth_Pixels)/StringLen(btext); 
 	   
      
      // Create the first background label
      createBackground (backName,btext,Bfontsize,xB,yB);
      
      for (k=1; k<=8 ; k++ )
      {
         // Create overlapping rectangles to create the background.
         // FYI, with all labels displayed, backName & backName1-5 are usually enough.  6-8 are just to make sure.
         if (offset <= MathCeil(yB+Bfontsize*bfactor)) { ObjectDelete(backName+k); continue; } //break;
         //Alert("DEBUG: offset: ",offset,"  yB: ",yB,"  yB+...",yB+Bfontsize*bfactor+0.01);
         yB = MathMin(yB+Bfontsize*bfactor, offset - Bfontsize*bfactor);
         createBackground (backName+k,btext,Bfontsize,xB,yB);
      }
   }

}
//+------------------------------------------------------------------+
void createBackground (string objName, string text, int Bfontsize, int xB, int yB)
{
	   if (ObjectFind(objName) == -1){
         ObjectCreate(objName, OBJ_LABEL, DrawInWindowNumber, 0, 0, 0, 0);}
         
      ObjectSetText(objName, text, Bfontsize, "Webdings");      
      ObjectSet(objName, OBJPROP_CORNER, LabelCorner);
      ObjectSet(objName, OBJPROP_BACK, false);
      ObjectSet(objName, OBJPROP_XDISTANCE, xB);
      ObjectSet(objName, OBJPROP_YDISTANCE, yB );    
      ObjectSet(objName, OBJPROP_COLOR, Background_Color);
      return;
} // end of createBackground


//+------------------------------------------------------------------+
//| Custom indicator iteration function -- Runs with each new tick   |
//+------------------------------------------------------------------+
int start()
  {
   static bool ranFirstTick;
   if (!ranFirstTick)
   {
      deinit();
      createLabels();
      ranFirstTick=true;
   }
   static datetime last_timecurrent;
   
   int counted_bars=IndicatorCounted();
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   int uncountedBars=Bars-counted_bars; // After the initial run through, a 2nd tick in the SAME current bar gives "1".  If a NEW bar, returns "2"

   //static bool FLAG_DEINIT = false;
   if(Indicator_On == false)
   {
      if (!FLAG_DEINIT) deinit(); //Run deinit() just once, not every tick.
      FLAG_DEINIT = true;
      return(0);
   }
   FLAG_DEINIT = false;
   
   if (!FLAG_LABELEXISTS) 
   {
     // This may happen if init() tried to create objects in subwindow 1 BEFORE the subwindow was created!
     init();  //Run init() again.
     // Potentially flag an Alert ERROR here, if at least one ShowX was true and FLAG_LABELEXISTS is still false.
     //FLAG_LABELEXISTS = true; // Possibly Force true because perhaps every ShowX variable is false. Don't run init() every time.
     last_timecurrent = 0; // Gets around weekend-mode issue.
   }
   
   // NOTE: This error is replaced by one in the init() section because init bombs out with the first DLL call and never gets here.
   //if ( !IsDllsAllowed() ) 
   //{
   //   if (TimeCurrent() - last_timecurrent < 7) return; // With a lot of fast ticks, this error message would be annoying if not delayed a bit
   //   last_timecurrent = TimeCurrent();
   //   Alert( WindowExpertName(),": ERROR. DLLs are disabled. To enable, select 'Allow DLL Imports' in the Common Tab of indicator" );
   //   return;
   //}
   
   static bool FLAG_WINDOWALERT = false;
   if (!FLAG_WINDOWALERT && !WindowIsVisible(DrawInWindowNumber))
   {
      Alert(WindowExpertName(),": ERROR, subwindow ",DrawInWindowNumber," was not found or is invisible. No labels drawn.");
      FLAG_WINDOWALERT = true;
   }
   
   // Only use ONE of the next two lines:
   static int peakVolThreshold;    // This is for build <=509, prior to major 2014-Feb-02 MT4 changes.
   //static uint peakVolThreshold; // Volume should be type uint, so use this line for build>=579 to prevent "sign mismatch" warning message.

   if (ShowVolume && Bars != lastBars)
   {  
      lastBars=Bars;
      int volBarLimit=MathMin(HighVolumeBarsCompared,lastBars);
      for(int i=0; i<volBarLimit; i++) 
         { volarray[i] = Volume[i]; }

      // int ArraySort( double&array[], int count=WHOLE_ARRAY, int start=0, int sort_dir=MODE_ASCEND) 
      ArraySort(volarray,WHOLE_ARRAY,0,MODE_DESCEND);
      int element = MathMin(volBarLimit,Above_The_Nth_Highest_Volume-1);
      peakVolThreshold = volarray[element];
   }
   
   
   // FYI, if uncommented, saves CPU but won't update on weekends. If commented, on weekends the Broker_MMSS_Is_Gold_Standard must be FALSE. Better, just use Weekend_Test_Mode=true to update every tick.
   if (!Weekend_Test_Mode && TimeCurrent() - last_timecurrent == 0) return(0); // No point in processing more than 1 tick per second.
   last_timecurrent = TimeCurrent();
   
   int    systemTimeArray[4];
   
   int    AucklandTimeArray[4];
   int    SydneyTimeArray[4];
   int    TokyoTimeArray[4];
   int    ChinaTimeArray[4];
   int    JakartaTimeArray[4];
   int    IndiaTimeArray[4];
   int    DubaiTimeArray[4];
   int    MoscowTimeArray[4];
   int    IsraelTimeArray[4];
   int    HelsinkiTimeArray[4];
   int    BerlinTimeArray[4];
   int    LondonTimeArray[4];
   int    BrazilTimeArray[4];
   int    NewYorkTimeArray[4];
   int    CentralTimeArray[4];
   int    MexicoTimeArray[4];
   int    MountainTimeArray[4];
   int    PacificTimeArray[4];
   int    LocalTimeArray[4];
   
   
   GetLocalTime(LocalTimeArray);
   datetime Local_Time = TimeArrayToTime(LocalTimeArray);

   datetime BrokerTime = TimeCurrent();
   datetime BrokerCorrection = 0;
   
   if (Broker_MMSS_Is_Gold_Standard && !Weekend_Test_Mode) 
   {
      BrokerCorrection = TimeMinute(BrokerTime)*60 + TimeSeconds(BrokerTime) - TimeMinute(Local_Time)*60 - TimeSeconds(Local_Time);
      if (BrokerCorrection > 1800) BrokerCorrection = BrokerCorrection - 3600;
      else if (BrokerCorrection < -1800) BrokerCorrection = BrokerCorrection + 3600;
      static bool BrokerCorrectionError;
      //if (SupportAlso_HH_30_TimeZones && MathAbs(BrokerCorrection) > 900) BrokerCorrection = MathMod(BrokerCorrection + 1800,1800);
      if (MathAbs(BrokerCorrection) > 900) BrokerCorrection = MathMod(BrokerCorrection + 1800,1800);
      else if ( MathAbs(BrokerCorrection) > 900 && !BrokerCorrectionError)
        { // Only if HH_30 TimeZones are NOT supported, then this error may occur and be flagged:
         Print(WindowExpertName(),": Broker MMSS correction exceeds 15 minute limit. Was: ",BrokerCorrection, " seconds, now set to 0. Local_Time is now Gold Standard.");
         BrokerCorrectionError=true;
         BrokerCorrection=0;
        }
      //Alert("BrokerCorrection seconds: ", BrokerCorrection);
   }   
     
   GetSystemTime(systemTimeArray);
   datetime UTC = TimeArrayToTime(systemTimeArray)+BrokerCorrection;

   SystemTimeToTzSpecificLocalTime(AucklandTZInfoArray, systemTimeArray, AucklandTimeArray);
   datetime Auckland   = TimeArrayToTime(AucklandTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(SydneyTZInfoArray, systemTimeArray, SydneyTimeArray);
   datetime Sydney  = TimeArrayToTime(SydneyTimeArray)+BrokerCorrection;
   
   SystemTimeToTzSpecificLocalTime(TokyoTZInfoArray, systemTimeArray, TokyoTimeArray);
   datetime Tokyo   = TimeArrayToTime(TokyoTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(ChinaTZInfoArray, systemTimeArray, ChinaTimeArray);
   datetime China   = TimeArrayToTime(ChinaTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(JakartaTZInfoArray, systemTimeArray, JakartaTimeArray);
   datetime Jakarta   = TimeArrayToTime(JakartaTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(IndiaTZInfoArray, systemTimeArray, IndiaTimeArray);
   datetime India   = TimeArrayToTime(IndiaTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(DubaiTZInfoArray, systemTimeArray, DubaiTimeArray);
   datetime Dubai   = TimeArrayToTime(DubaiTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(MoscowTZInfoArray, systemTimeArray, MoscowTimeArray);
   datetime Moscow   = TimeArrayToTime(MoscowTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(IsraelTZInfoArray, systemTimeArray, IsraelTimeArray);
   datetime Israel   = TimeArrayToTime(IsraelTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(HelsinkiTZInfoArray, systemTimeArray, HelsinkiTimeArray);
   datetime Helsinki   = TimeArrayToTime(HelsinkiTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(BerlinTZInfoArray, systemTimeArray, BerlinTimeArray);
   datetime Berlin   = TimeArrayToTime(BerlinTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(LondonTZInfoArray, systemTimeArray, LondonTimeArray);
   datetime London  = TimeArrayToTime(LondonTimeArray)+BrokerCorrection;
   
   SystemTimeToTzSpecificLocalTime(BrazilTZInfoArray, systemTimeArray, BrazilTimeArray);
   datetime Brazil  = TimeArrayToTime(BrazilTimeArray)+BrokerCorrection;
   
   SystemTimeToTzSpecificLocalTime(NewYorkTZInfoArray, systemTimeArray, NewYorkTimeArray);
   datetime NewYork = TimeArrayToTime(NewYorkTimeArray)+BrokerCorrection;
   
   SystemTimeToTzSpecificLocalTime(CentralTZInfoArray, systemTimeArray, CentralTimeArray);
   datetime Central   = TimeArrayToTime(CentralTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(MexicoTZInfoArray, systemTimeArray, MexicoTimeArray);
   datetime Mexico   = TimeArrayToTime(MexicoTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(MountainTZInfoArray, systemTimeArray, MountainTimeArray);
   datetime Mountain   = TimeArrayToTime(MountainTimeArray)+BrokerCorrection;
      
   SystemTimeToTzSpecificLocalTime(PacificTZInfoArray, systemTimeArray, PacificTimeArray);
   datetime Pacific   = TimeArrayToTime(PacificTimeArray)+BrokerCorrection;
   
   string spreads;
   if (ShowPipSpread)
   {
      double spread =MathRound((Ask - Bid)/pointdiv10) * pointdiv10/myPoint;
      spreads = StringConcatenate(DoubleToStr(spread,pipdigits),pipstring); // 1/10ths of pips is normal on extra-digit broker
   }
   
   if (ShowBidPrice)
   {
      double price = Bid;
      string prices = DoubleToStr(price,Digits); 
   }
   
   if (ShowVolume)
   {
      string volumes = DoubleToStr(Volume[0],0); 
   }
   
   string ranges;
   if (ShowRange)
   {
      double range =MathRound((High[0] - Low[0])/pointdiv10) * pointdiv10/myPoint;
      ranges = StringConcatenate(DoubleToStr(range,pipdigits),pipstring); // 1/10ths of pips is normal on extra-digit broker
   }
   
   string pips2opens;
   if (ShowPips2open)
   {
      double pips2open =MathRound((Close[0] - Open[0])/pointdiv10) * pointdiv10/myPoint;
      pips2opens = StringConcatenate(DoubleToStr(pips2open,pipdigits),pipstring); // 1/10ths of pips is normal on extra-digit broker
   }
   
   static string aprs;
   if (ShowAvgPeriodRange || ShowRange) //apr is needed for ShowRange, even if APR is not displayed.
   {
      // TBD. Calculate the AVERAGE for the specified PERIOD over the specified #BARS
      // double iMA( string symbol, int timeframe, int period, int ma_shift, int ma_method, int applied_price, int shift) 
   
      static double apr;
      // The following executes ONCE per bar, and calculates the PREVIOUS #bars APR, ignoring whatever is happening during the current bar! 
      if (uncountedBars > 1 || TimeCurrent() - lastapradrtime > 20) //Every new bar OR next tick after 20-seconds causes an update.
      {
         lastapr=apr;
         lastapradrtime = TimeCurrent();
         // What if the timeframe is not the current one and the data is not up-to-date??  Could try...
         //if (apr_timeframe != Period() )
         //double array1[][6];
         //ArrayCopyRates(array1,Symbol, PERIOD_H1);
         //if (GetLastError() == ERR_HISTORY_WILL_UPDATED  // ??? This is a return from failed ArrayCopySeries (not Rates!) 

         apr = MathRound((iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_HIGH,1) - iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_LOW,1))/pointdiv10) * pointdiv10/myPoint;
         aprs = StringConcatenate(DoubleToStr(apr,pipdigits),pipstring); // 1/10ths of pips is normal on extra-digit broker
         
//Alert("DEBUG:  Per=",Period(),"  iMA-H,L: ", iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_HIGH,1)," GetLastError: ",GetLastError(),"  ",iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_LOW,1)
// ,"  ",aprs,"  ", iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_HIGH,2),"  ",iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_LOW,2));

         if (lastapr == 0) lastapr = MathRound((iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_HIGH,2) - iMA(NULL,apr_timeframe,APR_Bars,0,MODE_SMA,PRICE_LOW,2))/pointdiv10) * pointdiv10/myPoint;
      }
   }
   
   static string adrs;
   if (ShowAvgDailyRange)
   {
      // TBD. Calculate the AVERAGE for the specified PERIOD over the specified #BARS
      // double iMA( string symbol, int timeframe, int period, int ma_shift, int ma_method, int applied_price, int shift) 
   
      static double adr;
      // The following executes ONCE per bar, and calculates the PREVIOUS #bars ADR, ignoring whatever is happening during the current bar! 
      if (uncountedBars > 1  || TimeCurrent() - lastapradrtime > 20) 
      {
         lastadr=adr;
         lastapradrtime = TimeCurrent();
         
         adr = MathRound((iMA(NULL,PERIOD_D1,ADR_Bars,0,MODE_SMA,PRICE_HIGH,1) - iMA(NULL,PERIOD_D1,ADR_Bars,0,MODE_SMA,PRICE_LOW,1))/pointdiv10) * pointdiv10/myPoint;
         adrs = StringConcatenate(DoubleToStr(adr,pipdigits),pipstring); // 1/10ths of pips is normal on extra-digit broker
         
         if (lastadr == 0) lastadr =  MathRound((iMA(NULL,PERIOD_D1,ADR_Bars,0,MODE_SMA,PRICE_HIGH,2) - iMA(NULL,PERIOD_D1,ADR_Bars,0,MODE_SMA,PRICE_LOW,2))/pointdiv10) * pointdiv10/myPoint;
      }
   }
   
   
   
   string Brokers = timeToString( TimeCurrent() );
   string Aucklands = timeToString( Auckland  );
   string Sydneys = timeToString(Sydney);
   string Tokyos = timeToString( Tokyo  );
   string Chinas = timeToString( China  );
   string Jakartas = timeToString( Jakarta  );
   string Indias = timeToString( India  );
   string Dubais = timeToString( Dubai  );
   string Moscows = timeToString( Moscow  );
   string Israels = timeToString( Israel  );
   string Helsinkis = timeToString( Helsinki  );
   string Berlins = timeToString( Berlin  );
   string Londons = timeToString( London  );
   string UTCs = timeToString( UTC );
   string Brazils = timeToString( Brazil  );
   string NewYorks = timeToString( NewYork  );
   string Centrals = timeToString( Central  );
   string Mexicos = timeToString( Mexico  );
   string Mountains = timeToString( Mountain  );
   string Pacifics = timeToString( Pacific  );
   string Locals = timeToString( Local_Time  );
   
   int secondsleft = Period()*60 + Time[0] - TimeCurrent(); // FYI, this CAN go negative if a new bar hasn't formed yet!
   string barstr;
   if (secondsleft >= 0) 
   {
      if (Display_Bar_With_Seconds != 0 && (Display_Bar_With_Seconds == 1 || Display_Time_With_Seconds || (Display_Bar_With_Seconds == 2 && secondsleft < 120))) barstr = TimeToStr( Period()*60 + Time[0] - TimeCurrent(), TIME_MINUTES|TIME_SECONDS );
      else barstr = TimeToStr( Period()*60 + Time[0] - TimeCurrent(), TIME_MINUTES );
      
      if (Suppress_Bar_HH_Below_H1 && Period() <= PERIOD_H1 && StringLen(barstr) > 6) barstr = StringSubstr(barstr,3);
   }
   else // negative means no new bar yet formed
     {
      if (Display_Bar_With_Seconds == 0) barstr = "wait"; // or "--:--"
      else barstr = "wait4bar"; // or "--:--:--"; 
     }
   
   if(ShowPipSpread)
   {
	   ObjectSetText( "spreadl", "Spread", TimezoneFontSize, FontName, TimezoneColor );
      if (spread > LowSpreadHighlightThreshold) ObjectSetText( "spreadt", spreads, ClockFontSize, FontName,HigherPriceVolumeColor ); // or ClockColor or ??
      else // if (IndicatorCounted() > 0) // No Alerts/Arrows on first tick.
      {
         ObjectSetText( "spreadt", spreads, ClockFontSize, FontName,LowerPriceVolumeColor ); // or ClockMktOpenColor or ??
         if (DoLowSpreadAlerts && lastBars_spread != Bars) { lastBars_spread = Bars; Alert(WindowExpertName()," on ",Symbol()," ",periodstr," :  LOW SPREAD: ",spreads," @ Bid= ",Bid); }
         if (DoLowSpreadArrows) // && lastBars_sp_arrows != Bars) 
         {
            //lastBars_sp_arrows = Bars; 
            //bool ObjectCreate( string name, int type, int window, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0) 
            datetime timecurrent = TimeCurrent();
            double price1 = Bid; // Right AT the spot. Object Background must be false to see it.
            // double price1 = Low[0] - 5*myPoint; //5 pips below bar-low.
            string objName = StringConcatenate(WindowExpertName()," LOW SPREAD ",timecurrent); // EVERY lowspread event creates an arrow
            //string objName = StringConcatenate(WindowExpertName()," LOW SPREAD ",DoubleToStr(Time[0]/Period(),0) ); // LAST lowspread event per bar creates an arrow
            if (ObjectFind(objName) < 0)
            {
               if(!ObjectCreate(objName,OBJ_ARROW,0,timecurrent,price1))
               {
                 string err=GetLastError();
                 Alert("ERROR: cannot create Arrow! code #",err," ",ErrorDescription(err));
                 //return;
               }
               else
               {
                  ObjectSetText(objName, StringConcatenate(spreads," @ Bid= ",Bid," @ ",TimeToStr(timecurrent,TIME_DATE|TIME_MINUTES|TIME_SECONDS)),8, "Arial", Red); // Font & color don't matter for Description text.
               }
            }
            else
            {
               double lastspread = StrToDouble(StringSubstr(ObjectDescription(objName),StringFind( ObjectDescription(objName)," ",0) ) );
               if (spread <= lastspread) ObjectSetText(objName,StringConcatenate(DoubleToStr(spread,1)," @ Bid= ",Bid," @ ",TimeToStr(timecurrent,TIME_DATE|TIME_MINUTES|TIME_SECONDS)),8, "Arial", Red); // Font & color don't matter for Description text.
               //Alert("DEBUG: spread: ",spread,"  lastspread: ",lastspread, "  Desc: ",ObjectDescription(objName));
               
               
            }
            ObjectSet(objName, OBJPROP_ARROWCODE, LowSpreadArrowCode); //119=tiny diamond.  216=point right (kinda like 2 lines approaching together.  Or try 54 hourglass.
            ObjectSet(objName, OBJPROP_COLOR , LowSpreadArrowColor);
            ObjectSet(objName, OBJPROP_WIDTH  , 1);
            ObjectSet(objName, OBJPROP_BACK  , false);
               
            //ObjectSetText(objName, "xxx", 8, "Arial", Red); // Font & color don't matter for Description text.
            //ObjectsRedraw();
            obj_created = true;
            ObjectMove(objName,0,timecurrent,price1);

         }
      }
   }
   
   if(ShowBidPrice)
   {
	   ObjectSetText( "pricel", "Price", TimezoneFontSize, FontName, TimezoneColor );
      if (price > lastprice) ObjectSetText( "pricet", prices, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "pricet", prices, ClockFontSize, FontName,LowerPriceVolumeColor );
      lastprice=price;
   }
   
   if(ShowVolume)
   {
      // If volume is >= Above_The_Nth_Highest_Volume out of HighVolumeBarsCompared, highlight the label
	   if (Volume[0] >= peakVolThreshold && peakVolThreshold >= 1) 
	   {
	      ObjectSetText( "volumel", "*HiVol*", TimezoneFontSize, FontName, LowerPriceVolumeColor ); // or LabelMktOpenColor or ??
	      if (DoHighVolumeAlerts && lastBars_volume != Bars) { lastBars_volume = Bars; Alert(WindowExpertName()," on ",Symbol(),",",periodstr,
	            " :  HIGH VOLUME: ",volumes," @ Bid= ",Bid," (and climbing!)  ( >= ",Above_The_Nth_Highest_Volume,"th-of-last-",HighVolumeBarsCompared,"-bars)"); }
	   }
      else ObjectSetText( "volumel", "Volume", TimezoneFontSize, FontName, TimezoneColor );

      if (Volume[0] >= Volume[1]) ObjectSetText( "volumet", volumes, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "volumet", volumes, ClockFontSize, FontName,LowerPriceVolumeColor );
      // Alternatively, consider using the bolder LowerPriceVolumeColor (or a 3rd color) when there is unusually high volume. (vs. Vol-SMA? Or >90% of last X bars?)
   }
   
   if(ShowRange)
   {
	   ObjectSetText( "rangel", "Range", TimezoneFontSize, FontName, TimezoneColor );
      if (range >= apr) ObjectSetText( "ranget", ranges, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "ranget", ranges, ClockFontSize, FontName,LowerPriceVolumeColor );
   }
   
   if(ShowPips2open)
   {
	   ObjectSetText( "pips2openl", "Pips2open", TimezoneFontSize, FontName, TimezoneColor );
      if (pips2open >= 0) ObjectSetText( "pips2opent", pips2opens, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "pips2opent", pips2opens, ClockFontSize, FontName,LowerPriceVolumeColor );
   }
   
   if(ShowAvgPeriodRange)
   {
	   ObjectSetText( "aprl", StringConcatenate("A",periodToName(apr_timeframe,APR_LabelShowsMinutes),"R(",DoubleToStr(APR_Bars,0),")"), TimezoneFontSize, FontName, TimezoneColor );
      if (apr > lastapr) ObjectSetText( "aprt", aprs, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "aprt", aprs, ClockFontSize, FontName,LowerPriceVolumeColor );
   }
   
   if ( ShowAvgDailyRange && ( !ShowAvgPeriodRange || ( ShowAvgPeriodRange && (apr_timeframe != PERIOD_D1 || APR_Bars != ADR_Bars) ) ) )
   {
	   ObjectSetText( "adrl", StringConcatenate("ADR(",DoubleToStr(ADR_Bars,0),")"), TimezoneFontSize, FontName, TimezoneColor );
      if (adr > lastadr) ObjectSetText( "adrt", adrs, ClockFontSize, FontName,HigherPriceVolumeColor );
      else ObjectSetText( "adrt", adrs, ClockFontSize, FontName,LowerPriceVolumeColor );
   }
   
   
   if(ShowBarTime && Period() <= PERIOD_D1)
   {
      ObjectSetText( "barl", "Bar Left", TimezoneFontSize, FontName, TimezoneColor );
      ObjectSetText( "bart", StringConcatenate("[ ",barstr," ]"), ClockFontSize, FontName,ClockColor );
   }

   if(ShowBroker)
   {
	   ObjectSetText( "Brokerl", "Broker", TimezoneFontSize, FontName, TimezoneColor );
      ObjectSetText( "Brokert", Brokers, ClockFontSize, FontName,ClockColor );
   }
   if(ShowAuckland)
   {
   	if (TimeDayOfWeek(Auckland) != 0 && TimeDayOfWeek(Auckland) != 6 && Highlight_Market_Open && TimeHour(Auckland) >= LocalOpenHour && TimeHour(Auckland) < LocalCloseHour)
   	{
   	   ObjectSetText( "Aucklandl", "* Auckland", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Aucklandt", Aucklands, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Aucklandl", "Auckland", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Aucklandt", Aucklands, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowSydney)
   {
   	//if (true)
   	if (TimeDayOfWeek(Sydney) != 0 && TimeDayOfWeek(Sydney) != 6 && Highlight_Market_Open && TimeHour(Sydney) >= SydneyLocalOpenHour && TimeHour(Sydney) < SydneyLocalCloseHour)
   	{
   	   ObjectSetText( "Sydneyl", "* Sydney", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Sydneyt", Sydneys, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Sydneyl", "Sydney", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Sydneyt", Sydneys, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowTokyo)
   {
   	if (TimeDayOfWeek(Tokyo) != 0 && TimeDayOfWeek(Tokyo) != 6 && Highlight_Market_Open && TimeHour(Tokyo) >= TokyoLocalOpenHour && TimeHour(Tokyo) < TokyoLocalCloseHour)
   	{
   	   ObjectSetText( "Tokyol", "* Tokyo", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Tokyot", Tokyos, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Tokyol", "Tokyo", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Tokyot", Tokyos, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowChina)
   {
   	if (TimeDayOfWeek(China) != 0 && TimeDayOfWeek(China) != 6 && Highlight_Market_Open && TimeHour(China) >= LocalOpenHour && TimeHour(China) < LocalCloseHour)
   	{
   	   ObjectSetText( "Chinal", "* China", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Chinat", Chinas, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Chinal", "China", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Chinat", Chinas, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowJakarta)
   {
   	if (TimeDayOfWeek(Jakarta) != 0 && TimeDayOfWeek(Jakarta) != 6 && Highlight_Market_Open && TimeHour(Jakarta) >= LocalOpenHour && TimeHour(Jakarta) < LocalCloseHour)
   	{
   	   ObjectSetText( "Jakartal", "* Jakarta", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Jakartat", Jakartas, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Jakartal", "Jakarta", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Jakartat", Jakartas, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowIndia)
   {
   	if (TimeDayOfWeek(India) != 0 && TimeDayOfWeek(India) != 6 && Highlight_Market_Open && TimeHour(India) >= LocalOpenHour && TimeHour(India) < LocalCloseHour)
   	{
   	   ObjectSetText( "Indial", "* India", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Indiat", Indias, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Indial", "India", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Indiat", Indias, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowDubai)
   {
   	if (TimeDayOfWeek(Dubai) != 0 && TimeDayOfWeek(Dubai) != 6 && Highlight_Market_Open && TimeHour(Dubai) >= LocalOpenHour && TimeHour(Dubai) < LocalCloseHour)
   	{
   	   ObjectSetText( "Dubail", "* Dubai", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Dubait", Dubais, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Dubail", "Dubai", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Dubait", Dubais, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowMoscow)
   {
   	if (TimeDayOfWeek(Moscow) != 0 && TimeDayOfWeek(Moscow) != 6 && Highlight_Market_Open && TimeHour(Moscow) >= LocalOpenHour && TimeHour(Moscow) < LocalCloseHour)
   	{
   	   ObjectSetText( "Moscowl", "* Moscow", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Moscowt", Moscows, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Moscowl", "Moscow", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Moscowt", Moscows, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowIsrael)
   {
   	if (TimeDayOfWeek(Israel) != 0 && TimeDayOfWeek(Israel) != 6 && Highlight_Market_Open && TimeHour(Israel) >= LocalOpenHour && TimeHour(Israel) < LocalCloseHour)
   	{
   	   ObjectSetText( "Israell", "* Israel", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Israelt", Israels, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Israell", "Israel", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Israelt", Israels, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowHelsinki)
   {
   	if (TimeDayOfWeek(Helsinki) != 0 && TimeDayOfWeek(Helsinki) != 6 && Highlight_Market_Open && TimeHour(Helsinki) >= LocalOpenHour && TimeHour(Helsinki) < LocalCloseHour)
   	{
   	   ObjectSetText( "Helsinkil", "* Helsinki", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Helsinkit", Helsinkis, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Helsinkil", "Helsinki", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Helsinkit", Helsinkis, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowBerlin)
   {
   	if (TimeDayOfWeek(Berlin) != 0 && TimeDayOfWeek(Berlin) != 6 && Highlight_Market_Open && TimeHour(Berlin) >= LocalOpenHour && TimeHour(Berlin) < LocalCloseHour)
   	{
   	   ObjectSetText( "Berlinl", "* Berlin", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Berlint", Berlins, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Berlinl", "Berlin", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Berlint", Berlins, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(Show_DIBS_London)
   {
   	if (TimeDayOfWeek(London) != 0 && TimeDayOfWeek(London) != 6 && Highlight_Market_Open && TimeHour(London) >= DIBS_LondonOpenHour && TimeHour(London) < DIBS_LondonCloseHour)
   	{
   	   ObjectSetText( "dibsl", "* DIBS UK", TimezoneFontSize, FontName, LabelMktOpenColor );
      	ObjectSetText( "dibst", Londons, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "dibsl", "DIBS UK", TimezoneFontSize, FontName, TimezoneColor );
      	ObjectSetText( "dibst", Londons, ClockFontSize, FontName,ClockColor );
      }
   }
   if(ShowLondon)
   {
   	if (TimeDayOfWeek(London) != 0 && TimeDayOfWeek(London) != 6 && Highlight_Market_Open && TimeHour(London) >= LocalOpenHour && TimeHour(London) < LocalCloseHour)
   	{
      	ObjectSetText( "Londonl", "* London", TimezoneFontSize, FontName, LabelMktOpenColor );
      	ObjectSetText( "Londont", Londons, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Londonl", "London", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Londont", Londons, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowUTC_GMT)
   {
   	ObjectSetText( "utcl", "UTC/GMT", TimezoneFontSize, FontName, TimezoneColor );
   	ObjectSetText( "utct", UTCs, ClockFontSize, FontName,ClockColor );
   }
   if(ShowBrazil)
   {
   	if (TimeDayOfWeek(Brazil) != 0 && TimeDayOfWeek(Brazil) != 6 && Highlight_Market_Open && TimeHour(Brazil) >= LocalOpenHour && TimeHour(Brazil) < LocalCloseHour)
   	{
   	   ObjectSetText( "Brazill", "* Brazil", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Brazilt", Brazils, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Brazill", "Brazil", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Brazilt", Brazils, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowNewYork)
   {
   	if (TimeDayOfWeek(NewYork) != 0 && TimeDayOfWeek(NewYork) != 6 && Highlight_Market_Open && TimeHour(NewYork) >= LocalOpenHour && TimeHour(NewYork) < LocalCloseHour)
   	{
   	   ObjectSetText( "NewYorkl", "* New York", TimezoneFontSize, FontName, LabelMktOpenColor );
      	ObjectSetText( "NewYorkt", NewYorks, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   //ObjectSetText( "NewYorkl", "* New York", TimezoneFontSize, FontName, TimezoneColor );
      	ObjectSetText( "NewYorkl", "New York", TimezoneFontSize, FontName, TimezoneColor );
      	ObjectSetText( "NewYorkt", NewYorks, ClockFontSize, FontName,ClockColor );
      }
   }
   if(ShowCentral)
   {
   	if (TimeDayOfWeek(Central) != 0 && TimeDayOfWeek(Central) != 6 && Highlight_Market_Open && TimeHour(Central) >= LocalOpenHour && TimeHour(Central) < LocalCloseHour)
   	{
   	   ObjectSetText( "Centrall", "* Central", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Centralt", Centrals, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Centrall", "Central", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Centralt", Centrals, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowMexico)
   {
   	if (TimeDayOfWeek(Mexico) != 0 && TimeDayOfWeek(Mexico) != 6 && Highlight_Market_Open && TimeHour(Mexico) >= LocalOpenHour && TimeHour(Mexico) < LocalCloseHour)
   	{
   	   ObjectSetText( "Mexicol", "* Mexico", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Mexicot", Mexicos, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Mexicol", "Mexico", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Mexicot", Mexicos, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowMountain)
   {
   	if (TimeDayOfWeek(Mountain) != 0 && TimeDayOfWeek(Mountain) != 6 && Highlight_Market_Open && TimeHour(Mountain) >= LocalOpenHour && TimeHour(Mountain) < LocalCloseHour)
   	{
   	   ObjectSetText( "Mountainl", "* Mountain", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Mountaint", Mountains, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Mountainl", "Mountain", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Mountaint", Mountains, ClockFontSize, FontName,ClockColor );
   	}
   }
   if(ShowPacific)
   {
   	if (TimeDayOfWeek(Pacific) != 0 && TimeDayOfWeek(Pacific) != 6 && Highlight_Market_Open && TimeHour(Pacific) >= LocalOpenHour && TimeHour(Pacific) < LocalCloseHour)
   	{
   	   ObjectSetText( "Pacificl", "* Pacific", TimezoneFontSize, FontName, LabelMktOpenColor );
   	   ObjectSetText( "Pacifict", Pacifics, ClockFontSize, FontName,ClockMktOpenColor );
   	}
   	else
   	{
   	   ObjectSetText( "Pacificl", "Pacific", TimezoneFontSize, FontName, TimezoneColor );
   	   ObjectSetText( "Pacifict", Pacifics, ClockFontSize, FontName,ClockColor );
   	}
   }
   if ( ShowLocal)
   {
      ObjectSetText( "Locall", "Local", TimezoneFontSize, FontName, TimezoneColor );
      ObjectSetText( "Localt", Locals, ClockFontSize, FontName,ClockColor );
   }

   //----
   return(0);
} // end of start()


//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

string timeToString( datetime when ) {
   string timeStr;
   int hour = TimeHour( when );
   if ( !Display_Times_With_AMPM ) 
     {
      if (Display_Time_With_Seconds) timeStr = (TimeToStr( when, TIME_MINUTES|TIME_SECONDS));
      else timeStr = (TimeToStr( when, TIME_MINUTES));
     }
   else
     {
      // User wants 12HourTime format with "AM" or "PM".   
      // FYI, if >12:00, subtract 12 hours in seconds which is 12*60*60=43200
      if (Display_Time_With_Seconds)
        {
         if ( hour >  12 || hour == 0) timeStr = TimeToStr( (when - 43200), TIME_MINUTES|TIME_SECONDS);
         else timeStr = TimeToStr( when, TIME_MINUTES|TIME_SECONDS);
         if ( hour >= 12) timeStr = StringConcatenate(timeStr, " PM");
         else timeStr = StringConcatenate(timeStr, " AM");
        }
      else
        {
         if ( hour >  12 || hour == 0) timeStr = TimeToStr( (when - 43200), TIME_MINUTES);
         else timeStr = TimeToStr( when, TIME_MINUTES);
         if ( hour >= 12) timeStr = StringConcatenate(timeStr, " PM");
         else timeStr = StringConcatenate(timeStr, " AM");
        }
     }
   return (timeStr);
} // end of timeToString
//+------------------------------------------------------------------+


int ObjectMakeLabel( string n, int xoff, int yoff ) {
   if (!WindowIsVisible(DrawInWindowNumber)) return(-1);
   ObjectCreate( n, OBJ_LABEL, DrawInWindowNumber, 0, 0 );
   ObjectSet( n, OBJPROP_CORNER, LabelCorner );
   ObjectSet( n, OBJPROP_XDISTANCE, xoff );
   ObjectSet( n, OBJPROP_YDISTANCE, yoff );
   ObjectSet( n, OBJPROP_BACK, false );
   if (ObjectFind(n) >= 0) FLAG_LABELEXISTS = true; // If NO label exists then start() may run init() again.
   return(0);
} // end of ObjectMakeLabel
//+------------------------------------------------------------------+

string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
   sMonth=100+nMonth;
   sMonth=StringSubstr(sMonth,1);
   sDay=100+nDay;
   sDay=StringSubstr(sDay,1);
   sHour=100+nHour;
   sHour=StringSubstr(sHour,1);
   sMin=100+nMin;
   sMin=StringSubstr(sMin,1);
   sSec=100+nSec;
   sSec=StringSubstr(sSec,1);
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
} // end of FormatDateTime
//+------------------------------------------------------------------+

datetime TimeArrayToTime(int& LocalTimeArray[])
{
   //---- parse date and time from array
   
   int    nYear,nMonth,nDay,nHour,nMin,nSec,nMilliSec;
   //string sMilliSec;

   nYear=LocalTimeArray[0]&0x0000FFFF;
   nMonth=LocalTimeArray[0]>>16;
   //int nDOW=LocalTimeArray[1]&0x0000FFFF;
   nDay=LocalTimeArray[1]>>16;
   nHour=LocalTimeArray[2]&0x0000FFFF;
   nMin=LocalTimeArray[2]>>16;
   nSec=LocalTimeArray[3]&0x0000FFFF;
   nMilliSec=LocalTimeArray[3]>>16;
   string LocalTimeS = FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime Local_Time = StrToTime( LocalTimeS );
   return(Local_Time);
} // end of TimeArrayToTime
//+------------------------------------------------------------------+

void GetAllTimeZoneInfo() 
      //int& AucklandTZInfoArray[], int& SydneyTZInfoArray[], int& TokyoTZInfoArray[], int& ChinaTZInfoArray[], int& JakartaTZInfoArray[], 
      //int& IndiaTZInfoArray[], int& DubaiTZInfoArray[], int& MoscowTZInfoArray[], int& IsraelTZInfoArray[], int& HelsinkiTZInfoArray[], int& BerlinTZInfoArray[], int& LondonTZInfoArray[], int& BrazilTZInfoArray[],
      //int& NewYorkTZInfoArray[], int& CentralTZInfoArray[], int& MexicoTZInfoArray[], int& MountainTZInfoArray[], int& PacificTZInfoArray[], int& LocalTZInfoArray[])
{
   int dst=GetTimeZoneInformation(LocalTZInfoArray);
   // Note: the dst return info is no longer used.  However, FYI, the Return info is: dst =
   //  0 = Your Local TZ does not switch between Std Time and DST (e.g. Tokyo, Jakarta)
   //  1 = Your Local TZ does switch to DST, but is presently on ST
   //  2 = Your Local TZ does switch to DST and is presently on DST
   //
   // FYI:  LocalTZInfoArray[n] =
   //   0 = bias, in minutes(!)    // ************* This is important and used below
   //   1-16 TZ-standard-name
   //   17-20 = StdTimeArray       // ************* This is important and used below
   //   21 = std-bias              // ************* This is important and used below
   //   22-37 = TZ-daylight-name
   //   38-41 = DaylightTimeArray  // ************* This is important and used below
   //   42 = dst-bias              // ************* This is important and used below
   
   // FYI:
   // From: http://www.tech-archive.net/Archive/DotNet/microsoft.public.dotnet.framework.interop/2005-05/msg00278.html
   //"To select the correct day in the month, set the wYear member to zero, the 
   //wHour and wMinute members to the transition time, the wDayOfWeek member to 
   //the appropriate weekday, and the wDay member to indicate the occurence of the 
   //day of the week within the month (first through fifth). 
   //
   //"Using this notation, specify the 2:00a.m. on the first Sunday in April as 
   //follows: wHour = 2, wMonth = 4, wDayOfWeek = 0, wDay = 1. Specify 2:00a.m. on 
   //the last Thursday in October as follows: wHour = 2, wMonth = 10, wDayOfWeek = 
   //4, wDay = 5."
   
   // 1<<16  = 065536 // Syntax 1<<16 is take the # and bitwise-shift it to the left 16 bits. The new (least significant) right-bits are zeros.
   // 2<<16  = 131072
   // 3<<16  = 196608
   // 4<<16  = 262144
   // 5<<16  = 327680
   // 6<<16  = 393216
   // 7<<16  = 458752
   // 8<<16  = 524288
   // 9<<16  = 589824
   // 10<<16 = 655360
   // 11<<16 = 720896
   // 12<<16 = 786432
   
   // FYI, for all the TZ ST/DST dates, the wYear=0 and wDay= the # for wDayOfWeek IN the month, e.g. wDayOfWeek=0 and wDay=1 means 1st Sunday.
   // Consequently, these numbers should be good into perpetuity, until of course, countries legistlatively change 
   // their DST/ST changeover dates. (e.g. Tokyo is considering DST, and the US changed it's dates not long ago)
   //ArrayCopy(NewYorkTZInfoArray, LocalTZInfoArray); // Not necessary. All key fields set below.
   AucklandTZInfoArray[0] = -720;
   AucklandTZInfoArray[17] = 262144; // 4<<16 == 262144  April
   AucklandTZInfoArray[18] = 65536;  // 1<<16 == 65536   1st Sunday
   AucklandTZInfoArray[19] = 3;
   AucklandTZInfoArray[20] = 0;
   AucklandTZInfoArray[21] = 0;
   AucklandTZInfoArray[38] = 589824; // 9<<16 == 589824  September
   AucklandTZInfoArray[39] = 327680; // 5<<16 == 327680  5th/Last Sunday
   AucklandTZInfoArray[40] = 2;
   AucklandTZInfoArray[41] = 0;
   AucklandTZInfoArray[42] = -60;
   
   SydneyTZInfoArray[0] = -600;
   SydneyTZInfoArray[17] = 262144; // 4<<16 == 262144  April
   SydneyTZInfoArray[18] = 65536;  // 1<<16 == 65536   1st Sunday
   SydneyTZInfoArray[19] = 3;
   SydneyTZInfoArray[20] = 0;
   SydneyTZInfoArray[21] = 0;
   SydneyTZInfoArray[38] = 655360; // 10<<16 == 655360  October
   SydneyTZInfoArray[39] = 65536;  // 1<<16 == 65536    1st Sunday
   SydneyTZInfoArray[40] = 2;
   SydneyTZInfoArray[41] = 0;
   SydneyTZInfoArray[42] = -60;
   
   // FYI Tokyo = Seoul
   TokyoTZInfoArray[0] = -540;
   TokyoTZInfoArray[17] = 0; 
   TokyoTZInfoArray[18] = 0;
   TokyoTZInfoArray[19] = 0;
   TokyoTZInfoArray[20] = 0;
   TokyoTZInfoArray[21] = 0;
   TokyoTZInfoArray[38] = 0;
   TokyoTZInfoArray[39] = 0;
   TokyoTZInfoArray[40] = 0;
   TokyoTZInfoArray[41] = 0;
   TokyoTZInfoArray[42] = 0;
   
   // FYI, Beijing = Perth, Singapore, Taipei
   ArrayCopy(ChinaTZInfoArray, TokyoTZInfoArray);
   ChinaTZInfoArray[0] = -480;
   
   // FYI, Jakarta = Bangkok
   ArrayCopy(JakartaTZInfoArray, TokyoTZInfoArray);
   JakartaTZInfoArray[0] = -420;
   
   ArrayCopy(IndiaTZInfoArray, TokyoTZInfoArray);
   IndiaTZInfoArray[0] = -330;  // NOTE! Top of the hour is 30 min off most world timezones.
   
   ArrayCopy(DubaiTZInfoArray, TokyoTZInfoArray);
   DubaiTZInfoArray[0] = -240;
   
   ArrayCopy(MoscowTZInfoArray, TokyoTZInfoArray);
   MoscowTZInfoArray[0] = -240;
   MoscowTZInfoArray[42] = -60;
   // Moscow WAS further below, but is now here because ST/DST was eliminated (Sep 2011)
   
   // FYI, Cairo ST/DST dates USED to be hardcoded (Nov 2009) but ST/DST is now eliminated (Sep 2011).
   //ArrayCopy(CairoTZInfoArray, TokyoTZInfoArray);
   //CairoTZInfoArray[0] = -120;
   //CairoTZInfoArray[42] = -60;
   
   
   IsraelTZInfoArray[0] = -120;
   IsraelTZInfoArray[17] = 655360; // 10<<16 == 655360  October // OLD: 9<<16 == 589824  September
   IsraelTZInfoArray[18] = 65536;  // 1<<16 == 65536   1st Sunday // OLD: 2<<16  = 131072
   IsraelTZInfoArray[19] = 2;
   IsraelTZInfoArray[20] = 0;
   IsraelTZInfoArray[21] = 0;
   IsraelTZInfoArray[38] = 262144; // 4<<16 == 262144  April // OLD: 3<<16 == 196608  March
   IsraelTZInfoArray[39] = 65541; // ??? // OLD: 5<<16  = 327680 AND "5" (*IF* Sunday is "0", is "5" Friday??)
   IsraelTZInfoArray[40] = 2;
   IsraelTZInfoArray[41] = 0;
   IsraelTZInfoArray[42] = -60;
   
   // Helsinki (-120) is further below
   // Berlin (-60) is further below
   
   LondonTZInfoArray[0] = 0;
   LondonTZInfoArray[17] = 655360; // 10<<16 == 655360  October
   LondonTZInfoArray[18] = 327680; // 5<<16 == 327680.  5th/Last Sunday. BECAUSE this is already "5" even though in 2008 the last Sunday in Oct is the 4th Sunday, this must mean "last" Sunday.
   LondonTZInfoArray[19] = 2;
   LondonTZInfoArray[20] = 0;
   LondonTZInfoArray[21] = 0;
   LondonTZInfoArray[38] = 196608; // 3<<16 == 196608  March
   LondonTZInfoArray[39] = 327680; // 5<<16 == 327680  5th/Last Sunday
   LondonTZInfoArray[40] = 1;
   LondonTZInfoArray[41] = 0;
   LondonTZInfoArray[42] = -60;
   
   //ArrayCopy(MoscowTZInfoArray, LondonTZInfoArray);
   //MoscowTZInfoArray[0] = -180;
   //MoscowTZInfoArray[19] = 3;
   //MoscowTZInfoArray[40] = 2;
   
   // FYI, Helsinki = Athens
   ArrayCopy(HelsinkiTZInfoArray, LondonTZInfoArray);
   HelsinkiTZInfoArray[0] = -120;
   HelsinkiTZInfoArray[19] = 4;
   HelsinkiTZInfoArray[40] = 3;
   
   // FYI, Berlin = Belgrade, Brussels, Paris, Sarajevo
   ArrayCopy(BerlinTZInfoArray, LondonTZInfoArray);
   BerlinTZInfoArray[0] = -60;
   BerlinTZInfoArray[19] = 3;
   BerlinTZInfoArray[40] = 2;
   
   // NOTE! Brazil's ST/DST is likely a hardcoded date which will need updating EVERY YEAR!
   BrazilTZInfoArray[0] = 180;
   BrazilTZInfoArray[17] = 131072;   // 2<<16  = 131072
   BrazilTZInfoArray[18] = 196614;   // 3<<16 == 196608 AND 6, so, Saturday?? or Mar 6?
   BrazilTZInfoArray[19] = 3866647;
   BrazilTZInfoArray[20] = 65470523;
   BrazilTZInfoArray[21] = 0;
   BrazilTZInfoArray[38] = 655360;   // 10<<16 == 655360
   BrazilTZInfoArray[39] = 196614;
   BrazilTZInfoArray[40] = 3866647;
   BrazilTZInfoArray[41] = 65470523;
   BrazilTZInfoArray[42] = -60;
   
   //ArrayCopy(BuenasAriesTZInfoArray, BuenasAriesTZInfoArray);
   //BuenasAriesTZInfoArray[0] = 180;
   
   NewYorkTZInfoArray[0] = 300;
   NewYorkTZInfoArray[17] = 720896; // wYear = 0. wMonth = 11, and 11<<16 == 720896
   NewYorkTZInfoArray[18] = 65536;  // wDOW = 0 = Sunday. nDay = 1 and 1<<16 == 65536 // NOTE! When wYear = 0, wDay is the # for wDOW IN the month. 1 = 1st... Sunday for example.
   NewYorkTZInfoArray[19] = 2;
   NewYorkTZInfoArray[20] = 0;
   NewYorkTZInfoArray[21] = 0;
   NewYorkTZInfoArray[38] = 196608; // 3<<16 == 196608  March
   NewYorkTZInfoArray[39] = 131072; // 2<<16 == 131072  2nd Sunday
   NewYorkTZInfoArray[40] = 2;
   NewYorkTZInfoArray[41] = 0;
   NewYorkTZInfoArray[42] = -60;
   
   ArrayCopy(CentralTZInfoArray, NewYorkTZInfoArray);
   CentralTZInfoArray[0] = 360;
   
   //ArrayCopy(CenAmerTZInfoArray, TokyoTZInfoArray);
   //CenAmerTZInfoArray[0] = 360;
   
   MexicoTZInfoArray[0] = 360;
   MexicoTZInfoArray[17] = 655360; // 10<<16 == 655360  October
   MexicoTZInfoArray[18] = 327680; // 5<<16 == 327680  5th/Last Sunday
   MexicoTZInfoArray[19] = 2;
   MexicoTZInfoArray[20] = 0;
   MexicoTZInfoArray[21] = 0;
   MexicoTZInfoArray[38] = 262144; // 4<<16 == 262144  April
   MexicoTZInfoArray[39] = 65536;  // 1<<16 == 65536   1st Sunday
   MexicoTZInfoArray[40] = 2;
   MexicoTZInfoArray[41] = 0;
   MexicoTZInfoArray[42] = -60;
   
   ArrayCopy(MountainTZInfoArray, NewYorkTZInfoArray);
   MountainTZInfoArray[0] = 420;
   
   ArrayCopy(PacificTZInfoArray, NewYorkTZInfoArray);
   PacificTZInfoArray[0] = 480;
   
} // end of GetAllTimeZoneInfo
//+------------------------------------------------------------------+

void writeLocalTZInfoToFile(string filename, bool AllTZData)
{
   int    TimeArray[4];
   //int    TZInfoArray[43];
   int    z[43];
   int dst=GetTimeZoneInformation(z);
   
   if (ObjectFind("timezone") < 0)
   {
      Alert(WindowExpertName(),": Open your Terminal window. Go to Experts tab for timezone update instructions!");
      Print(WindowExpertName(),": If the market zone ST/DST changeover dates change, or to ADD a new market zone, do these steps!");
      Print("... First check for any program updates at: http://forexfactory.com/showthread.php?t=109305");
      Print("... If no update, you can start editing the version you already have.");
      Print("... First temporarily set your CPU clock to the NewYork Eastern US timezone.");
      Print("... Next create a text. Make the name 'timezone'. Make the description 'NewYork'.");
      Print("... Change chart period JUST ONCE -- the file will be appended each change!");
      Print("... Repeat steps to change CPU clock and text for GMT, Tokyo, Sydney, etc.");
      Print("... Start Excel. Open a blank file. Go to Data => Import External Data => Import Data");
      Print("... Import the file: ",TerminalPath(),"\x5Cexperts\x5Cfiles\x5C",filename);
      Print("... The file is Tab delimited and should provide simple readable columns of data");
      Print("... In MetaEditor, open: ",WindowExpertName(),".mq4, search for: NewYorkTZInfoArray[17]"); 
      Print("... Change all array values for all timezones according to your Excel spreadsheet");
      Print("... If you THOUGHT you just wrote data but you see this again, you missed a step.");
      Print("... Check your text name/description and try again...");
      Print("... When finished... change CPU clock back to normal. Change the timezone update boolean back to FALSE");
      return;
   }
   string tzname = ObjectDescription("timezone");
   
   int handle;
   handle = FileOpen(filename,FILE_READ,"\t");
   if (handle<0)
   {
      // If file does not exist, open new file and write a single line with column labels and then close it.
      handle = FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE,"\t");
      if(handle<0) 
        {
         Print(filename," OPEN Error: ",GetLastError());
         return;
        }
      else FileSeek(handle,0,SEEK_END);
   
      if (AllTZData) 
      {
         FileWrite(handle, 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,"tzname");
      }
      else 
      {
         FileWrite(handle, 0,17,18,19,20,21,38,39,40,41,42,"tzname");
      }
      FileClose(handle);
   }
   
   // File should exist by now.
   handle = FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE,"\t");
   if(handle<0) 
     {
      Print(filename," OPEN Error: ",GetLastError());
      return;
     }
   else FileSeek(handle,0,SEEK_END);
   
   if (AllTZData)
   {
      FileWrite(handle, z[0], z[1], z[2], z[3], z[4], z[5], z[6], z[7], z[8], z[9], z[10], z[11], z[12], z[13], z[14], z[15], z[16], z[17], z[18], z[19],
         z[20], z[21], z[22], z[23], z[24], z[25], z[26], z[27], z[28], z[29], z[30], z[31], z[32], z[33], z[34], z[35], z[36], z[37], z[38], z[39], z[40], z[41], z[42], tzname);
   }
   else
   {
      FileWrite(handle, z[0], z[17], z[18], z[19], z[20], z[21], z[38], z[39], z[40], z[41], z[42], tzname);
   
   }
   FileClose(handle);
   Print(WindowExpertName(),": ",tzname," data written to ",TerminalPath(),"\x5Cexperts\x5Cfiles\x5C",filename);
} // end of writeLocalTZInfoToFile


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   if(ShowPipSpread) { ObjectDelete( "spreadl" ); ObjectDelete( "spreadt" ); }
   if(ShowBidPrice) { ObjectDelete( "pricel" ); ObjectDelete( "pricet" ); }
   if(ShowVolume) { ObjectDelete( "volumel" ); ObjectDelete( "volumet" ); }
   if(ShowRange) { ObjectDelete( "rangel" ); ObjectDelete( "ranget" ); }
   if(ShowPips2open) { ObjectDelete( "pips2openl" ); ObjectDelete( "pips2opent" ); }
   if(ShowAvgPeriodRange) { ObjectDelete( "aprl" ); ObjectDelete( "aprt" ); }
   if(ShowAvgDailyRange) { ObjectDelete( "adrl" ); ObjectDelete( "adrt" ); }
   if(ShowBarTime) { ObjectDelete( "barl" ); ObjectDelete( "bart" ); }
   if(ShowBroker) { ObjectDelete( "Brokerl" ); ObjectDelete( "Brokert" ); }
   if(ShowAuckland) { ObjectDelete( "Aucklandl" ); ObjectDelete( "Aucklandt" ); }
   if(ShowSydney) { ObjectDelete( "Sydneyl" ); ObjectDelete( "Sydneyt" ); }
   if(ShowTokyo) { ObjectDelete( "Tokyol" ); ObjectDelete( "Tokyot" ); }
   if(ShowChina) { ObjectDelete( "Chinal" ); ObjectDelete( "Chinat" ); }
   if(ShowJakarta) { ObjectDelete( "Jakartal" ); ObjectDelete( "Jakartat" ); }
   if(ShowIndia) { ObjectDelete( "Indial" ); ObjectDelete( "Indiat" ); }
   if(ShowDubai) { ObjectDelete( "Dubail" ); ObjectDelete( "Dubait" ); }
   if(ShowMoscow) { ObjectDelete( "Moscowl" ); ObjectDelete( "Moscowt" ); }
   if(ShowIsrael) { ObjectDelete( "Israell" ); ObjectDelete( "Israelt" ); }
   if(ShowHelsinki) { ObjectDelete( "Helsinkil" ); ObjectDelete( "Helsinkit" ); }
   if(ShowBerlin) { ObjectDelete( "Berlinl" ); ObjectDelete( "Berlint" ); }
   if(Show_DIBS_London) { ObjectDelete( "dibsl" ); ObjectDelete( "dibst" ); }
   if(ShowLondon) { ObjectDelete( "Londonl" ); ObjectDelete( "Londont" ); }
   if(ShowUTC_GMT) { ObjectDelete( "utcl" ); ObjectDelete( "utct" ); }
   if(ShowBrazil) { ObjectDelete( "Brazill" ); ObjectDelete( "Brazilt" ); }
   if(ShowNewYork) { ObjectDelete( "NewYorkl" ); ObjectDelete( "NewYorkt" ); }
   if(ShowCentral) { ObjectDelete( "Centrall" ); ObjectDelete( "Centralt" ); }
   if(ShowMexico) { ObjectDelete( "Mexicol" ); ObjectDelete( "Mexicot" ); }
   if(ShowMountain) { ObjectDelete( "Mountainl" ); ObjectDelete( "Mountaint" ); }
   if(ShowPacific) { ObjectDelete( "Pacificl" ); ObjectDelete( "Pacifict" ); }
   if(ShowLocal) { ObjectDelete( "Locall" ); ObjectDelete( "Localt" ); }
   if(Background_Under_Labels) 
   {
      ObjectDelete( backName );
      ObjectDelete( backName+1 );
      ObjectDelete( backName+2 );
      ObjectDelete( backName+3 );
      ObjectDelete( backName+4 );
      ObjectDelete( backName+5 );
      ObjectDelete( backName+6 );
      ObjectDelete( backName+7 );
      ObjectDelete( backName+8 );
   }
   if (obj_created && Delete_Old_SpreadArrows) deleteArrows();
   //----
   return(0);
} // end of deinit()

void deleteArrows()
{
      int obj_total, objType;
      string objName;
      obj_total = ObjectsTotal();
      for (int i=obj_total-1; i>=0; i--) // NOTE! When deleting objects as below, must count DOWN in this loop!
      {
         objName = ObjectName(i);
         objType = ObjectType(objName);
         if ( objType == OBJ_ARROW )
         { 
            if ( StringFind(objName,WindowExpertName(),0) == 0) ObjectDelete(objName);
            //if ( ObjectGet(objName,OBJPROP_ARROWCODE) == LowSpreadArrowCode) ObjectDelete(objName);
         }
      }
}
//+------------------------------------------------------------------+
double getPoint(bool custommode)
{
   double point = Point;
   string symbol = Symbol();
   int pluspos = StringFind(symbol,"+",0);
   int minuspos = StringFind(symbol,"-",0);
   if (pluspos > 0) symbol = StringSubstr(symbol,0,pluspos);
   else if (minuspos > 0) symbol = StringSubstr(symbol,0,minuspos);
   
   if (! custommode) return(point);
   else
     {
      if (symbol == "NOKJPY" || symbol == "SEKJPY" || symbol == "GBPDKK" 
          || symbol == "GBPNOK" || symbol == "USDSKK" || symbol == "XAG") point = Point; // These are 0.001 on BroCo.
      else if (StringFind(symbol,"JPY",3) == 3 || symbol == "XAUUSD") point = 0.01; // ***JPY, XAUUSD
      else if (StringFind(symbol,"USD",0) >= 0
               || StringFind(symbol,"EUR",0) >= 0
               || StringFind(symbol,"GBP",0) >= 0
               || StringFind(symbol,"CAD",0) >= 0
              ) point = 0.0001;
     }
   //Print("getPoint: ",point,"  symbol: ",symbol);
   return(point);
} // end of getPoint
//+------------------------------------------------------------------+
string stringReplaceEveryMatch(string str, string toFind, string toReplace) {
    int len = StringLen(toFind);
    int pos = 0;
    string leftPart, rightPart, result = str;
    if (len == 0) return (result); // Cannot find ""
    while (true) {
        // Careful, pos must change each loop or it's an infinite loop.
        pos = StringFind(result, toFind, pos);
        if (pos == -1) {
            break;
        }
        if (pos == 0) {
            leftPart = "";
        } else {
            leftPart = StringSubstr(result, 0, pos);
        }
        pos = pos + len;
        rightPart = StringSubstr(result, pos); 
        result = StringConcatenate(leftPart,toReplace,rightPart);
    }    
    return (result);
} // end of stringReplaceEveryMatch
//+------------------------------------------------------------------+
string stringToUC(string str) {
    // Convert str to upper-case
    int lS = 97, lE = 122, uS = 65, uE = 90, diff = lS - uS;
    for (int i = 0; i < StringLen(str); i++) {
        int code = StringGetChar(str, i);
        if (code >= lS && code <= lE) {
            code -= diff;
            str = StringSetChar(str, i, code);
        }
    }
    return (str);
} // end of stringToUC
//+------------------------------------------------------------------+
int stringTimeframeToPeriod(string tfstr)
{
   int out;
   tfstr = stringToUC(tfstr);
   if (tfstr == "C" || tfstr == "CURRENT" || tfstr == "O") out = Period(); // Note, capital-oh changed also.
   else 
   if (tfstr == "M1" || tfstr == "1M") out =1;
   else if (tfstr == "M5" || tfstr == "5M") out =5;
   else if (tfstr == "M15" || tfstr == "15M") out =15;
   else if (tfstr == "M30" || tfstr == "30M") out =30;
   else if (tfstr == "H1" || tfstr == "1H" || tfstr == "M60" || tfstr == "60M") out =60;
   else if (tfstr == "H4" || tfstr == "4H" || tfstr == "M240" || tfstr == "240M") out =240;
   else if (tfstr == "D" || tfstr == "Daily" || tfstr == "D1" || tfstr == "1D" || tfstr == "M1440" || tfstr == "1440M") out =1440;
   else if (tfstr == "W" || tfstr == "Weekly" || tfstr == "W1" || tfstr == "1W" || tfstr == "WK" || tfstr == "M10080" || tfstr == "10080M") out =10080;
   else if (tfstr == "Month" || tfstr == "Monthly" || tfstr == "MN" || tfstr == "MO" || tfstr == "M43200" || tfstr == "43200M") out = 43200;
   else out = StrToInteger(stringReplaceEveryMatch(tfstr,"M","")); //e.g. convert M10 or 10M to "10"
   return(out);
}

string periodToName(int period, bool showminutes)
{
   string out;
   if (period == 60) out="H";
   else if (period == 120) out="H2";
   else if (period == 240) out="H4";
   else if (period == 480) out="H8";
   else if (period == 1440) out="D";
   else if (period == 10080) out="W";
   else if (period == 43200) out="MN";
   else if (!showminutes) out = "P";
   //else out = StringConcatenate("M",DoubleToStr(period,0));  // Uppercase "M"
   //else out = StringConcatenate("m",DoubleToStr(period,0));  // Lowercase "m"
   else out = DoubleToStr(period,0);  // NO prefix to the #-of-minutes
   return(out);
}