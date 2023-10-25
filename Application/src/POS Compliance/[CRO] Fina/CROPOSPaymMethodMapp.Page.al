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
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("CRO Payment Method"; Rec."CRO Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the CRO Payment Method field.';
                }
            }
        }
    }
}