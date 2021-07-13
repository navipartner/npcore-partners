page 6014509 "NPR Accessory List - Register"
{
    Caption = 'Accessories List Register';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Accessory/Spare Part";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
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
                field(Inventory; Rec.Inventory)
                {

                    ToolTip = 'Specifies the value of the Inventory field';
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
            }
        }
    }

    actions
    {
    }
}

