enum 6014407 "NPR BTF EndPoint Method" implements "NPR BTF IEndPoint"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "Get Token")
    {
        Caption = 'Get Token';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF GetToken";
    }
    value(1; "Get Orders")
    {
        Caption = 'Get Orders';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF GetOrders";
    }
    value(2; "Get Invoices")
    {
        Caption = 'Get Invoices';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF GetInvoices";
    }
    value(3; "Process Message")
    {
        Caption = 'Process Message';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF ProcessMessage";
    }
    value(4; "Get Order Response")
    {
        Caption = 'Get Order Response';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF GetOrderResp";
    }
    value(5; "Get Price Catalogue")
    {
        Caption = 'Get Price Catalogue';
        Implementation = "NPR BTF IEndPoint" = "NPR BTF GetPriCat";
    }
}
