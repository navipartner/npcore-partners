page 6014510 "NPR Accessory List"
{
    // NPR5.40/MHA /20180214  CASE 288039 Added field 85 "Unfold in Worksheet"

    Caption = 'Accessories List';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Accessory/Spare Part";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Vendor; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor field';
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor Name field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Per unit"; Rec."Per unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Per unit field';
                }
                field("Add Extra Line Automatically"; Rec."Add Extra Line Automatically")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Add Extra Line Automatically field';
                }
                field("Use Alt. Price"; Rec."Use Alt. Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Alt. Price field';
                }
                field("Quantity in Dialogue"; Rec."Quantity in Dialogue")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity in Dialogue field';
                }
                field("Show Discount"; Rec."Show Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Discount field';
                }
                field("Alt. Price"; Rec."Alt. Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alt. Price field';
                }
                field("Unfold in Worksheet"; Rec."Unfold in Worksheet")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unfold in Worksheet field';
                }
            }
        }
    }

    actions
    {
    }
}

