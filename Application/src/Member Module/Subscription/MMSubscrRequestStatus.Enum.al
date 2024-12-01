enum 6059804 "NPR MM Subscr. Request Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscription Request Status';

    value(0; New) { Caption = 'New'; }
    value(10; Requested) { Caption = 'Requested'; }
    value(30; Confirmed) { Caption = 'Confirmed'; }
    value(40; Rejected) { Caption = 'Rejected'; }
    value(50; Cancelled) { Caption = 'Cancelled'; }
    value(60; "Request Error") { Caption = 'Request Error'; }
}