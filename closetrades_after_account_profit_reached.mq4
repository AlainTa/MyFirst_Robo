//+------------------------------------------------------------------+
//|                    CloseTrades_After_Account_Profit_Reached.mq4  |
//|                                     Copyright © 2007, Tradinator |
//|                                          tradinator.fx@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Tradinator"
#property link      "tradinator.fx@gmail.com"


                                       
extern double My_Money_Profit_Target=300;     //The amount of money profit at which you want to close ALL open trades.
                                          
int Slippage=5;
int i;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+


int start()
{
if (AccountProfit()>= My_Money_Profit_Target)
   {
    for(i=OrdersTotal()-1;i>=0;i--)
       {
       OrderSelect(i, SELECT_BY_POS);
       int type   = OrderType();
               
       bool result = false;
              
       switch(type)
          {
          //Close opened long positions
          case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slippage,Pink);
                         break;
               
          //Close opened short positions
          case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),Slippage,Pink);
                          
          }
          
       if(result == false)
          {
            Sleep(3000);
          }  
       }
      Print ("Account Profit Reached. All Open Trades Have Been Closed");
      return(0);
   }  
   
   Comment("Balance: ",AccountBalance(),", Account Equity: ",AccountEquity(),", Account Profit: ",AccountProfit(),
           "\nMy Account Profit Target: ",My_Money_Profit_Target);
   
  return(0);
}