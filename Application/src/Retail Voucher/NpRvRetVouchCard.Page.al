page 6151019 "NPR NpRv Ret. Vouch. Card"
{
    UsageCategory = None;
    Caption = 'Return Retail Voucher Card';
    SourceTable = "NPR NpRv Ret. Vouch. Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Return Voucher Type"; "Return Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Voucher Type field';
                }
                field("Return Voucher Description"; "Return Voucher Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Voucher Description field';
                }
            }
        }
    }
}

