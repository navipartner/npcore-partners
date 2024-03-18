enum 6014643 "NPR NPRE Notification Trigger"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;
    Caption = 'Notification Trigger';

    value(0; " ") { }
    value(10; KDS_ORDER_NEW) { Caption = 'New Order'; }
    value(30; KDS_ORDER_DELAYED_1) { Caption = 'Delayed Order (1st Threshold)'; }
    value(40; KDS_ORDER_DELAYED_2) { Caption = 'Delayed Order (2nd Threshold)'; }
    value(50; KDS_ORDER_READY_FOR_SERVING) { Caption = 'Order Ready for Serving'; }
}
