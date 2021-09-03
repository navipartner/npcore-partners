page 6014685 "NPR Sales Price Maint. Setup"
{
    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Sales Price Maint. Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ToolTip = 'Specifies the value of the Sales Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ToolTip = 'Specifies the value of the Price List Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ToolTip = 'Specifies the value of the Allow Invoice Disc. field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ToolTip = 'Specifies the value of the Allow Line Disc. field';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Unit Price"; Rec."Internal Unit Price")
                {
                    ToolTip = 'Specifies the value of the Internal Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field(Factor; Rec.Factor)
                {
                    ToolTip = 'Specifies the value of the Factor field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
