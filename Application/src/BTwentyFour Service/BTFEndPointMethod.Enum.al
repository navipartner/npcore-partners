enum 6014407 "NPR BTF EndPoint Method" implements "NPR BTF IEndPoint"
{
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
}