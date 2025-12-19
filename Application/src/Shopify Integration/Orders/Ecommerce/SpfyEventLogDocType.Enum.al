#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059931 "NPR SpfyEventLogDocType"
{
    Extensible = false;
    Access = Internal;

    value(0; "Order")
    {
        Caption = 'Order';
    }
    value(1; "Return Order")
    {
        Caption = 'Return Order';
    }
}
#endif