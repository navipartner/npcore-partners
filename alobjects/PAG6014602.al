page 6014602 "NPR Item Variants"
{
    // NPR5.40/TSA /20180329 CASE 308522 Added Inventory and NetChange
    // NPR5.55/ANPA/20200505  CASE 401161 Changed visibility setting of "description 2" to true

    Caption = 'NPR Item Variants';
    DataCaptionFields = "Item No.";
    PageType = List;
    SourceTable = "Item Variant";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory';
                    Editable = false;
                }
                field(NetChange; NetChange)
                {
                    ApplicationArea = All;
                    Caption = 'Net Change';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("V&ariant")
            {
                Caption = 'V&ariant';
                Image = ItemVariant;
                action(Translations)
                {
                    Caption = 'Translations';
                    Image = Translations;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD(Code);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
    begin
        Item.Reset();
        Item.Get(Rec."Item No.");
        Item.SetFilter("No.", '=%1', Rec."Item No.");
        Item.SetFilter("Variant Filter", '=%1', Rec.Code);
        Item.SetFilter("Date Filter", '..%1', Today);
        if (LocationCodeFilter <> '') then
            Item.SetFilter("Location Filter", '=%1', LocationCodeFilter);
        Item.CalcFields(Inventory, "Net Change");
        Inventory := Item.Inventory;
        NetChange := Item."Net Change";
    end;

    var
        Inventory: Decimal;
        NetChange: Decimal;
        LocationCodeFilter: Code[10];

    procedure SetLocationCodeFilter(LocationCodeFilterIn: Code[10])
    begin
        LocationCodeFilter := LocationCodeFilterIn;
    end;
}

