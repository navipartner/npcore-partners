page 6151088 "NPR RIS Retail Inv. Buffer"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR RIS Retail Inv. Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = "Processing Error";
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = "Processing Error";
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; "Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field("Processing Error Message"; "Processing Error Message")
                {
                    ApplicationArea = All;
                    Visible = ProcessingErrorExists;
                    ToolTip = 'Specifies the value of the Processing Error Message field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
    begin
        if IsTemporary then
            RetailInventoryBuffer.Copy(Rec, true)
        else
            RetailInventoryBuffer.Copy(Rec);
        RetailInventoryBuffer.Reset;
        RetailInventoryBuffer.SetRange("Processing Error", true);
        ProcessingErrorExists := RetailInventoryBuffer.FindFirst;
    end;

    var
        ProcessingErrorExists: Boolean;
}

