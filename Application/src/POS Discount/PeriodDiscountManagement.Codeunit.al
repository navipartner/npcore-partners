﻿codeunit 6014415 "NPR Period Discount Management"
{
    Access = Internal;
    trigger OnRun()
    begin
    end;

    var
        TempCustDiscGroup: Record "Customer Discount Group" temporary;

    procedure ApplyPeriodDiscounts(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete; RecalculateAllLines: Boolean)
    begin
        Clear(TempSaleLinePOS);
        if RecalculateAllLines then begin
            TempSaleLinePOS.SetRange("Register No.", Rec."Register No.");
            TempSaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            TempSaleLinePOS.SetRange(Date, Rec.Date);
            TempSaleLinePOS.SetFilter("Discount Type", '=%1|=%2', TempSaleLinePOS."Discount Type"::" ", TempSaleLinePOS."Discount Type"::Customer);
            if TempSaleLinePOS.FindSet() then
                repeat
                    ApplyDiscountOnLine(TempSaleLinePOS, SalePOS);
                until TempSaleLinePOS.Next() = 0;
        end else
            if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
                ApplyDiscountOnLine(TempSaleLinePOS, SalePOS);
    end;

    local procedure ApplyDiscountOnLine(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; TempSalePOS: Record "NPR POS Sale" temporary)
    var
        TempSaleLinePOS2: Record "NPR POS Sale Line" temporary;
    begin
        if not TempSaleLinePOS."Allow Line Discount" then
            exit;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " then begin
            ApplyPeriodDiscountOnLine(TempSaleLinePOS, TempSalePOS);
            TempSaleLinePOS.Modify();
        end;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Customer then begin
            TempSaleLinePOS2.Copy(TempSaleLinePOS, true);
            ApplyPeriodDiscountOnLine(TempSaleLinePOS2, TempSalePOS);

            if TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" then
                exit;
            TempSaleLinePOS2.Modify();
        end;
    end;

    procedure ApplyPeriodDiscountOnLine(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; TempSalePOS: Record "NPR POS Sale" temporary)
    var
        Customer: Record Customer;
        Item: Record Item;
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetup2: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Price: Decimal;
        UnitPrice: Decimal;
        BestCode: Code[20];
        BestVariant: Code[10];
        Handled: Boolean;
    begin
        //SetPeriodeRabat()
        if TempSaleLinePOS."No." = '' then
            exit;
        Item.Get(TempSaleLinePOS."No.");
        PeriodDiscountLine.Reset();
        PeriodDiscountLine.SetCurrentKey("Item No.");
        PeriodDiscountLine.SetRange(Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter("Starting Date", '<=%1', Today);
        PeriodDiscountLine.SetFilter("Ending Date", '>=%1', Today);
        PeriodDiscountLine.SetRange("Item No.", TempSaleLinePOS."No.");
        PeriodDiscountLine.SetFilter("Variant Code", '=%1|=%2', TempSaleLinePOS."Variant Code", '');
        if not PeriodDiscountLine.FindFirst() then
            exit;

        TempSaleLinePOS.SetPOSHeader(TempSalePOS);

        UnitPrice := TempSaleLinePOS.FindItemSalesPrice();
        TempSaleLinePOS."Discount Amount" := 0;
        TempSaleLinePOS."Discount %" := 0;
        Price := 999999999999.99;

        if PeriodDiscountLine.FindSet() then
            repeat
                if PeriodDiscountLineIsValid(PeriodDiscountLine, TempSaleLinePOS, TempSalePOS) then begin
                    if PeriodDiscountLine."Campaign Unit Price" < Price then begin
                        Price := PeriodDiscountLine."Campaign Unit Price";
                        BestCode := PeriodDiscountLine.Code;
                        BestVariant := PeriodDiscountLine."Variant Code";
                    end;
                end;
            until PeriodDiscountLine.Next() = 0;

        if PeriodDiscountLine.Get(BestCode, TempSaleLinePOS."No.", BestVariant) then begin
            PeriodDiscountLine.CalcFields("Unit Price Incl. VAT");
            if Customer.Get(TempSalePOS."Customer No.") and PeriodDiscountLine."Unit Price Incl. VAT" then begin
                if VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                    POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                if VATPostingSetup2.Get(Customer."VAT Bus. Posting Group", TempSaleLinePOS."VAT Prod. Posting Group") then
                    POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup2, Handled);
                PeriodDiscountLine."Campaign Unit Price" :=
                    PeriodDiscountLine."Campaign Unit Price" / (100 + VATPostingSetup."VAT %") * (100 + VATPostingSetup2."VAT %");
            end;

            if TempSaleLinePOS."Price Includes VAT" then begin
                if not PeriodDiscountLine."Unit Price Incl. VAT" then
                    PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" * (100 + TempSaleLinePOS."VAT %") / 100;
            end else begin
                if PeriodDiscountLine."Unit Price Incl. VAT" then
                    PeriodDiscountLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price" / (100 + TempSaleLinePOS."VAT %") * 100;
            end;
            if PeriodDiscountLine."Campaign Unit Price" <= UnitPrice then begin
                if UnitPrice <> 0 then
                    TempSaleLinePOS."Discount %" := 100 - PeriodDiscountLine."Campaign Unit Price" / UnitPrice * 100
                else
                    TempSaleLinePOS."Discount %" := 0;
                TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::Campaign;
                TempSaleLinePOS."Discount Code" := PeriodDiscountLine.Code;
                PeriodDiscount.Get(PeriodDiscountLine.Code);
                if Item."NPR Custom Discount Blocked" then
                    TempSaleLinePOS."Custom Disc Blocked" := Item."NPR Custom Discount Blocked"
                else
                    TempSaleLinePOS."Custom Disc Blocked" := PeriodDiscount."Block Custom Disc.";
            end;

            //Apply unit cost for the period if specified
            if PeriodDiscountLine."Campaign Unit Cost" <> 0 then
                TempSaleLinePOS."Unit Cost" := PeriodDiscountLine."Campaign Unit Cost";
        end;

        TempSaleLinePOS."Discount Calculated" := true;
    end;

    procedure "-- Aux"()
    begin
    end;

    procedure PeriodDiscountLineIsValid(var PeriodDiscountLine: Record "NPR Period Discount Line"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; SalePOS: Record "NPR POS Sale"): Boolean
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if not PeriodDiscount.Get(PeriodDiscountLine.Code) then
            exit(false);

        if not IsValidDay(PeriodDiscount, Today) then
            exit(false);

        if not IsValidTime(PeriodDiscount, Time) then
            exit(false);

        if not IsValidCustDiscGroup(PeriodDiscount, SalePOS) then
            exit(false);

        exit(true);
    end;

    local procedure IsValidCustDiscGroup(PeriodDiscount: Record "NPR Period Discount"; SalePOS: Record "NPR POS Sale"): Boolean
    begin
        if PeriodDiscount."Customer Disc. Group Filter" = '' then
            exit(true);

        GenerateTmpCustDiscGroupList();
        TempCustDiscGroup.SetFilter(Code, PeriodDiscount."Customer Disc. Group Filter");
        TempCustDiscGroup.Code := SalePOS."Customer Disc. Group";
        exit(TempCustDiscGroup.Find());
    end;

    local procedure IsValidDay(PeriodDiscount: Record "NPR Period Discount"; CheckDate: Date): Boolean
    begin
        case PeriodDiscount."Period Type" of
            PeriodDiscount."Period Type"::"Every Day":
                begin
                    exit(true);
                end;
            PeriodDiscount."Period Type"::Weekly:
                begin
                    case Date2DWY(CheckDate, 1) of
                        1:
                            exit(PeriodDiscount.Monday);
                        2:
                            exit(PeriodDiscount.Tuesday);
                        3:
                            exit(PeriodDiscount.Wednesday);
                        4:
                            exit(PeriodDiscount.Thursday);
                        5:
                            exit(PeriodDiscount.Friday);
                        6:
                            exit(PeriodDiscount.Saturday);
                        7:
                            exit(PeriodDiscount.Sunday);
                    end;
                end;
            else
                exit(false);
        end;
    end;

    local procedure IsValidTime(PeriodDiscount: Record "NPR Period Discount"; CheckTime: Time): Boolean
    begin
        if (PeriodDiscount."Starting Time" <> 0T) and (PeriodDiscount."Starting Time" > CheckTime) then
            exit(false);

        if (PeriodDiscount."Ending Time" <> 0T) and (PeriodDiscount."Ending Time" < CheckTime) then
            exit(false);

        exit(true);
    end;

    procedure GetOrInit(var DiscountPriority: Record "NPR Discount Priority")
    begin
        if DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        DiscountPriority.Init();
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 3;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority.Insert(true);
    end;

    procedure GetNoSeries(): Code[20]
    var
        DiscountPriority: Record "NPR Discount Priority";
        NoSeriesCodeTok: Label 'PER-DISC', Locked = true;
        NoSeriesDescriptionTok: Label 'Period Discount No. Series';
    begin
        GetOrInit(DiscountPriority);
        if DiscountPriority."Discount No. Series" = '' then // if not initialized via upgrade codeunit
            DiscountPriority.CreateNoSeries(NoSeriesCodeTok, NoSeriesDescriptionTok, false);

        exit(DiscountPriority."Discount No. Series");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
        GetOrInit(DiscountPriority);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete; RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        ApplyPeriodDiscounts(SalePOS, TempSaleLinePOS, Rec, xRec, LineOperation, RecalculateAllLines);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete)
    var
        DiscountPriority: Record "NPR Discount Priority";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;
        if not IsValidLineOperation(LineOperation) then
            exit;

        PeriodDiscountLine.SetCurrentKey("Item No.", "Variant Code", "Starting Date", "Ending Date", Status);
        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
        PeriodDiscountLine.SetFilter("Variant Code", '%1|%2', '', Rec."Variant Code");
        PeriodDiscountLine.SetRange(Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
        PeriodDiscountLine.SetFilter("Ending Date", '>=%1|=%2', Today, 0D);
        if not PeriodDiscountLine.IsEmpty then begin
            tmpDiscountPriority.Init();
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert();
        end;
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "NPR Discount Priority"): Boolean
    begin
        if DiscountPriority.Disabled then
            exit(false);
        if DiscountPriority."Table ID" <> DiscSourceTableId() then
            exit(false);
        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId()) then
            exit(false);

        exit(true);
    end;

    local procedure IsValidLineOperation(LineOperation: Option Insert,Modify,Delete): Boolean
    begin
        if LineOperation = LineOperation::Delete then
            exit(false);
        exit(true);
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Period Discount");
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Period Discount Management");
    end;

    local procedure GenerateTmpCustDiscGroupList()
    var
        CustDiscGroup: Record "Customer Discount Group";
    begin
        TempCustDiscGroup.Reset();
        if not TempCustDiscGroup.IsEmpty then
            exit;

        if CustDiscGroup.FindSet() then
            repeat
                TempCustDiscGroup := CustDiscGroup;
                TempCustDiscGroup.Insert();
            until CustDiscGroup.Next() = 0;

        TempCustDiscGroup.Init();
        TempCustDiscGroup.Code := '';
        if not TempCustDiscGroup.Find() then
            TempCustDiscGroup.Insert();
    end;

    #region AddPeriodDiscountLinesFromPriceList
    procedure AddLinesBasedOnSalesPriceList(PeriodDiscount: Record "NPR Period Discount")
    var
        PriceListHeader: Record "Price List Header";
    begin
        PeriodDiscount.TestField(Status, PeriodDiscount.Status::Await);

        SelectPriceListHeader(PriceListHeader);
        AddPeriodDiscountLinesFromPriceList(PeriodDiscount, PriceListHeader);
    end;

    local procedure SelectPriceListHeader(var PriceListHeader: Record "Price List Header")
    var
        SalesPriceLists: Page "Sales Price Lists";
    begin
        PriceListHeader.Reset();
        PriceListHeader.SetFilter("Source Group", '%1|%2', PriceListHeader."Source Group"::All, PriceListHeader."Source Group"::Customer);
        PriceListHeader.SetRange("Source Type", PriceListHeader."Source Type"::"Customer Price Group");

        if PriceListHeader.Count = 1 then begin
            PriceListHeader.FindFirst();
            exit;
        end;

        SalesPriceLists.SetTableView(PriceListHeader);
        SalesPriceLists.LookupMode(true);
        SalesPriceLists.Editable(false);
        if SalesPriceLists.RunModal() <> Action::LookupOK then
            Error('');

        SalesPriceLists.GetRecord(PriceListHeader);
    end;

    local procedure AddPeriodDiscountLinesFromPriceList(PeriodDiscount: Record "NPR Period Discount"; PriceListHeader: Record "Price List Header")
    var
        PriceListLine: Record "Price List Line";
        LinesAddedCount: Integer;
        SuccessfullyAddedLinesLbl: Label 'Successfully added %1 lines.', Comment = '%1-line count';
    begin
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetFilter("Asset Type", '%1|%2', PriceListLine."Asset Type"::Item, PriceListLine."Asset Type"::"Item Discount Group");
        PriceListLine.SetFilter("Asset No.", '<>%1', '');
        if PriceListLine.FindSet() then
            repeat
                case PriceListLine."Asset Type" of
                    PriceListLine."Asset Type"::Item:
                        if CreatePeriodDiscountLine(PeriodDiscount.Code, PriceListLine."Asset No.", PriceListLine."Variant Code") then
                            LinesAddedCount += 1;
                    PriceListLine."Asset Type"::"Item Discount Group":
                        CreatePeriodDiscountLinesBasedOnItemDiscGroup(PeriodDiscount.Code, PriceListLine, LinesAddedCount);
                end;
            until PriceListLine.Next() = 0;

        Message(SuccessfullyAddedLinesLbl, LinesAddedCount);
    end;

    local procedure CreatePeriodDiscountLinesBasedOnItemDiscGroup(PeriodDiscountCode: Code[20]; PriceListLine: Record "Price List Line"; var LinesAddedCount: Integer)
    var
        Item: Record Item;
    begin
        PriceListLine.TestField("Asset Type", PriceListLine."Asset Type"::"Item Discount Group");
        PriceListLine.TestField("Asset No.");

        Item.SetLoadFields("No.");
        Item.SetRange("Item Disc. Group", PriceListLine."Asset No.");
        if Item.FindSet() then
            repeat
                if CreatePeriodDiscountLine(PeriodDiscountCode, Item."No.", '') then
                    LinesAddedCount += 1;
            until Item.Next() = 0;
    end;

    local procedure CreatePeriodDiscountLine(PeriodDiscountCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[20]): Boolean
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
        Item: Record Item;
    begin
        if CheckPeriodDiscountLineAlreadyExist(PeriodDiscountCode, ItemNo, VariantCode) then
            exit(false);

        if not Item.Get(ItemNo) then
            exit(false);

        if Item."Unit Price" = 0 then
            exit(false);

        PeriodDiscountLine.Init();
        PeriodDiscountLine.Validate(Code, PeriodDiscountCode);
        PeriodDiscountLine.Validate("Item No.", ItemNo);
        if VariantCode <> '' then
            PeriodDiscountLine.Validate("Variant Code", VariantCode);

        PeriodDiscountLine.TestField(Code);
        PeriodDiscountLine.TestField("Item No.");
        exit(PeriodDiscountLine.Insert(true));
    end;

    local procedure CheckPeriodDiscountLineAlreadyExist(PeriodDiscountCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[20]): Boolean
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        PeriodDiscountLine.SetRange(Code, PeriodDiscountCode);
        PeriodDiscountLine.SetRange("Item No.", ItemNo);
        PeriodDiscountLine.SetRange("Variant Code", VariantCode);
        exit(not PeriodDiscountLine.IsEmpty);
    end;
    #endregion
}
