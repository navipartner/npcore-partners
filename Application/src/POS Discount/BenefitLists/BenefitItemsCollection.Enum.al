enum 6014567 "NPR Benefit Items Collection"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(1; "All")
    {
        Caption = 'All';
    }
    value(2; "No Input Needed")
    {
        Caption = 'No Input Needed';
    }
    value(3; "Input Needed")
    {
        Caption = 'Input Needed';
    }
}
