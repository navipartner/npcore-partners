enum 6014668 "NPR Adyen Rec. Log Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; "Get Report")
    {
        Caption = 'Get Report';
    }
    value(10; "Import Lines")
    {
        Caption = 'Import Lines';
    }
    value(20; "Match Transactions")
    {
        Caption = 'Match Transactions';
    }
    value(30; "Reconcile Transactions")
    {
        Caption = 'Reconcile Transactions';
    }
    value(40; "Post Transactions")
    {
        Caption = 'Post Transactions';
    }
    value(50; "Background Session")
    {
        Caption = 'Background Session';
    }
    value(60; "Validate Report Scheme")
    {
        Caption = 'Validate Report Scheme';
    }
}
