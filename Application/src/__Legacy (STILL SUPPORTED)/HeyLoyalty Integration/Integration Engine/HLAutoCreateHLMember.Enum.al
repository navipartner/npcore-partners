enum 6014515 "NPR HL Auto Create HL Member"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;

    value(0; Never) { Caption = 'Never'; }
    value(1; Eligible) { Caption = 'Eligible for Subscription'; }
    value(2; Always) { Caption = 'Always'; }
}
