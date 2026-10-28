page 6150992 "NPR POS Entry Paym. FactBox"
{
    Extensible = False;
    Caption = 'Payments';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Entry Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ToolTip = 'Specifies the POS payment method used on the transaction.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the payment line.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount paid with this payment method in local currency.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
