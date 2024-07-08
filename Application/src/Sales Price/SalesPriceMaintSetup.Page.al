page 6014685 "NPR Sales Price Maint. Setup"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/reference/sales_price_maintenance/';
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
                    ToolTip = 'Specifies the ID of the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ToolTip = 'Specifies the sales type of the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ToolTip = 'Specifies the sales code of the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ToolTip = 'Specifies the price list code of the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency code of the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ToolTip = 'Specifies if the prices should include VAT or not for the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ToolTip = 'Specifies the VAT business posting group for the sales price maintenance.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ToolTip = 'Specifies if an invoice discount should be allowed or not';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ToolTip = 'Specifies if an invoice line discount should be allowed or not';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Unit Price"; Rec."Internal Unit Price")
                {
                    ToolTip = 'Specifies the internal unit price for the sales price maintenance';
                    ApplicationArea = NPRRetail;
                }
                field(Factor; Rec.Factor)
                {
                    ToolTip = 'Specifies the factor for the Factor';
                    ApplicationArea = NPRRetail;
                }
                field("Background Processing"; Rec."Background Processing")
                {
                    ToolTip = 'Specifies if the Sales Price Lists should be updated in background or immediately. If enabled, codeunit 6014481 "NPR Sales Price Maint. Event" should be scheduled to run via job queue and process the modifications in the background.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
