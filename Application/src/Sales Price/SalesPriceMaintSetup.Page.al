page 6014685 "NPR Sales Price Maint. Setup"
{
    // NPR5.25/CLVA/20160628 CASE 244461 : Sales Price Maintenance

    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Sales Price Maint. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Code field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Invoice Disc. field';
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Line Disc. field';
                }
                field("Internal Unit Price"; "Internal Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Unit Price field';
                }
                field(Factor; Factor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Factor field';
                }
            }
        }
    }

    actions
    {
    }
}

