//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


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
  
  
  
//+------------------------------------------------------------------+
//| Read server response                                             |
//+------------------------------------------------------------------+
  
bool HTTPRecv(int socket,uint timeout)
  {
   char   rsp[];
   string result;
   uint   timeout_check=GetTickCount()+timeout;
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
            if( StringFind(result, "--EOF", 0) != -1 ) {
               //Print("found end");
               StringReplace(result, "--EOF", "");
               Print(result);
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
