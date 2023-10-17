enum 6014604 "NPR Nc IL Lookup Handler" implements "NPR Nc Import List ILookup"
{
    Extensible = true;
    DefaultImplementation = "NPR Nc Import List ILookup" = "NPR Nc IL Lookup Default";

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "NPR Nc Import List ILookup" = "NPR Nc IL Lookup Default";
    }
    value(10; "Magento Lookup Sales Order")
    {
        Caption = 'Magento Lookup Sales Order';
        Implementation = "NPR Nc Import List ILookup" = "NPR Magento Lookup SalesOrder";
    }
    value(20; "Magento Lookup Return Order")
    {
        Caption = 'Magento Lookup Return Order';
        Implementation = "NPR Nc Import List ILookup" = "NPR Magento Lookup Ret.Order";
    }

    value(30; "TM View Ticket Requests")
    {
        Caption = 'TM View Ticket Requests';
        Implementation = "NPR Nc Import List ILookup" = "NPR TM View Ticket Requests";
    }

    value(40; "External POS Sale Lookup")
    {
        Caption = 'External POS Sale Lookup';
        Implementation = "NPR Nc Import List ILookup" = "NPR Ext. POS Sale Lookup";
    }

    value(50; "NpEc S.Order Lookup")
    {
        Caption = 'NpEc S.Order Lookup';
        Implementation = "NPR Nc Import List ILookup" = "NPR NpEc S.Order Lookup";
    }

    value(60; "NpEc P.Invoice Look")
    {
        Caption = 'NpEc P.Invoice Look';
        Implementation = "NPR Nc Import List ILookup" = "NPR NpEc P.Invoice Look.";
    }

    value(70; "NpCs Lookup Sales Document")
    {
        Caption = 'NpCs Lookup Sales Document';
        Implementation = "NPR Nc Import List ILookup" = "NPR NpCs Lookup Sales Document";
    }



}
