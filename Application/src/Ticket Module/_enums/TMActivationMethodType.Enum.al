enum 6014645 "NPR TM ActivationMethod_Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;

    // OptionCaption = 'Scan,(POS) Default Admission,Invoice,(POS) All Admissions,Not Applicable';
    // OptionMembers = SCAN,POS_DEFAULT,INVOICE,POS_ALL,NA;
    value(0; SCAN)
    {
        Caption = 'Scan';
    }
    value(1; POS_DEFAULT)
    {
        Caption = '(POS) Default Admission';
    }
    value(2; INVOICE)
    {
        Caption = 'Invoice';
        ObsoleteState = pending;
        ObsoleteTag = 'NPR32.0';
        ObsoleteReason = 'Never implemented.';
    }
    value(3; POS_ALL)
    {
        Caption = '(POS) All Admissions';
    }
    value(4; NA)
    {
        Caption = 'Not Applicable';
    }
}