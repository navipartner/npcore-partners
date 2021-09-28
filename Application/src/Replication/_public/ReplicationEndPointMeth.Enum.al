enum 6014474 "NPR Replication EndPoint Meth" implements "NPR Replication IEndpoint Meth"
{
    Extensible = true;

    value(100; "Get BC Generic Data")
    {
        Caption = 'Get BC Generic Data';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get BC Generic Data";
    }

}
