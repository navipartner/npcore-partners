enum 6059821 "NPR MM SubsPayReqLogProcStatus"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscriptions Payment Request Log Processing Status';

    value(0; Success) { }
    value(10; Error) { }
    value(20; Rejected) { }

}
