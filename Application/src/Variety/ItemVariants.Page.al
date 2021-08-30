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

            }
        }

        area(FactBoxes)
        {
            part(ItemVariantsFactBox; "NPR Item Variants FactBox")
            {

                Caption = 'Availability FactBox';
                SubPageLink = "No." = FIELD("Item No.");
                ApplicationArea = all;
                Visible = true;

            }
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
    end;

    var
        LocationCodeFilter: Code[10];

    procedure SetLocationCodeFilter(LocationCodeFilterIn: Code[10])
    begin
        LocationCodeFilter := LocationCodeFilterIn;
    end;
}

