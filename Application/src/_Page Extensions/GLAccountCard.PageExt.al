pageextension 6014422 "NPR G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; "NPR Retail Payment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Retail Payment field';
            }
        }
    }
}

