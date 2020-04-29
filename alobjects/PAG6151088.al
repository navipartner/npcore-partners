page 6151088 "RIS Retail Inventory Buffer"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    Caption = 'Retail Inventory';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "RIS Retail Inventory Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Inventory;Inventory)
                {
                    Style = Attention;
                    StyleExpr = "Processing Error";
                }
                field("Company Name";"Company Name")
                {
                    Style = Attention;
                    StyleExpr = "Processing Error";
                }
                field("Location Filter";"Location Filter")
                {
                }
                field("Processing Error Message";"Processing Error Message")
                {
                    Visible = ProcessingErrorExists;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;
    begin
        if IsTemporary then
          RetailInventoryBuffer.Copy(Rec,true)
        else
          RetailInventoryBuffer.Copy(Rec);
        RetailInventoryBuffer.Reset;
        RetailInventoryBuffer.SetRange("Processing Error",true);
        ProcessingErrorExists := RetailInventoryBuffer.FindFirst;
    end;

    var
        ProcessingErrorExists: Boolean;
}

