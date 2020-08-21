page 6151330 "NP Retail Voucher Cue"
{
    Caption = 'Retail Voucher Cue';
    PageType = CardPart;
    SourceTable = "Retail Sales Cue";

    layout
    {

        area(content)
        {
            cuegroup(Control6150623)
            {

                Caption = 'SALES';
                ShowCaption = true;

                field("Retail Voucher"; "Retail Vouchers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "NpRv Vouchers";
                    //Visible = VisibilityRetailVoucher;

                }

                field("Gift Voucher"; "Gift Vouchers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Gift Voucher List";
                    //Visible = VisibilityGiftVoucher;
                }

                field("Credit Voucher"; "Credit Vouchers")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Credit Voucher List";
                    Visible = VisibilityCreditVoucher;
                    //Visible = false;
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
        NpRvVoucher: Record "NpRv Voucher";
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";


}