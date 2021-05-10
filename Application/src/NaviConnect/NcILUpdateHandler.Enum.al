enum 6151500 "NPR Nc IL Update Handler" implements "NPR Nc Import List IUpdate"
{
    Extensible = true;

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "NPR Nc Import List IUpdate" = "NPR Nc IL Update Default";
    }
    value(10; "B24GetInvoice")
    {
        Caption = 'B24 Get Invoice';
        Implementation = "NPR Nc Import List IUpdate" = "NPR BTF GetInvoices";
    }
    value(12; "B24GetOrderResp")
    {
        Caption = 'B24 Get Order Response';
        Implementation = "NPR Nc Import List IUpdate" = "NPR BTF GetOrderResp";
    }
    value(13; "B24GetPriCat")
    {
        Caption = 'B24 Get Price Catalogue';
        Implementation = "NPR Nc Import List IUpdate" = "NPR BTF GetPriCat";
    }
    value(14; "B24GetOrder")
    {
        Caption = 'B24 Get Order';
        Implementation = "NPR Nc Import List IUpdate" = "NPR BTF GetOrders";
    }
}