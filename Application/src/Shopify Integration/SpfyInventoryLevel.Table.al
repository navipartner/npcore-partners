#if not BC17
table 6150816 "NPR Spfy Inventory Level"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify Inventory Level';
    LookupPageId = "NPR Spfy Inventory Levels";
    DrillDownPageId = "NPR Spfy Inventory Levels";

    fields
    {
        field(1; "Shopify Location ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Shopify Location ID';
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item WHERE(Type = CONST(Inventory));
        }
        field(3; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(4; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(10; Inventory; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Last Updated at"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Updated at';
        }
    }

    keys
    {
        key(PK; "Shopify Store Code", "Shopify Location ID", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
        key(ByItem; "Item No.", "Variant Code") { }
        key(ByItemAtLocation; "Shopify Store Code", "Item No.", "Shopify Location ID", "Variant Code") { }
    }

    trigger OnInsert()
    begin
        "Last Updated at" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Updated at" := CurrentDateTime;
    end;

    procedure AvailableInventory(): Decimal
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        If Inventory < 0 then
            if not SpfyIntegrationMgt.IsSendNegativeInventory("Shopify Store Code") then
                exit(0);
        Exit(Round(Inventory, 1, '<'));
    end;
}
#endif