#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
enumextension 6014420 "NPR Webhook Event Category" extends "EventCategory"
{
    value(6014400; "NPR POS")
    {
        Caption = 'Point of Sale';
    }
}
#endif