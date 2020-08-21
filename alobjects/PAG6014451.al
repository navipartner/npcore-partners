page 6014451 "Mixed Discount Lines"
{
    // NPR5.26/BHR /20160712  CASE 246594 Display field Cross reference
    //                                     Set property 'Delayed on insert'= true
    // NPR5.31/MHA /20170110  CASE 262904 Added functions for enabling view: MixedDiscount."Mix Type"::::Combination
    //                                    Deleted unused functions and variables
    // NPR5.54/YAHA/20200303  CASE 393386 Added Mix Discount Price
    // NPR5.55/YAHA/20200513  CASE 393386 Code review Mix Discount Price
    // NPR5.55/ALPO/20200714  CASE 412946 Set Visible property of Mix Discount Price to "(DiscountType <> 4)"

    Caption = 'Mix Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Mixed Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                Visible = (MixType <> 1);
                field("Disc. Grouping Type"; "Disc. Grouping Type")
                {
                    ApplicationArea = All;
                    OptionCaption = 'Item,Item Group,Item Disc. Group';
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Enabled = ("Disc. Grouping Type" = 0);
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Enabled = Lot;
                    Visible = Lot;
                }
                field("Unit cost"; "Unit cost")
                {
                    ApplicationArea = All;
                }
                field("Unit price"; "Unit price")
                {
                    ApplicationArea = All;
                }
                field("Unit price incl. VAT"; "Unit price incl. VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                }
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Mix Discount Price';
                    Visible = (DiscountType <> 4);
                }
            }
            repeater(MixLines)
            {
                Visible = (MixType = 1);
                field(NoCom; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'Part Code';
                    Lookup = true;
                    LookupPageID = "Mixed Discount Part List";
                }
                field(DescriptionCom; GetDescription())
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                }
                field("CalcMinQty()"; CalcMinQty())
                {
                    ApplicationArea = All;
                    Caption = 'Min. Qty.';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = (MixType = 1);
                }
                field(MinimumDiscount; CalcExpectedAmount(false))
                {
                    ApplicationArea = All;
                    Caption = 'Min. Expected Amount';
                }
                field(MaximumDiscount; CalcExpectedAmount(true))
                {
                    ApplicationArea = All;
                    Caption = 'Max. Expected Amount';
                    Editable = false;
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
                PromotedIsBig = true;
                Visible = (MixType = 1);

                trigger OnAction()
                var
                    MixedDiscount: Record "Mixed Discount";
                begin
                    //-NPR5.31 [262904]
                    MixedDiscount.Init;
                    MixedDiscount.Code := '';
                    MixedDiscount."Mix Type" := MixedDiscount."Mix Type"::"Combination Part";
                    MixedDiscount.Insert(true);

                    Init;
                    "Disc. Grouping Type" := "Disc. Grouping Type"::"Mix Discount";
                    Validate("No.", MixedDiscount.Code);
                    Insert(true);

                    Commit;
                    PAGE.Run(PAGE::"Mixed Discount", MixedDiscount);
                    //+NPR5.31 [262904]
                end;
            }
            action("Part Card")
            {
                Image = Item;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "Mixed Discount";
                RunPageLink = Code = FIELD("No.");
                Visible = (MixType = 1);
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.31 [262904]
        //BeregnBesparelse;
        //OnAfterGetCurrRecord;
        //+NPR5.31 [262904]
        //-NPR5.55 [393386]
        TotalAmount := GetTotalAmount;
        //+NPR5.55 [393386]
    end;

    trigger OnInit()
    begin
        //-NPR5.31 [262904]
        //QuantityEnabled := TRUE;
        //+NPR5.31 [262904]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.31 [262904]
        //OnAfterGetCurrRecord;
        //+NPR5.31 [262904]
    end;

    var
        Text10600000: Label 'Enter Belongs to Item Group No. on item %1';
        Text10600001: Label 'An error has occured in the VAT settings. Check style sheet posting on the item card!';
        Text10600002: Label 'Saving %1';
        Text10600003: Label 'Saving %1 %2 %3';
        Lot: Boolean;
        DiscountType: Integer;
        MixType: Integer;
        TotalAmount: Decimal;

    local procedure CalcExpectedAmount(FindMaxDisc: Boolean) ExpectedDiscAmount: Decimal
    var
        MixedDiscount: Record "Mixed Discount";
        TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary;
        MixedDiscountMgt: Codeunit "Mixed Discount Management";
    begin
        //-NPR5.31 [262904]
        if "Disc. Grouping Type" <> "Disc. Grouping Type"::"Mix Discount" then
            exit(0);

        if not MixedDiscount.Get("No.") then
            exit(0);

        exit(MixedDiscountMgt.CalcExpectedAmountPerBatch(MixedDiscount, FindMaxDisc, TempPriorityBuffer));
        //+NPR5.31 [262904]
    end;

    local procedure CalcMinQty(): Decimal
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //-NPR5.31 [262904]
        if "Disc. Grouping Type" <> "Disc. Grouping Type"::"Mix Discount" then
            exit(0);
        if not MixedDiscount.Get("No.") then
            exit(0);

        exit(MixedDiscount.CalcMinQty());
        //+NPR5.31 [262904]
    end;

    local procedure GetDescription(): Text
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //+NPR5.31 [262904]
        if "Disc. Grouping Type" <> "Disc. Grouping Type"::"Mix Discount" then
            exit('');
        if not MixedDiscount.Get("No.") then
            exit('');

        exit(MixedDiscount.Description);
        //+NPR5.31 [262904]
    end;

    procedure UpdateMixedDiscountView(MixedDiscount: Record "Mixed Discount")
    begin
        //-NPR5.31 [262904]
        Lot := MixedDiscount.Lot;
        MixType := MixedDiscount."Mix Type";
        DiscountType := MixedDiscount."Discount Type";  //NPR5.55 [412946]

        FilterGroup(2);
        case MixType of
            MixedDiscount."Mix Type"::Combination:
                SetRange("Disc. Grouping Type", "Disc. Grouping Type"::"Mix Discount");
            else
                SetRange("Disc. Grouping Type", "Disc. Grouping Type"::Item, "Disc. Grouping Type"::"Item Disc. Group");
        end;
        FilterGroup(0);

        CurrPage.Update(false);
        //+NPR5.31 [262904]
    end;

    procedure GetTotalAmount(): Decimal
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //-NPR5.55 [393386]
        if not MixedDiscount.Get(Code) then
            exit;

        exit(MixedDiscount."Total Amount");
        //+NPR5.55 [393386]
    end;
}

