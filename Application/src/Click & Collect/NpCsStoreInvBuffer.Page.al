page 6151210 "NPR NpCs Store Inv. Buffer"
{
    Caption = 'Collect Store Inventory List';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Store Inv. Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sku; Sku)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("In Stock"; "In Stock")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetSourceTable(var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    begin
        Rec.Copy(NpCsStoreInventoryBuffer, true);
    end;
}

