enum 6014474 "NPR Replication EndPoint Meth" implements "NPR Replication IEndpoint Meth", "NPR Rep. WS IFunctions"
{
#IF NOT BC17  
    Access = Internal;       
#ENDIF
    Extensible = true;

    value(100; "Get BC Generic Data")
    {
        Caption = 'Get BC Generic Data';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get BC Generic Data", "NPR Rep. WS IFunctions" = "NPR Rep. WS Functions Client";
    }

}
