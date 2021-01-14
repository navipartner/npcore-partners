page 6151088 "NPR RIS Retail Inv. Buffer"
{
    Caption = 'Retail Inventory';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR RIS Retail Inv. Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field("Processing Error Message"; Rec."Processing Error Message")
                {
                    ApplicationArea = All;
                    Visible = ProcessingErrorExists;
                    ToolTip = 'Specifies the value of the Processing Error Message field';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
    begin
        if Rec.IsTemporary then
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