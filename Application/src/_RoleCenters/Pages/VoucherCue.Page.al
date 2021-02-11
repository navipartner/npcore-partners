page 6151330 "NPR Voucher Cue"
{
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
                    ApplicationArea = All;
                    DrillDownPageId = "NPR NpRv Vouchers";
                    ToolTip = 'Specifies the value of the Retail Vouchers field';
                }

            }
        }
    }

    trigger OnOpenPage()

    begin
        NpRvVoucher.Reset();
        IF NOT NpRvVoucher.FindSet() THEN
            VisibilityRetailVoucher := FALSE
        ELSE
            VisibilityRetailVoucher := TRUE;
    end;

    var

        VisibilityRetailVoucher: Boolean;
        NpRvVoucher: Record "NPR NpRv Voucher";

}
