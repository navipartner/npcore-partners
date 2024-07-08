page 6151092 "NPR Item Benefit List Subform"
{
    Extensible = false;
    Caption = 'Item Benefit List Subform';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Item Benefit List Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. of the benefit item.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the variant code of the benefit item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the benefit item.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the quantity of the benefit item.';
                }

                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unit price of the benefit item.';
                }
            }
        }
    }

}