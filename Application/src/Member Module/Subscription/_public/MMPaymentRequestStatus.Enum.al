enum 6059803 "NPR MM Payment Request Status"
{
#if not BC17
    Access = Public;
#endif
    Extensible = false;

    value(0; New) { Caption = 'New'; }
    value(10; Requested) { Caption = 'Requested'; }
    value(20; Authorized) { Caption = 'Authorized'; }
    value(30; Captured) { Caption = 'Captured'; }
    value(40; Rejected) { Caption = 'Rejected'; }
    value(50; Cancelled) { Caption = 'Cancelled'; }
    value(60; Error) { Caption = 'Error'; }
}