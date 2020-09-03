pageextension 6014421 "NPR Chart of Accounts" extends "Chart of Accounts"
{
    layout
    {
        addafter("Default IC Partner G/L Acc. No")
        {
            field("NPR Retail Payment"; "NPR Retail Payment")
            {
                ApplicationArea = All;
            }
        }
    }
}

