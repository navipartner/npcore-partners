enum 6014661 "NPR Adyen Rec. Line Status"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; Matched)
    {
        Caption = 'Matched';
    }
    value(20; "Matched Manually")
    {
        Caption = 'Matched Manually';
    }
    value(30; "Failed to Match")
    {
        Caption = 'Failed to Match';
    }
    value(40; Reconciled)
    {
        Caption = 'Reconciled';
    }
    value(45; "Failed to Post")
    {
        Caption = 'Failed to Post';
    }
    value(50; Posted)
    {
        Caption = 'Posted';
    }
    value(55; "Posted Failed to Match")
    {
        Caption = 'Posted Failed to Match';
    }
    value(60; "Not to be Posted")
    {
        Caption = 'Not to be Posted';
    }
    value(70; "Not to be Matched")
    {
        Caption = 'Not to be Matched';
    }
    value(80; "Not to be Reconciled")
    {
        Caption = 'Not to be Reconciled';
    }
    value(90; "Failed to Reconcile")
    {
        Caption = 'Failed to Reconcile';
    }
}
