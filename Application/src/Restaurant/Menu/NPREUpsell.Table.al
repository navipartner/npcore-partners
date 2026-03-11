#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151266 "NPR NPRE Upsell"
{
    Access = Internal;
    Caption = 'Restaurant Upsell';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "External Table"; Enum "NPR NPRE Upsell Table")
        {
            Caption = 'External Table';
        }
        field(2; "External System Id"; Guid)
        {
            Caption = 'External System Id';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Menu Item System Id"; Guid)
        {
            Caption = 'Menu Item';
            TableRelation = "NPR NPRE Menu Item".SystemId;

            trigger OnLookup()
            var
                MenuItem: Record "NPR NPRE Menu Item";
                MenuItem2: Record "NPR NPRE Menu Item";
                Menu: Record "NPR NPRE Menu";
            begin
                case "External Table" of
                    Enum::"NPR NPRE Upsell Table"::MenuItem:
                        begin
                            MenuItem2.GetBySystemId("External System Id");
                            MenuItem.SetRange("Restaurant Code", MenuItem2."Restaurant Code");
                            MenuItem.SetRange("Menu Code", MenuItem2."Menu Code");
                            if Page.RunModal(Page::"NPR NPRE Menu Items", MenuItem) = ACTION::LookupOK then
                                "Menu Item System Id" := MenuItem.SystemId;
                        end;
                    Enum::"NPR NPRE Upsell Table"::Menu:
                        begin
                            Menu.GetBySystemId("External System Id");
                            MenuItem.SetRange("Restaurant Code", Menu."Restaurant Code");
                            MenuItem.SetRange("Menu Code", Menu."Code");
                            if Page.RunModal(Page::"NPR NPRE Menu Items", MenuItem) = ACTION::LookupOK then
                                "Menu Item System Id" := MenuItem.SystemId;
                        end;
                end;
            end;
        }
        field(10; "Menu Item Item No."; Code[20])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR NPRE Menu Item"."Item No." where("SystemId" = field("Menu Item System Id")));
        }
        field(11; "Menu Item Item Description"; Text[100])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Menu Item Item No.")));
        }
        field(30; "Sort Key"; Integer)
        {
            Caption = 'Sort Key';
        }
    }

    keys
    {
        key(Key1; "External Table", "External System Id", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "External Table", "External System Id", "Sort Key")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    var
        Upsell: Record "NPR NPRE Upsell";
    begin
        TestField("External System Id");

        Upsell.SetCurrentKey("External Table", "External System Id", "Sort Key");
        Upsell.Ascending(true);
        Upsell.SetRange("External Table", Rec."External Table");
        Upsell.SetRange("External System Id", Rec."External System Id");
        if Upsell.FindLast() then;

        Rec."Sort Key" := Upsell."Sort Key" + 10000;
    end;

    procedure MoveUp()
    var
        NPREUpsell: Record "NPR NPRE Upsell";
        tmpSortKey: Integer;
    begin
        NPREUpsell.SetCurrentKey("External Table", "External System Id", "Sort Key");
        NPREUpsell.Ascending(true);
        NPREUpsell.SetRange("External Table", Rec."External Table");
        NPREUpsell.SetRange("External System Id", Rec."External System Id");
        NPREUpsell.SetFilter("Sort Key", '<%1', Rec."Sort Key");
        if not NPREUpsell.FindLast() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREUpsell."Sort Key";
        NPREUpsell."Sort Key" := -Random(10000);
        NPREUpsell.Modify();
        Rec.Modify();
        NPREUpsell."Sort Key" := tmpSortKey;
        NPREUpsell.Modify();
    end;

    procedure MoveDown()
    var
        NPREUpsell: Record "NPR NPRE Upsell";
        tmpSortKey: Integer;
    begin
        NPREUpsell.SetCurrentKey("External Table", "External System Id", "Sort Key");
        NPREUpsell.Ascending(true);
        NPREUpsell.SetRange("External Table", Rec."External Table");
        NPREUpsell.SetRange("External System Id", Rec."External System Id");
        NPREUpsell.SetFilter("Sort Key", '>%1', Rec."Sort Key");
        if not NPREUpsell.FindFirst() then
            exit;

        tmpSortKey := Rec."Sort Key";
        Rec."Sort Key" := NPREUpsell."Sort Key";
        NPREUpsell."Sort Key" := -Random(10000);
        NPREUpsell.Modify();
        Rec.Modify();
        NPREUpsell."Sort Key" := tmpSortKey;
        NPREUpsell.Modify();
    end;
}
#endif
