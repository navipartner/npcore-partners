page 6151330 "NPR Voucher Cue"
{
    Extensible = False;
    Caption = 'Retail Voucher Cue';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;

    layout
    {

        area(content)
        {
            cuegroup(Control6150623)
            {

                Caption = 'SALES';
                ShowCaption = true;

                field("Retail Voucher"; Rec."Retail Vouchers")
                {

                    DrillDownPageId = "NPR NpRv Vouchers";
                    ToolTip = 'Specifies the number of the Retail Vouchers. By clicking you can view the list of Retail Vouchers';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    trigger OnOpenPage()

    begin
        NpRvVoucher.Reset();

    end;

    var

        NpRvVoucher: Record "NPR NpRv Voucher";

}
