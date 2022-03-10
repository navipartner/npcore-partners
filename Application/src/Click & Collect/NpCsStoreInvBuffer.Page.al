﻿page 6151210 "NPR NpCs Store Inv. Buffer"
{
    Extensible = False;
    Caption = 'Collect Store Inventory List';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
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

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Sku field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("In Stock"; Rec."In Stock")
                {

                    ToolTip = 'Specifies the value of the In Stock field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetSourceTable(var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    begin
        Rec.Copy(NpCsStoreInventoryBuffer, true);
    end;
}

