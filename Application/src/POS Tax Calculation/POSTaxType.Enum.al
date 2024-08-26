﻿enum 6150757 "NPR POS Tax Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Sales Tax")
    {
        Caption = 'Sales Tax';
    }
    value(1; "Excise Tax")
    {
        Caption = 'Excise Tax';
    }
    value(2; "Normal Tax")
    {
        Caption = 'Normal Tax';
    }
    value(3; "Reverse Tax")
    {
        Caption = 'Reverse Tax';
    }
    value(4; "No Taxable VAT")
    {
        Caption = 'No Taxable VAT';
    }
}
