enum 6014524 "NPR RS Fiscal Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Proforma Sales")
    {
        Caption = 'Proforma sent to Tax Core';
    }
    value(2; "Proforma Refund")
    {
        Caption = 'Proforma Refund sent to Tax Core';
    }
    value(3; "Normal Sale")
    {
        Caption = 'Normal Sale sent to Tax Core';
    }
    value(4; "Normal Refund")
    {
        Caption = 'Normal Refund sent to Tax Core';
    }
    value(5; "Advance Sale")
    {
        Caption = 'Advance Sale sent to Tax Core';
    }
    value(6; "Advance Refund")
    {
        Caption = 'Advance Refund sent to Tax Core';
    }
}