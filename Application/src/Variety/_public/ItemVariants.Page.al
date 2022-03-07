page 6014602 "NPR Item Variants"
{
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
        Item.Get(Rec."Item No.");
        Item.SetRange("Variant Filter", Rec.Code);
        Item.SetFilter("Date Filter", '..%1', Today);
        if (LocationCodeFilter <> '') then
            Item.SetRange("Location Filter", LocationCodeFilter);
        Item.CalcFields(Inventory, "Net Change");
        Inventory := Item.Inventory;
        NetChange := Item."Net Change";
    end;

    internal procedure SetLocationCodeFilter(LocationCode: Code[10])
    begin
        LocationCodeFilter := LocationCode;
    end;

    var
        Inventory: Decimal;
        NetChange: Decimal;
        LocationCodeFilter: Code[10];
}

