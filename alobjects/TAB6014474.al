table 6014474 "Item Replenishment by Store"
{
    // NPR4.16/TJ/20151115 CASE 222281 Table Created

    Caption = 'Item Replenishment by Store';

    fields
    {
        field(1;"Store Group Code";Code[20])
        {
            Caption = 'Store Group Code';
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(10;"Reorder Policy";Option)
        {
            Caption = 'Reorder Policy';
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order";
        }
        field(20;"Reorder Point";Decimal)
        {
            Caption = 'Reorder Point';

            trigger OnValidate()
            begin
                "Reorder Point Text" := Format("Reorder Point");
            end;
        }
        field(21;"Reorder Point Text";Text[30])
        {
            Caption = 'Reorder Point Text';

            trigger OnValidate()
            begin
                if "Reorder Point Text" = '' then
                  "Reorder Point" := 0
                else
                  Evaluate("Reorder Point","Reorder Point Text");
            end;
        }
        field(30;"Reorder Quantity";Decimal)
        {
            Caption = 'Reorder Quantity';

            trigger OnValidate()
            begin
                "Reorder Quantity Text" := Format("Reorder Quantity");
            end;
        }
        field(31;"Reorder Quantity Text";Text[30])
        {
            Caption = 'Reorder Quantity Text';

            trigger OnValidate()
            begin
                if "Reorder Quantity Text" = '' then
                  "Reorder Quantity" := 0
                else
                  Evaluate("Reorder Quantity","Reorder Quantity Text");
            end;
        }
        field(40;"Maximum Inventory";Decimal)
        {
            Caption = 'Maximum Inventory';

            trigger OnValidate()
            begin
                "Maximum Inventory Text" := Format("Maximum Inventory");
            end;
        }
        field(41;"Maximum Inventory Text";Text[30])
        {
            Caption = 'Maximum Inventory Text';

            trigger OnValidate()
            begin
                if "Maximum Inventory Text" = '' then
                  "Maximum Inventory" := 0
                else
                  Evaluate("Maximum Inventory","Maximum Inventory Text");
            end;
        }
        field(50;"Item Description";Text[30])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60;"Variant Description";Text[30])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
        }
        field(6059972;"Master Record Reference";Text[250])
        {
            Caption = 'Master Record Reference';
        }
    }

    keys
    {
        key(Key1;"Store Group Code","Item No.","Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}

