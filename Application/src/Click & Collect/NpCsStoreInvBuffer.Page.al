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
                    ToolTip = 'Specifies the value of the Sku field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("In Stock"; "In Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the In Stock field';
                }
            }
        }
    }

    procedure SetSourceTable(var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    begin
        Rec.Copy(NpCsStoreInventoryBuffer, true);
    end;
}

