page 6151183 "NPR CRO POS Paym. Method Mapp."
{
    ApplicationArea = NPRCROFiscal;
    Caption = 'CRO POS Payment Method Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR CRO POS Paym. Method Mapp.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Payment Method Code.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the CRO Payment Method that relates to the selected POS Payment Method.';
                }
            }
        }
    }
}