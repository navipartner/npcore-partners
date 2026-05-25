#if not (BC17 or BC18 or BC19 or BC20 or BC21)
enum 6014634 "NPR Dig. Notif. Type"
{
    Access = Public;
    Extensible = true;

    value(0; "Digital Assets")
    {
        Caption = 'Digital Assets';
    }
    value(10; "Order Confirmation")
    {
        Caption = 'Order Confirmation';
    }
}
#endif
