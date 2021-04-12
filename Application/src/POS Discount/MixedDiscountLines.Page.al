page 6014451 "NPR Mixed Discount Lines"
{
    Caption = 'Mix Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Mixed Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                Visible = (MixType <> 1);
                field("Disc. Grouping Type"; Rec."Disc. Grouping Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disc. Grouping Type field';
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the referenced item number.';
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Disc. Grouping Type" = Rec."Disc. Grouping Type"::Item);
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Enabled = Lot;
                    Visible = Lot;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit cost"; Rec."Unit cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Unit price"; Rec."Unit price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Unit price incl. VAT"; Rec."Unit price incl. VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Mix Discount Price';
                    ToolTip = 'Specifies the value of the Mix Discount Price field';

                    trigger OnValidate()
                    var
                        CantChangePriceErr: Label 'You can''t change Mix Discount Price.';
                    begin
                        if DiscountType = DiscountType::"Multiple Discount Levels" then
                            Error(CantChangePriceErr);
                    end;
                }
            }
            repeater(MixLines)
            {
                Visible = (MixType = 1);
                field(NoCom; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Part Code';
                    Lookup = true;
                    LookupPageID = "NPR Mixed Discount Part List";
                    ToolTip = 'Specifies the value of the Part Code field';
                }
                field(DescriptionCom; GetDescription())
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("CalcMinQty()"; CalcMinQty())
                {
                    ApplicationArea = All;
                    Caption = 'Min. Qty.';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = (MixType = 1);
                    ToolTip = 'Specifies the value of the Min. Qty. field';
                }
                field(MinimumDiscount; CalcExpectedAmount(false))
                {
                    ApplicationArea = All;
                    Caption = 'Min. Expected Amount';
                    ToolTip = 'Specifies the value of the Min. Expected Amount field';
                }
                field(MaximumDiscount; CalcExpectedAmount(true))
                {
                    ApplicationArea = All;
                    Caption = 'Max. Expected Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Max. Expected Amount field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("New Part")
            {
                Image = NewItem;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                Visible = (MixType = 1);
                ApplicationArea = All;
                ToolTip = 'Executes the New Part action';

                trigger OnAction()
                var
                    MixedDiscount: Record "NPR Mixed Discount";
                begin
                    MixedDiscount.Init();
                    MixedDiscount.Code := '';
                    MixedDiscount."Mix Type" := MixedDiscount."Mix Type"::"Combination Part";
                    MixedDiscount.Insert(true);

                    Rec.Init();
                    Rec."Disc. Grouping Type" := Rec."Disc. Grouping Type"::"Mix Discount";
                    Rec.Validate("No.", MixedDiscount.Code);
                    Rec.Insert(true);

                    Commit();
                    PAGE.Run(PAGE::"NPR Mixed Discount", MixedDiscount);
                end;
            }
            action("Part Card")
            {
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR Mixed Discount";
                RunPageLink = Code = FIELD("No.");
                Visible = (MixType = 1);
                ApplicationArea = All;
                ToolTip = 'Executes the Part Card action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TotalAmount := GetTotalAmount;
    end;

    var
        Lot: Boolean;
        DiscountType: Enum "NPR Mixed Discount Type";
        MixType: Integer;
        TotalAmount: Decimal;

    local procedure CalcExpectedAmount(FindMaxDisc: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary;
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
    begin
        if Rec."Disc. Grouping Type" <> Rec."Disc. Grouping Type"::"Mix Discount" then
            exit(0);

        if not MixedDiscount.Get(Rec."No.") then
            exit(0);

        exit(MixedDiscountMgt.CalcExpectedAmountPerBatch(MixedDiscount, FindMaxDisc, TempPriorityBuffer));
    end;

    local procedure CalcMinQty(): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if Rec."Disc. Grouping Type" <> Rec."Disc. Grouping Type"::"Mix Discount" then
            exit(0);
        if not MixedDiscount.Get(Rec."No.") then
            exit(0);

        exit(MixedDiscount.CalcMinQty());
    end;

    local procedure GetDescription(): Text
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if Rec."Disc. Grouping Type" <> Rec."Disc. Grouping Type"::"Mix Discount" then
            exit('');
        if not MixedDiscount.Get(Rec."No.") then
            exit('');

        exit(MixedDiscount.Description);
    end;

    procedure UpdateMixedDiscountView(MixedDiscount: Record "NPR Mixed Discount")
    begin
        Lot := MixedDiscount.Lot;
        MixType := MixedDiscount."Mix Type";
        DiscountType := MixedDiscount."Discount Type";

        Rec.FilterGroup(2);
        case MixType of
            MixedDiscount."Mix Type"::Combination:
                Rec.SetRange("Disc. Grouping Type", Rec."Disc. Grouping Type"::"Mix Discount");
            else
                Rec.SetRange("Disc. Grouping Type", Rec."Disc. Grouping Type"::Item, Rec."Disc. Grouping Type"::"Item Disc. Group");
        end;
        Rec.FilterGroup(0);

        CurrPage.Update(false);
    end;

    procedure GetTotalAmount(): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if not MixedDiscount.Get(Rec.Code) then
            exit;

        exit(MixedDiscount."Total Amount");
    end;
}

