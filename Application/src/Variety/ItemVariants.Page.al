page 6014602 "NPR Item Variants"
{
    // NPR5.40/TSA /20180329 CASE 308522 Added Inventory and NetChange
    // NPR5.55/ANPA/20200505  CASE 401161 Changed visibility setting of "description 2" to true

    Caption = 'NPR Item Variants';
    DataCaptionFields = "Item No.";
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Item Variant";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Inventory)
                {

                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field(NetChange; NetChange)
                {

                    Caption = 'Net Change';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Net Change field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Translations action';
                    ApplicationArea = NPRRetail;
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

