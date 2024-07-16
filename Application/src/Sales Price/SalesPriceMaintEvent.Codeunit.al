﻿codeunit 6014481 "NPR Sales Price Maint. Event"
{
    Access = Internal;
    trigger OnRun()
    begin
        ProcessLogInBackground();
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, true)]
    local procedure ItemOnAfterModifyEvent(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        if not RunTrigger then
            exit;
        if (Rec."Unit Cost" = xRec."Unit Cost") and
           (Rec."Last Direct Cost" = xRec."Last Direct Cost") and
           (Rec."Unit Price" = xRec."Unit Price") and
           (Rec."Standard Cost" = xRec."Standard Cost") and
           (Rec."Item Category Code" = xRec."Item Category Code") then
            exit;
        UpdateSalesPricesForStaff(Rec, SalesPriceMaintSetup, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Last Direct Cost', true, true)]
    local procedure OnAfterValidateLastDirectCostEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        UpdateSalesPricesForStaff(Rec, SalesPriceMaintSetup, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Price/Profit Calculation', true, true)]
    local procedure OnAfterValidatePriceProfitCalcEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        UpdateSalesPricesForStaff(Rec, SalesPriceMaintSetup, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Unit Price', true, true)]
    local procedure OnAfterValidateUnitPriceEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        UpdateSalesPricesForStaff(Rec, SalesPriceMaintSetup, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', true, true)]
    local procedure OnAfterPostItemJournalLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        if Item.Get(ItemJournalLine."Item No.") then
            UpdateSalesPricesForStaff(Item, SalesPriceMaintSetup, false);
    end;

    local procedure ConvertPriceLCYToFCY(PricesInCurrency: Boolean; ExchRateDate: Date; Currency: Record Currency; var UnitPrice: Decimal; CurrencyFactor: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            UnitPrice := CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end;
    end;

    local procedure CreateLogEntry(Item: Record Item)
    var
        SalesPriceMaintLog: Record "NPR Sales Price Maint. Log";
    begin
        SalesPriceMaintLog.SetRange(Processed, false);
        SalesPriceMaintLog.SetRange("Item No.", Item."No.");
        if SalesPriceMaintLog.IsEmpty() then begin
            SalesPriceMaintLog."Entry No." := 0;
            SalesPriceMaintLog."Item No." := Item."No.";
            SalesPriceMaintLog.Insert();
        end;
    end;

    internal procedure UpdateSalesPricesForStaff(var Item: Record Item; var SalesPriceMaintenanceSetup: Record "NPR Sales Price Maint. Setup"; FromBackGroundProcessing: Boolean)
    var
        PriceListLine: Record "Price List Line";
        PriceListHeader: Record "Price List Header";
        xPriceListHeader: Record "Price List Header";
        VATPostingSetup: Record "VAT Posting Setup";
        VATPct: Decimal;
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchRateDate: Date;
        UnitPrice: Decimal;
        PricesInCurrency: Boolean;
        RecRef: RecordRef;
        BreakLoop: Boolean;
        TmpItem: Record Item;
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
        SalesPriceMaintMgt: Codeunit "NPR Sales Price Maint. Mgt.";
        HandledUpdateSalesPrices: Boolean;
    begin
        SalesPriceMaintMgt.OnBeforeUpdateSalesPricesForStaff(Item, HandledUpdateSalesPrices);
        if HandledUpdateSalesPrices then
            exit;

        RecRef.GetTable(Item);
        if RecRef.IsTemporary then
            exit;

        if not FromBackGroundProcessing then
            if not TmpItem.Get(Item."No.") then
                exit;

        SalesPriceMaintenanceSetup.SetAutoCalcFields("Exclude Item Groups");
        if SalesPriceMaintenanceSetup.FindSet() then begin
            ExchRateDate := Today();
            GeneralLedgerSetup.Get();
            repeat
                BreakLoop := SalesPriceMaintenanceSetup."Exclude All Item Groups";
                if not BreakLoop then
                    if Item."Item Category Code" <> '' then
                        if SalesPriceMaintenanceSetup."Exclude Item Groups" > 0 then
                            BreakLoop := SalesPriceMaintMgt.CheckExcludeItemGroup(SalesPriceMaintenanceSetup.Id, Item."Item Category Code");

                if not BreakLoop then
                    if (not SalesPriceMaintenanceSetup."Background Processing") or FromBackGroundProcessing then begin
                        VATPct := 0;
                        PricesInCurrency := false;

                        GetPriceListHeader(SalesPriceMaintenanceSetup, PriceListHeader);

                        if VATPostingSetup.Get(PriceListHeader."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                            POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                            VATPct := VATPostingSetup."VAT %";
                        end;

                        if SalesPriceMaintenanceSetup.Factor = 0 then
                            SalesPriceMaintenanceSetup.Factor := 1;

                        if (PriceListHeader."Currency Code" <> '') and (PriceListHeader."Currency Code" <> GeneralLedgerSetup."LCY Code") then begin
                            if Currency.Get(PriceListHeader."Currency Code") then begin
                                Currency.SetRecFilter();
                                CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ExchRateDate, Currency.Code);
                                PricesInCurrency := true;
                            end else begin
                                CurrencyFactor := 1
                            end;
                        end else begin
                            CurrencyFactor := 1
                        end;

                        case SalesPriceMaintenanceSetup."Internal Unit Price" of
                            SalesPriceMaintenanceSetup."Internal Unit Price"::"Unit Cost":
                                begin
                                    if not PriceListHeader."Price Includes VAT" then
                                        UnitPrice := Item."Unit Cost" * SalesPriceMaintenanceSetup.Factor
                                    else
                                        UnitPrice := (Item."Unit Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                                end;
                            SalesPriceMaintenanceSetup."Internal Unit Price"::"Last Direct Cost":
                                begin
                                    if not PriceListHeader."Price Includes VAT" then
                                        UnitPrice := Item."Last Direct Cost" * SalesPriceMaintenanceSetup.Factor
                                    else
                                        UnitPrice := (Item."Last Direct Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                                end;
                            SalesPriceMaintenanceSetup."Internal Unit Price"::"Standard Cost":
                                begin
                                    if not PriceListHeader."Price Includes VAT" then
                                        UnitPrice := Item."Standard Cost" * SalesPriceMaintenanceSetup.Factor
                                    else
                                        UnitPrice := (Item."Standard Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                                end;
                            SalesPriceMaintenanceSetup."Internal Unit Price"::"Unit Price":
                                begin
                                    if not PriceListHeader."Price Includes VAT" then
                                        UnitPrice := Item."Unit Price" * SalesPriceMaintenanceSetup.Factor
                                    else
                                        UnitPrice := (Item."Unit Price" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                                end;
                        end;

                        Clear(PriceListLine);
                        PriceListLine.SetRange("Price List Code", PriceListHeader."Code");
                        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                        PriceListLine.SetRange("Asset No.", Item."No.");
                        PriceListLine.SetRange("Source Type", PriceListHeader."Source Type");
                        PriceListLine.SetRange("Source No.", PriceListHeader."Source No.");
                        PriceListLine.SetRange("Currency Code", PriceListHeader."Currency Code");
                        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                        PriceListLine.SetRange("Amount Type", PriceListLine."Amount Type"::Price);

                        if not PriceListLine.FindFirst() then begin
                            Clear(PriceListLine);
                            xPriceListHeader := PriceListHeader;
                            if PriceListHeader.Status <> PriceListHeader.Status::Draft then begin
                                PriceListHeader.Status := PriceListHeader.Status::Draft;
                                PriceListHeader.Modify();
                            end;

                            PriceListLine.Init();
                            PriceListLine."Price List Code" := PriceListHeader.Code;
                            PriceListLine.CopyFrom(PriceListHeader);
                            PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
                            PriceListLine.Validate("Asset No.", Item."No.");
                            PriceListLine.Validate("Price Type", PriceListLine."Price Type"::Sale);
                            PriceListLine.Validate("Amount Type", PriceListLine."Amount Type"::Price);
                            PriceListLine.Status := xPriceListHeader.Status;
                            PriceListLine.Insert(true);

                            if PriceListHeader.Status <> xPriceListHeader.Status then begin
                                PriceListHeader.Status := xPriceListHeader.Status;
                                PriceListHeader.Modify();
                            end;
                        end;

                        ConvertPriceLCYToFCY(PricesInCurrency, ExchRateDate, Currency, UnitPrice, CurrencyFactor);
                        PriceListLine."Unit Price" := UnitPrice;
                        if PriceListLine."Unit Price" <> 0 then
                            PriceListLine."Cost Factor" := 0;
                        PriceListLine.Modify();
                    end else
                        CreateLogEntry(Item);

            until SalesPriceMaintenanceSetup.Next() = 0;
        end;
    end;

    internal procedure ExcludeItemGroup(Current_ItemGroup: Code[20]; ItemCategory_To_Exclude: Code[20]): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Get(ItemCategory_To_Exclude);
        ItemCategory.Get(Current_ItemGroup);

        if ItemCategory."Parent Category" = '' then
            exit(false);

        if (ItemCategory."Parent Category" = ItemCategory_To_Exclude) or (ItemCategory."NPR Main Category Code" = ItemCategory_To_Exclude) then
            exit(true);

        if ExcludeItemGroup(ItemCategory."Parent Category", ItemCategory_To_Exclude) then
            exit(true);
    end;

    local procedure GetSourceType(SalesType: Option Customer,"Customer Price Group","All Customers",Campaign) SourceType: Enum "Price Source Type"
    begin
        case SalesType of
            SalesType::Customer:
                SourceType := SourceType::Customer;
            SalesType::"Customer Price Group":
                SourceType := SourceType::"Customer Price Group";
            SalesType::"All Customers":
                SourceType := SourceType::"All Customers";
            SalesType::Campaign:
                SourceType := SourceType::Campaign;
        end;
    end;

    local procedure GetPriceListHeader(var SalesPriceMaintenanceSetup: Record "NPR Sales Price Maint. Setup"; var PriceListHeader: Record "Price List Header")
    var
        CouldNotCreatePriceListHdrErr: Label 'System could not create a %1 for %2 = %3. Please manually create a %1 and assign it to the %2', Comment = '%1 = Price List Header tablecaption, %2 = Sales Price Maintenance Setup table caption, %3 = Sales Price Maintenance Setup Id';
    begin
        if SalesPriceMaintenanceSetup."Price List Code" <> '' then
            if PriceListHeader.get(SalesPriceMaintenanceSetup."Price List Code") then
                exit;

        if SalesPriceMaintenanceSetup."Price List Code" = '' then begin
            if SalesPriceMaintenanceSetup."Sales Code" <> '' then begin
                if not PriceListHeader.Get(SalesPriceMaintenanceSetup."Sales Code") then
                    SalesPriceMaintenanceSetup."Price List Code" := SalesPriceMaintenanceSetup."Sales Code";
            end;
            if SalesPriceMaintenanceSetup."Price List Code" = '' then begin
                if SalesPriceMaintenanceSetup.Id <= 0 then
                    SalesPriceMaintenanceSetup."Price List Code" := '001'
                else
                    SalesPriceMaintenanceSetup."Price List Code" := CopyStr(Format(SalesPriceMaintenanceSetup.Id), 1, MaxStrLen(SalesPriceMaintenanceSetup."Price List Code"));
                while PriceListHeader.Get(SalesPriceMaintenanceSetup."Price List Code") do begin
                    if StrLen(IncStr(SalesPriceMaintenanceSetup."Price List Code")) > MaxStrLen(SalesPriceMaintenanceSetup."Price List Code") then
                        Error(CouldNotCreatePriceListHdrErr, PriceListHeader.TableCaption, SalesPriceMaintenanceSetup.TableCaption, SalesPriceMaintenanceSetup.Id);
#pragma warning disable AA0139
                    SalesPriceMaintenanceSetup."Price List Code" := IncStr(SalesPriceMaintenanceSetup."Price List Code");
#pragma warning restore
                end;
            end;
        end;
        SalesPriceMaintenanceSetup.Modify();

        PriceListHeader.Init();
        PriceListHeader.Code := SalesPriceMaintenanceSetup."Price List Code";
        PriceListHeader.Insert(true);
        PriceListHeader."Source Group" := PriceListHeader."Source Group"::All;
        PriceListHeader.Validate("Source Type", GetSourceType(SalesPriceMaintenanceSetup."Sales Type"));
        PriceListHeader.Validate("Source No.", SalesPriceMaintenanceSetup."Sales Code");
        PriceListHeader."Currency Code" := SalesPriceMaintenanceSetup."Currency Code";
        PriceListHeader."Price Includes VAT" := SalesPriceMaintenanceSetup."Prices Including VAT";
        PriceListHeader."VAT Bus. Posting Gr. (Price)" := GetVatBusinessPostingGroupForPrices(SalesPriceMaintenanceSetup);
        PriceListHeader."Allow Invoice Disc." := SalesPriceMaintenanceSetup."Allow Invoice Disc.";
        PriceListHeader."Allow Line Disc." := SalesPriceMaintenanceSetup."Allow Line Disc.";
        PriceListHeader.Status := PriceListHeader.Status::Active;
        PriceListHeader.Modify(true);
    end;

    local procedure GetVatBusinessPostingGroupForPrices(SalesPriceMaintenanceSetup: Record "NPR Sales Price Maint. Setup"): Code[20]
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        case SalesPriceMaintenanceSetup."Sales Type" of
            SalesPriceMaintenanceSetup."Sales Type"::"All Customers":
                begin
                    exit(SalesPriceMaintenanceSetup."VAT Bus. Posting Gr. (Price)");
                end;
            SalesPriceMaintenanceSetup."Sales Type"::Customer:
                begin
                    SalesPriceMaintenanceSetup.TestField("Sales Code");
                    Customer.Get(SalesPriceMaintenanceSetup."Sales Code");
                    exit(Customer."VAT Bus. Posting Group");
                end;
            SalesPriceMaintenanceSetup."Sales Type"::"Customer Price Group":
                begin
                    SalesPriceMaintenanceSetup.TestField("Sales Code");
                    CustomerPriceGroup.Get(SalesPriceMaintenanceSetup."Sales Code");
                    exit(CustomerPriceGroup."VAT Bus. Posting Gr. (Price)");
                end;
        end;
    end;

    local procedure ProcessLogInBackground()
    var
        SalesPriceMaintLog: Record "NPR Sales Price Maint. Log";
        SalesPriceMaintLog2: Record "NPR Sales Price Maint. Log";
        Item: Record Item;
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        SelectLatestVersion();
        SalesPriceMaintLog.SetRange(Processed, false);
        if SalesPriceMaintLog.FindSet(true) then
            repeat
                SalesPriceMaintLog2 := SalesPriceMaintLog;
                if Item.Get(SalesPriceMaintLog."Item No.") then begin
                    UpdateSalesPricesForStaff(Item, SalesPriceMaintSetup, true);
                    SalesPriceMaintLog2.Processed := true;
                    SalesPriceMaintLog2.Modify();
                end else
                    SalesPriceMaintLog2.Delete();
            until SalesPriceMaintLog.Next() = 0;
    end;
}
