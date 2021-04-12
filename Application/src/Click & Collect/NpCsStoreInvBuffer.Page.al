page 6151210 "NPR NpCs Store Inv. Buffer"
{
    Caption = 'Collect Store Inventory List';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Store Inv. Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sku; Rec.Sku)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Sku field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("In Stock"; Rec."In Stock")
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

