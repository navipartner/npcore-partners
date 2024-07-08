page 6014510 "NPR Accessory List"
{
    Extensible = False;
    // NPR5.40/MHA /20180214  CASE 288039 Added field 85 "Unfold in Worksheet"

    Caption = 'Accessories List';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Accessory/Spare Part";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Vendor; Rec.Vendor)
                {

                    ToolTip = 'Specifies the value of the Buy-from Vendor field';
                    ApplicationArea = NPRRetail;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {

                    ToolTip = 'Specifies the value of the Buy-from Vendor Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {

                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Per unit"; Rec."Per unit")
                {

                    ToolTip = 'Specifies the value of the Per unit field';
                    ApplicationArea = NPRRetail;
                }
                field("Add Extra Line Automatically"; Rec."Add Extra Line Automatically")
                {

                    ToolTip = 'Specifies the value of the Add Extra Line Automatically field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Alt. Price"; Rec."Use Alt. Price")
                {

                    ToolTip = 'Specifies the value of the Use Alt. Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity in Dialogue"; Rec."Quantity in Dialogue")
                {

                    ToolTip = 'Specifies the value of the Quantity in Dialogue field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Discount"; Rec."Show Discount")
                {

                    ToolTip = 'Specifies the value of the Show Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Alt. Price"; Rec."Alt. Price")
                {

                    ToolTip = 'Specifies the value of the Alt. Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Unfold in Worksheet"; Rec."Unfold in Worksheet")
                {

                    ToolTip = 'Specifies the value of the Unfold in Worksheet field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

