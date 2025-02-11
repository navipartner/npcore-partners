enum 6059787 "NPR ES Audit Entry Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(1; "Customer Information")
    {
        Caption = 'Customer Information';
    }
}