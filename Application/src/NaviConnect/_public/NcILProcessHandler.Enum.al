enum 6014602 "NPR Nc IL Process Handler" implements "NPR Nc Import List IProcess"
{
    Extensible = true;
    DefaultImplementation = "NPR Nc Import List IProcess" = "NPR Nc IL Process Default";

    value(0; Default)
    {
        Caption = 'Default';
        Implementation = "NPR Nc Import List IProcess" = "NPR Nc IL Process Default";
    }
    value(10; "Magento Sales Order")
    {
        Caption = 'Magento Sales Order';
        Implementation = "NPR Nc Import List IProcess" = "NPR Magento Sales Order Mgt.";
    }

    value(20; "Magento Return Order")
    {
        Caption = 'Magento Return Order';
        Implementation = "NPR Nc Import List IProcess" = "NPR Magento Imp. Ret. Order";
    }

    value(30; "Btwentyfour")
    {
        Caption = 'Btwentyfour';
        Implementation = "NPR Nc Import List IProcess" = "NPR BTF Nc Import Entry";
    }

    value(40; "Collect Sales Document")
    {
        Caption = 'Collect Sales Document';
        Implementation = "NPR Nc Import List IProcess" = "NPR NpCs Imp. Sales Doc.";
    }

    value(50; "TM Ticket WebService Mgr")
    {
        Caption = 'TM Ticket WebService Mgr';
        Implementation = "NPR Nc Import List IProcess" = "NPR TM Ticket WebService Mgr";
    }

    value(60; "MM Member WebService Mgr")
    {
        Caption = 'TM Ticket WebService Mgr';
        Implementation = "NPR Nc Import List IProcess" = "NPR MM Member WebService Mgr";
    }

    value(70; "MM Loyalty WebService Mgr")
    {
        Caption = 'MM Loyalty WebService Mgr';
        Implementation = "NPR Nc Import List IProcess" = "NPR MM Loyalty WebService Mgr";
    }

    value(80; "HC POS Entry Management")
    {
        Caption = 'HC POS Entry Management';
        Implementation = "NPR Nc Import List IProcess" = "NPR HC POS Entry Management";
        ObsoleteState = Pending;
        ObsoleteTag = 'NPR24.0';
        ObsoleteReason = 'HQ Connector will no longer be supported';
    }

    value(90; "Endpoint Query WS Mgr")
    {
        Caption = 'Endpoint Query WS Mgr';
        Implementation = "NPR Nc Import List IProcess" = "NPR Endpoint Query WS Mgr";
    }

    value(100; "Replication")
    {
        Caption = 'Replication';
        Implementation = "NPR Nc Import List IProcess" = "NPR Replication Import Entry";
    }

    value(110; "Item Wksht. WebService Mgr")
    {
        Caption = 'Item Wksht. WebService Mgr';
        Implementation = "NPR Nc Import List IProcess" = "NPR Item Wksht. WebService Mgr";
    }

    value(120; "External POS Sale")
    {
        Caption = 'External POS Sale';
        Implementation = "NPR Nc Import List IProcess" = "NPR Ext. POS Sale Processor";
    }

    value(130; "NpEc S.Order Import Create")
    {
        Caption = 'NpEc S.Order Import Create';
        Implementation = "NPR Nc Import List IProcess" = "NPR NpEc S.Order Import Create";
    }

    value(131; "NpEc S.Order Import (Post)")
    {
        Caption = 'NpEc S.Order Import (Post)';
        Implementation = "NPR Nc Import List IProcess" = "NPR NpEc S.Order Import (Post)";
    }

    value(132; "NpEc S.Order Imp. Delete")
    {
        Caption = 'NpEc S.Order Imp. Delete';
        Implementation = "NPR Nc Import List IProcess" = "NPR NpEc S.Order Imp. Delete";
    }

    value(133; "NpEc P.Invoice Imp. Create")
    {
        Caption = 'NpEc P.Invoice Imp. Create';
        Implementation = "NPR Nc Import List IProcess" = "NPR NpEc P.Invoice Imp. Create";
    }


}
