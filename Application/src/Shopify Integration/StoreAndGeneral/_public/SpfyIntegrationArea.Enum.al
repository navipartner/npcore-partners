#if not BC17
enum 6014656 "NPR Spfy Integration Area" implements "NPR Spfy Change Handler"
{
    Extensible = true;
    DefaultImplementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Default";

    value(0; " ") { }
    value(10; Items)
    {
        Caption = 'Item List';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Items";
    }
    value(11; "Inventory Levels")
    {
        Caption = 'Inventory';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Inventory";
    }
    value(12; "Item Prices")
    {
        Caption = 'Item Prices';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Item Prices";
    }
    value(13; "Item Categories")
    {
        Caption = 'Item Categories';
    }
    value(20; "Sales Orders")
    {
        Caption = 'Sales Orders';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Sales Orders";
    }
    value(21; "Order Fulfillments")
    {
        Caption = 'Sales Order Fulfillments';
    }
    value(22; "Payment Capture Requests")
    {
        Caption = 'Payment Capture Requests';
    }
    value(23; "Close Order Requests")
    {
        Caption = 'Close Order Requests';
    }
    value(24; "Order Ready for Pickup")
    {
        Caption = 'Order Ready for Pickup';
    }
#if not (BC18 or BC19 or BC20 or BC21 or BC22)
    value(25; "Sales Returns")
    {
        Caption = 'Sales Returns';
    }
#endif
    value(30; "Retail Vouchers")
    {
        Caption = 'Retail Vouchers';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Vouchers";
    }
    value(40; "Loyalty Points")
    {
        Caption = 'Loyalty Points';
    }
#if not (BC18 or BC19 or BC20)
    value(50; "BC Customer Transactions")
    {
        Caption = 'BC Customer Transactions';
    }
#endif
    value(60; Metafields)
    {
        // Dispatch-routing area for the owner-polymorphic NPR Spfy Entity Metafield table (Item + Customer metafields).
        // Not an end-user "enable" toggle — the handler gates each metafield by its OWNER's area (Items/Customers).
        Caption = 'Metafields';
        Implementation = "NPR Spfy Change Handler" = "NPR Spfy Chg Hdlr Metafields";
    }
}
#endif