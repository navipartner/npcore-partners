enum 6014521 "NPR User Login Type"
{
#IF NOT BC17  
    Access = Internal;
#ENDIF
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    value(0; BC)
    {
        Caption = 'BC';
    }
    value(1; POS)
    {
        Caption = 'POS';
    }
}
