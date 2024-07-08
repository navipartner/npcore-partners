table 6151223 "NPR NpCs Store Stock Item"
{
    Access = Internal;
    Caption = 'Collect Store Stock Item';
    DrillDownPageID = "NPR NpCs Store Stock Items";
    LookupPageID = "NPR NpCs Store Stock Items";

    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            ;
            NotBlank = true;
            TableRelation = "NPR NpCs Store";
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(30; "Stock Qty."; Decimal)
        {
            Caption = 'Stock Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(40; "Last Updated at"; DateTime)
        {
            Caption = 'Last Updated at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store Code", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Last Updated at" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Updated at" := CurrentDateTime;
    end;
}
