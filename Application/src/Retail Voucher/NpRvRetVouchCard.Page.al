page 6151019 "NPR NpRv Ret. Vouch. Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Return Retail Voucher Card';
    SourceTable = "NPR NpRv Ret. Vouch. Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Return Voucher Type"; Rec."Return Voucher Type")
                {

                    ToolTip = 'Specifies the value of the Return Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Voucher Description"; Rec."Return Voucher Description")
                {

                    ToolTip = 'Specifies the value of the Return Voucher Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

