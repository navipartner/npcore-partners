page 6151210 "NpCs Store Inventory Buffer"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store Inventory List';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NpCs Store Inventory Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sku;Sku)
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field(Description;Description)
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Description 2";"Description 2")
                {
                }
                field(Quantity;Quantity)
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field(Inventory;Inventory)
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("In Stock";"In Stock")
                {
                }
            }
        }
    }

    actions
    {
    }

    procedure SetSourceTable(var NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary)
    begin
        Rec.Copy(NpCsStoreInventoryBuffer,true);
    end;
}

