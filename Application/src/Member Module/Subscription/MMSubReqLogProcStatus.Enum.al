enum 6059830 "NPR MM Sub Req Log Proc Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscriptions Request Log Processing Status';

    value(0; Success) { }
    value(10; Error) { }
}
