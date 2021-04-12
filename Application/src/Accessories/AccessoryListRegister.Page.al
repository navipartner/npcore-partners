page 6014509 "NPR Accessory List - Register"
{
    Caption = 'Accessories List Register';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Accessory/Spare Part";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
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
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field';
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
            }
        }
    }

    actions
    {
    }
}

