#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151269 "NPR NPRE Menu Item"
{
    Access = Internal;
    Caption = 'Restaurant Menu Item';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Menu Items Part";
    LookupPageID = "NPR NPRE Menu Items Part";

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(2; "Menu Code"; Code[20])
        {
            Caption = 'Menu Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Menu".Code where("Restaurant Code" = field("Restaurant Code"));
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Menu Category"."Category Code" where("Restaurant Code" = field("Restaurant Code"), "Menu Code" = field("Menu Code"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(25; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            NotBlank = true;
        }
        field(30; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Description" WHERE("No." = field("Item No.")));
            Editable = false;
        }

        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Item No." = filter(<> '')) "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(35; "Has Addons"; Boolean)
        {
            Caption = 'Has Addons';
            FieldClass = FlowField;
            CalcFormula = exist(Item where("No." = field("Item No."), "NPR Item AddOn No." = filter(<> '')));
            Editable = false;
        }
        field(40; "Captions Filled"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("NPR NPRE Menu Item Translation" WHERE("External System Id" = field(SystemId)));
        }
        field(41; "Has Upsells"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("NPR NPRE Upsell" WHERE("External Table" = const("NPR NPRE Upsell Table"::MenuItem), "External System Id" = field(SystemId)));
        }
        field(42; "Has Picture"; Boolean)
        {
            Caption = 'Has Picture';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR CloudflareMediaLink" WHERE(TableNumber = const(6151269), RecordId = field(SystemId), MediaSelector = const("NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE)));
            Editable = false;
        }
        field(50; "Sort Key"; Integer)
        {
            Caption = 'Sort Key';
        }
        field(60; Status; Enum "NPR NPRE Menu Item Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = Active;
        }
    }

    keys
    {
        key(Key1; "Restaurant Code", "Menu Code", "Category Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Restaurant Code", "Menu Code", "Category Code", "Sort Key")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    var
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        MenuItem.SetCurrentKey("Restaurant Code", "Menu Code", "Category Code", "Sort Key");
        MenuItem.Ascending(true);
        MenuItem.SetRange("Restaurant Code", Rec."Restaurant Code");
        MenuItem.SetRange("Menu Code", Rec."Menu Code");
        MenuItem.SetRange("Category Code", Rec."Category Code");
        if MenuItem.FindLast() then;

        Rec."Sort Key" := MenuItem."Sort Key" + 10000;
    end;

    trigger OnDelete()
    var
        Upsell: Record "NPR NPRE Upsell";
        NPREMenuItemTranslation: Record "NPR NPRE Menu Item Translation";
    begin
        Upsell.SetRange("External System Id", SystemId);
        Upsell.DeleteAll(true);

        NPREMenuItemTranslation.SetRange("External System Id", SystemId);
        NPREMenuItemTranslation.DeleteAll(true);
    end;

    procedure MoveUp()
    var
        NPREMenuItem: Record "NPR NPRE Menu Item";
        tmpSortKey: Integer;
    begin
        NPREMenuItem.SetCurrentKey("Restaurant Code", "Menu Code", "Category Code", "Sort Key");
        NPREMenuItem.Ascending(true);
        NPREMenuItem.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREMenuItem.SetRange("Menu Code", Rec."Menu Code");
        NPREMenuItem.SetRange("Category Code", Rec."Category Code");
        NPREMenuItem.SetFilter("Sort Key", '<%1', Rec."Sort Key");
        if not NPREMenuItem.FindLast() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREMenuItem."Sort Key";
        NPREMenuItem."Sort Key" := -Random(10000);
        NPREMenuItem.Modify();
        Rec.Modify();
        NPREMenuItem."Sort Key" := tmpSortKey;
        NPREMenuItem.Modify();
    end;

    procedure MoveDown()
    var
        NPREMenuItem: Record "NPR NPRE Menu Item";
        tmpSortKey: Integer;
    begin
        NPREMenuItem.SetCurrentKey("Restaurant Code", "Menu Code", "Category Code", "Sort Key");
        NPREMenuItem.Ascending(true);
        NPREMenuItem.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREMenuItem.SetRange("Menu Code", Rec."Menu Code");
        NPREMenuItem.SetRange("Category Code", Rec."Category Code");
        NPREMenuItem.SetFilter("Sort Key", '>%1', Rec."Sort Key");
        if not NPREMenuItem.FindFirst() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREMenuItem."Sort Key";
        NPREMenuItem."Sort Key" := -Random(10000);
        NPREMenuItem.Modify();
        Rec.Modify();
        NPREMenuItem."Sort Key" := tmpSortKey;
        NPREMenuItem.Modify();
    end;

}
#endif
