page 6151088 "NPR RIS Retail Inv. Buffer"
{
    Caption = 'Retail Inventory';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR RIS Retail Inv. Buffer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Inventory; Rec.Inventory)
                {

                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Filter"; Rec."Location Filter")
                {

                    ToolTip = 'Specifies the value of the Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Error Message"; Rec."Processing Error Message")
                {

                    Visible = ProcessingErrorExists;
                    ToolTip = 'Specifies the value of the Processing Error Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TempRetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
    begin
        if Rec.IsTemporary then
            TempRetailInventoryBuffer.Copy(Rec, true)
        else
            TempRetailInventoryBuffer.Copy(Rec);
        TempRetailInventoryBuffer.Reset();
        TempRetailInventoryBuffer.SetRange("Processing Error", true);
        ProcessingErrorExists := TempRetailInventoryBuffer.FindFirst();
    end;

    var
        ProcessingErrorExists: Boolean;
}