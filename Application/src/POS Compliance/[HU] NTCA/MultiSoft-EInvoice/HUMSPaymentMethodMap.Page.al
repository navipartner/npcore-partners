page 6151364 "NPR HU MS Payment Method Map."
{
    ApplicationArea = NPRHUMultiSoftEInv;
    Caption = 'HU Payment Method Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU MS Payment Method Map.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodsMapping)
            {
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                }
                field(Cash; Rec.Cash)
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Cash field.';
                }
                field(Card; Rec.Card)
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Card field.';
                }
                field(Voucher; Rec.Voucher)
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Voucher field.';
                }
            }
        }
    }
}