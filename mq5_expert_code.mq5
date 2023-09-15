//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>

CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;

CTrade trade;
input double SL = 200.0; //Take Profit
input double TP = 500.0; //Take Profit

input string Address="127.0.0.1";
input int    Port   =6000;
bool         ExtTLS =false;


//+------------------------------------------------------------------+
//| Send command to the server                                       |
//+------------------------------------------------------------------+
bool HTTPSend(int socket,string request)
  {
   char req[];
   int  len=StringToCharArray(request,req)-1;
   if(len<0)
      return(false);
//--- if secure TLS connection is used via the port 443
   if(ExtTLS)
      return(SocketTlsSend(socket,req,len)==len);
//--- if standard TCP connection is used
   return(SocketSend(socket,req,len)==len);
  }
  
  
  void trade(string currency, string command) {
   Print(currency + " - " + command);
  }
  
  
//+------------------------------------------------------------------+
//| Read server response                                             |
//+------------------------------------------------------------------+
bool HTTPRecv(int socket,uint timeout)
  {


   char   rsp[];
   string result;
   uint   timeout_check=GetTickCount()+timeout;
   string currencyName, tradeDirection;
//--- read data from sockets till they are still present but not longer than timeout
   do
     {
      uint len=SocketIsReadable(socket);
      //Print("len: ", len);
      if(len)
        {
         int rsp_len;
         
         rsp_len=SocketRead(socket,rsp,len,timeout);
         //--- analyze the response
         if(rsp_len>0)
           {
            result+=CharArrayToString(rsp,0,rsp_len);
            if( StringFind(result, "^", 0) != -1 ) {
               //Print("found end");
               //StringReplace(result, "--EOF", "");
               Print(result);

               string m_to_split = result; // A string to split into substrings 
               string m_sep="^";                // A separator as a character 
               ushort m_u_sep;                  // The code of the separator character 
               string m_splitedResult[];               // An array to get strings 
               //--- Get the separator code 
               m_u_sep=StringGetCharacter(m_sep,0); 
               //--- Split the string to substrings 
               int m_k=StringSplit(m_to_split,m_u_sep, m_splitedResult); 
               //--- Show a comment  
               //PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep); 
               
               for( int i=0; i<m_k; i++ ) {
                string to_split = m_splitedResult[i]; // A string to split into substrings 
                string sep="-";                // A separator as a character 
                ushort u_sep;                  // The code of the separator character 
                string splitedResult[];               // An array to get strings 
                //--- Get the separator code 
                u_sep=StringGetCharacter(sep,0); 
                //--- Split the string to substrings 
                int k=StringSplit(to_split,u_sep, splitedResult); 
                //--- Show a comment  
                PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep); 
                //--- Now output all obtained strings 
                if(k==4) 
                  { 
                    for(int i=0;i<k;i++) 
                      { 
                      PrintFormat("result[%d]=%s",i,splitedResult[i]); 
                      
                      } 
                      currencyName = splitedResult[1];
                      tradeDirection = splitedResult[2];
                      
                      trade(currencyName, tradeDirection);
                      
                      //double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
                      //double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
                      //int CurrentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
                      
                      //if (tradeDirection == "buy") {
                      //    Print("Buying");
                      //    trade.Buy(0.01, currencyName, Ask, Bid-SL*_Point, Ask+TP*_Point, NULL);
                      //}
                      
                      //if (tradeDirection == "sell") {
                      //    Print("Selling");
                      //    trade.Sell(0.01, currencyName, Bid, Ask+SL*_Point, Bid-TP*_Point, NULL);
                      //}
                    }               
               }
               

               
               
               return true;
            }
           }
        }
     }
   while(GetTickCount()<timeout_check && !IsStopped());
   return(false);
  }
  
int socket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(10);
   Print("Initializing");
   
   socket = SocketCreate();
//--- check the handle
   if(socket!=INVALID_HANDLE)
     {
      //--- connect if all is well
      if(SocketConnect(socket,Address,Port,5000))
        {
         Print("Established connection to ",Address,":",Port);
         if(HTTPSend(socket,"HEALTH CHECK"))
           {
            Print("health check data sent");
            //--- read the response
            if(!HTTPRecv(socket,1000))
               Print("Failed to get a response, error ",GetLastError());
            else 
               Print("Got response");
           }
        }
      else {
         Print("Couldnt connect", GetLastError());
      }
     }
     return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      HTTPRecv(socket,1000);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
