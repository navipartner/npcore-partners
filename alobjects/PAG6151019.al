page 6151019 "NpRv Return Voucher Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Return Retail Voucher Card';
    SourceTable = "NpRv Return Voucher Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Return Voucher Type"; "Return Voucher Type")
                {
                    ApplicationArea = All;
                }
                field("Return Voucher Description"; "Return Voucher Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

