page 6151597 "NPR NpDc Coupon List Items"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Coupon List Items';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Coupon List Item";
    SourceTableView = SORTING("Coupon Type", "Line No.")
                      WHERE("Line No." = FILTER(>= 0));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Total)
            {
                Caption = 'Total';
                field(TotalMaxQty; MaxQty)
                {

                    BlankZero = true;
                    Caption = 'Max. Quantity per Coupon';
                    DecimalPlaces = 0 : 5;
                    Importance = Promoted;
                    Visible = (NOT ValidationView);
                    ToolTip = 'Specifies the value of the Max. Quantity per Coupon field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        //-NPR5.45 [312991]
                        SetTotals();
                        //+NPR5.45 [312991]
                    end;
                }
                field(LotValidation; LotValidation)
                {

                    Caption = 'Lot Validation';
                    Visible = ValidationView;
                    ToolTip = 'Specifies the value of the Lot Validation field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        //-NPR5.46 [327366]
                        SetTotals();
                        //+NPR5.46 [327366]
                    end;
                }
                group(Control6014417)
                {
                    ShowCaption = false;
                    Visible = (NOT LotValidation);
                    field(TotalValidQty; ValidQty)
                    {

                        BlankZero = true;
                        Caption = 'Validation Quantity';
                        Visible = (ValidationView);
                        ToolTip = 'Specifies the value of the Validation Quantity field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            //-NPR5.46 [327366]
                            SetTotals();
                            //+NPR5.46 [327366]
                        end;
                    }
                }
            }
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Discount Amount"; Rec."Max. Discount Amount")
                {

                    Visible = (NOT ValidationView);
                    ToolTip = 'Specifies the value of the Max. Discount Amount per Coupon field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Quantity"; Rec."Max. Quantity")
                {

                    Visible = (NOT ValidationView);
                    ToolTip = 'Specifies the value of the Max. Quantity per Coupon field';
                    ApplicationArea = NPRRetail;
                }
                field("Validation Quantity"; Rec."Validation Quantity")
                {

                    Visible = (LotValidation);
                    ToolTip = 'Specifies the value of the Validation Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Add Items")
            {
                Caption = 'Add Items';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Add Items action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    //-NPR5.36 [291016]
                    AddItems();
                    //+NPR5.36 [291016]
                end;
            }
            action("Set Priority")
            {
                Caption = 'Set Priorities';
                Image = SetPriorities;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Set Priorities action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    //-NPR5.36 [291016]
                    SetPriority();
                    //+NPR5.36 [291016]
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.45 [312991]
        GetTotals();
        //+NPR5.45 [312991]
    end;

    var
        Text000: Label 'Add Items';
        MaxDiscountAmt: Decimal;
        MaxQty: Decimal;
        ValidQty: Integer;
        LotValidation: Boolean;
        ValidationView: Boolean;

    local procedure AddItems()
    var
        Item: Record Item;
        NpDcRequestPriority: Report "NPR NpDc Request Priority";
        NewPriority: Integer;
    begin
        //-NPR5.36 [291016]
        if not RunDynamicRequestPage(Item) then
            exit;
        if not NpDcRequestPriority.RequestPriority(NewPriority) then
            exit;

        InsertItems(Item, NewPriority);
        CurrPage.Update(false);
        //+NPR5.36 [291016]
    end;

    local procedure InsertItems(var Item: Record Item; NewPriority: Integer)
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
        LineNo: Integer;
    begin
        //-NPR5.36 [291016]
        CouponType := Rec.GetRangeMax("Coupon Type");
        if CouponType = '' then
            exit;

        NpDcCouponListItem.SetRange("Coupon Type", CouponType);
        if NpDcCouponListItem.FindLast() then;
        LineNo := NpDcCouponListItem."Line No.";

        Item.FindSet();
        repeat
            NpDcCouponListItem.SetRange("Coupon Type", CouponType);
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::Item);
            NpDcCouponListItem.SetRange("No.", Item."No.");
            if NpDcCouponListItem.IsEmpty then begin
                LineNo += 10000;
                NpDcCouponListItem.Init();
                NpDcCouponListItem."Coupon Type" := CouponType;
                NpDcCouponListItem."Line No." := LineNo;
                NpDcCouponListItem.Type := NpDcCouponListItem.Type::Item;
                NpDcCouponListItem.Validate("No.", Item."No.");
                NpDcCouponListItem.Priority := NewPriority;
                NpDcCouponListItem.Insert(true);
            end;
        until Item.Next() = 0;
        //+NPR5.36 [291016]
    end;

    local procedure RunDynamicRequestPage(var Item: Record Item): Boolean
    var
        RecRef: RecordRef;
        TableMetadata: Record "Table Metadata";
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        OutStream: OutStream;
        ReturnFilters: Text;
        EntityID: Code[20];
    begin
        //-NPR5.36 [291016]
        Clear(Item);
        RecRef.GetTable(Item);
        TableMetadata.Get(RecRef.Number);
        EntityID := CopyStr(Text000, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);

        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Vendor No."));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Category Code"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Item Disc. Group"));
        FilterPageBuilder.AddFieldNo(TableMetadata.Name, Item.FieldNo("Search Description"));
        FilterPageBuilder.PageCaption := Text000;
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset();
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit(false);
        end;

        RecRef.SetTable(Item);
        exit(Item.FindFirst());
        //+NPR5.36 [291016]
    end;

    local procedure SetPriority()
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        NpDcRequestPriority: Report "NPR NpDc Request Priority";
        NewPriority: Integer;
    begin
        //-NPR5.36 [291016]
        if not NpDcRequestPriority.RequestPriority(NewPriority) then
            exit;

        CurrPage.SetSelectionFilter(NpDcCouponListItem);
        NpDcCouponListItem.SetFilter(Priority, '<>%1', NewPriority);
        if not NpDcCouponListItem.FindSet() then
            exit;

        repeat
            NpDcCouponListItem.Priority := NewPriority;
            NpDcCouponListItem.Modify(true);
        until NpDcCouponListItem.Next() = 0;

        CurrPage.Update(false);
        //+NPR5.36 [291016]
    end;

    local procedure SetTotals()
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
        PrevRec: Text;
    begin
        //-NPR5.45 [312991]
        CouponType := Rec."Coupon Type";
        if CouponType = '' then begin
            Rec.FilterGroup(2);
            CouponType := Rec.GetRangeMax("Coupon Type");
            Rec.FilterGroup(0);
        end;

        //-NPR5.46 [327366]
        //IF MaxQty <= 0 THEN BEGIN
        if (MaxQty <= 0) and (ValidQty <= 0) and (not LotValidation) then begin
            //+NPR5.46 [327366]
            if NpDcCouponListItem.Get(CouponType, -1) then
                NpDcCouponListItem.Delete(true);

            CurrPage.Update(false);
            exit;
        end;

        if not NpDcCouponListItem.Get(CouponType, -1) then begin
            NpDcCouponListItem.Init();
            NpDcCouponListItem."Coupon Type" := CouponType;
            NpDcCouponListItem."Line No." := -1;
            NpDcCouponListItem."Max. Discount Amount" := MaxDiscountAmt;
            NpDcCouponListItem."Max. Quantity" := MaxQty;
            //-NPR5.46 [327366]
            NpDcCouponListItem."Validation Quantity" := ValidQty;
            NpDcCouponListItem."Lot Validation" := LotValidation;
            //+NPR5.46 [327366]
            NpDcCouponListItem.Insert(true);
        end;

        PrevRec := Format(NpDcCouponListItem);

        NpDcCouponListItem."Max. Quantity" := MaxQty;
        //-NPR5.46 [327366]
        NpDcCouponListItem."Validation Quantity" := ValidQty;
        NpDcCouponListItem."Lot Validation" := LotValidation;
        //+NPR5.46 [327366]

        if PrevRec <> Format(NpDcCouponListItem) then
            NpDcCouponListItem.Modify(true);

        CurrPage.Update(false);
        //+NPR5.45 [312991]
    end;

    local procedure GetTotals()
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
    begin
        //-NPR5.45 [312991]
        CouponType := Rec."Coupon Type";
        if CouponType = '' then begin
            Rec.FilterGroup(2);
            CouponType := Rec.GetRangeMax("Coupon Type");
            Rec.FilterGroup(0);
        end;
        MaxDiscountAmt := 0;
        MaxQty := 0;
        //-NPR5.46 [327366]
        ValidQty := 0;
        LotValidation := false;
        //+NPR5.46 [327366]

        //-NPR5.46 [327366]
        //IF NpDcCouponListItem.GET(CouponType,-1) THEN
        //  MaxQty := NpDcCouponListItem."Max. Quantity";
        if not NpDcCouponListItem.Get(CouponType, -1) then
            exit;

        MaxQty := NpDcCouponListItem."Max. Quantity";
        ValidQty := NpDcCouponListItem."Validation Quantity";
        LotValidation := NpDcCouponListItem."Lot Validation";
        //+NPR5.46 [327366]
        //+NPR5.45 [312991]
    end;

    procedure SetValidationView(NewValidationView: Boolean)
    begin
        //-NPR5.46 [327366]
        ValidationView := NewValidationView;
        //+NPR5.46 [327366]
    end;
}

