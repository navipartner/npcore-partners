enum 6059851 "NPR Ext. JQ Refresher Options"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; create)
    {
        Caption = 'create';
    }
    value(1; delete)
    {
        Caption = 'delete';
    }
    value(2; select)
    {
        Caption = 'select';
    }
}
