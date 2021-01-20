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

                field("Gift Voucher"; Rec."Gift Vouchers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "NPR Gift Voucher List";
                    ToolTip = 'Specifies the value of the Gift Vouchers field';
                }

                field("Credit Voucher"; Rec."Credit Vouchers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "NPR Credit Voucher List";
                    Visible = VisibilityCreditVoucher;
                    ToolTip = 'Specifies the value of the Credit Vouchers field';
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

        GiftVoucher.Reset();
        IF NOT GiftVoucher.FindSet() then
            VisibilityGiftVoucher := FALSE
        ELSE
            VisibilityGiftVoucher := TRUE;

        CreditVoucher.Reset();
        IF NOT CreditVoucher.FindSet() then
            VisibilityCreditVoucher := FALSE
        ELSE
            VisibilityCreditVoucher := TRUE;

    end;

    var

        VisibilityRetailVoucher: Boolean;
        VisibilityGiftVoucher: Boolean;
        VisibilityCreditVoucher: Boolean;
        NpRvVoucher: Record "NPR NpRv Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
        CreditVoucher: Record "NPR Credit Voucher";


}
