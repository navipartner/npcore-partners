#if not BC17
enum 6014656 "NPR Spfy Integration Area"
{
    Extensible = true;

    value(0; " ") { }
    value(10; Items)
    {
        Caption = 'Item List';
    }
    value(11; "Inventory Levels")
    {
        Caption = 'Inventory';
    }
    value(12; "Item Prices")
    {
        Caption = 'Item Prices';
    }
    value(20; "Sales Orders")
    {
        Caption = 'Sales Orders';
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
    value(30; "Retail Vouchers")
    {
        Caption = 'Retail Vouchers';
    }
}
#endif