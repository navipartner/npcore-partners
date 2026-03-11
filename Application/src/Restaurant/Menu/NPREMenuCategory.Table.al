#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151273 "NPR NPRE Menu Category"
{
    Access = Internal;
    Extensible = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPR NPRE Restaurant";
        }
        field(2; "Menu Code"; Code[20])
        {
            Caption = 'Menu Code';
            TableRelation = "NPR NPRE Menu".Code where("Restaurant Code" = field("Restaurant Code"));
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
        }
        field(4; "Sort Key"; Integer)
        {
            Caption = 'Sort Key';
        }
        field(10; "Captions Filled"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("NPR NPRE Menu Cat. Translation" WHERE("Restaurant Code" = field("Restaurant Code"), "Menu Code" = field("Menu Code"), "Category Code" = field("Category Code")));
        }
    }

    keys
    {
        key(Key1; "Restaurant Code", "Menu Code", "Category Code")
        {
            Clustered = true;
        }
        key(Key2; "Restaurant Code", "Menu Code", "Sort Key")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    var
        NPREMenuCategory: Record "NPR NPRE Menu Category";
    begin
        NPREMenuCategory.SetCurrentKey("Restaurant Code", "Menu Code", "Sort Key");
        NPREMenuCategory.Ascending(true);
        NPREMenuCategory.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREMenuCategory.SetRange("Menu Code", Rec."Menu Code");
        if NPREMenuCategory.FindLast() then;

        Rec."Sort Key" := NPREMenuCategory."Sort Key" + 10000;
    end;

    procedure MoveUp()
    var
        NPREMenuCategory: Record "NPR NPRE Menu Category";
        tmpSortKey: Integer;
    begin
        NPREMenuCategory.SetCurrentKey("Restaurant Code", "Menu Code", "Sort Key");
        NPREMenuCategory.Ascending(true);
        NPREMenuCategory.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREMenuCategory.SetRange("Menu Code", Rec."Menu Code");
        NPREMenuCategory.SetFilter("Sort Key", '<%1', Rec."Sort Key");
        if not NPREMenuCategory.FindLast() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREMenuCategory."Sort Key";
        NPREMenuCategory."Sort Key" := -Random(10000);
        NPREMenuCategory.Modify();
        Rec.Modify();
        NPREMenuCategory."Sort Key" := tmpSortKey;
        NPREMenuCategory.Modify();
    end;

    procedure MoveDown()
    var
        NPREMenuCategory: Record "NPR NPRE Menu Category";
        tmpSortKey: Integer;
    begin
        NPREMenuCategory.SetCurrentKey("Restaurant Code", "Menu Code", "Sort Key");
        NPREMenuCategory.Ascending(true);
        NPREMenuCategory.SetRange("Restaurant Code", Rec."Restaurant Code");
        NPREMenuCategory.SetRange("Menu Code", Rec."Menu Code");
        NPREMenuCategory.SetFilter("Sort Key", '>%1', Rec."Sort Key");
        if not NPREMenuCategory.FindFirst() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREMenuCategory."Sort Key";
        NPREMenuCategory."Sort Key" := -Random(10000);
        NPREMenuCategory.Modify();
        Rec.Modify();
        NPREMenuCategory."Sort Key" := tmpSortKey;
        NPREMenuCategory.Modify();
    end;
}
#endif
