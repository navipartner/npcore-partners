#IF NOT BC17 AND NOT BC18
enumextension 6014404 "NPR Reten. Pol. Deleting" extends "Reten. Pol. Deleting"
{
    value(6014400; "NPR Data Archive")
    {
        Caption = 'Data Archive';
        Implementation = "Reten. Pol. Deleting" = "NPR Reten. Pol. Delete. Impl.";
    }
    value(6014401; "NPR Nc Task")
    {
        Caption = 'Nc Task';
        Implementation = "Reten. Pol. Deleting" = "NPR Nc Task Delete Impl.";
    }
}
#ENDIF