enum 6014515 "NPR HL Auto Create HL Member"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;

    value(0; Never) { Caption = 'Never'; }
    value(1; Eligible) { Caption = 'Eligible for Subscription'; }
    value(2; Always) { Caption = 'Always'; }
}
