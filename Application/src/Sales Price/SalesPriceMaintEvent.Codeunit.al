codeunit 6014481 "NPR Sales Price Maint. Event"
{
    trigger OnRun()
    begin
        EventTest();
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure ItemOnAfterModifyEvent(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if (Rec."Unit Cost" = xRec."Unit Cost") and
           (Rec."Last Direct Cost" = xRec."Last Direct Cost") and
           (Rec."Unit Price" = xRec."Unit Price") and
           (Rec."Standard Cost" = xRec."Standard Cost") and
           (Rec."Item Category Code" = xRec."Item Category Code") then
            exit;
        UpdateSalesPricesForStaff(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Last Direct Cost', true, true)]
    local procedure OnAfterValidateLastDirectCostEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    begin
        UpdateSalesPricesForStaff(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Price/Profit Calculation', true, true)]
    local procedure OnAfterValidatePriceProfitCalcEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    begin
        UpdateSalesPricesForStaff(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Price', true, true)]
    local procedure OnAfterValidateUnitPriceEvent(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    begin
        UpdateSalesPricesForStaff(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterPostItemJnlLine', '', true, true)]
    local procedure OnAfterPostItemJournalLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if Item.Get(ItemJournalLine."Item No.") then
            UpdateSalesPricesForStaff(Item);
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

    local procedure EventTest()
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", '0000050536191');
        if Item.FindSet() then
            repeat
                if Item."No." <> '' then
                    if Item.Modify(true) then;
            until Item.Next() = 0;
    end;

    procedure UpdateSalesPricesForStaff(var Item: Record Item)
    var
        SalesPriceMaintenanceSetup: Record "NPR Sales Price Maint. Setup";
        PriceListLine: Record "Price List Line";
        PriceListHeader: Record "Price List Header";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerPriceGroup: Record "Customer Price Group";
        VATPct: Decimal;
        VATBusPostingGrp: Code[20];
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyFactor: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchRateDate: Date;
        UnitPrice: Decimal;
        PricesInCurrency: Boolean;
        RecRef: RecordRef;
        BreakLoop: Boolean;
        SalesPriceMaintenanceGroups: Record "NPR Sales Price Maint. Groups2";
        TmpItem: Record Item;
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
    begin
        RecRef.GetTable(Item);
        if RecRef.IsTemporary then
            exit;

        if not TmpItem.Get(Item."No.") then
            exit;

        if SalesPriceMaintenanceSetup.FindFirst() then begin

            ExchRateDate := Today();
            GeneralLedgerSetup.Get();

            repeat
                SalesPriceMaintenanceSetup.CalcFields("Exclude Item Groups");
                BreakLoop := SalesPriceMaintenanceSetup."Exclude All Item Groups";
                if not BreakLoop then begin
                    if Item."Item Category Code" <> '' then
                        if SalesPriceMaintenanceSetup."Exclude Item Groups" > 0 then begin
                            Clear(SalesPriceMaintenanceGroups);
                            SalesPriceMaintenanceGroups.SetRange(Id, SalesPriceMaintenanceSetup.Id);
                            if SalesPriceMaintenanceGroups.FindSet() then begin
                                repeat
                                    if not BreakLoop then
                                        BreakLoop := ExcludeItemGroup(Item."Item Category Code", SalesPriceMaintenanceGroups."Item Category Code");
                                until SalesPriceMaintenanceGroups.Next() = 0;
                            end;
                        end;
                end;

                if not BreakLoop then begin
                    VATPct := 0;
                    VATBusPostingGrp := '';
                    PricesInCurrency := false;

                    Clear(PriceListLine);
                    PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                    PriceListLine.SetRange("Asset No.", Item."No.");
                    PriceListLine.SetRange("Source Type", GetSourceType(SalesPriceMaintenanceSetup."Sales Type"));
                    PriceListLine.SetRange("Source No.", SalesPriceMaintenanceSetup."Sales Code");
                    PriceListLine.SetRange("Currency Code", SalesPriceMaintenanceSetup."Currency Code");
                    PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);

                    if not PriceListLine.FindFirst() then begin
                        Clear(PriceListLine);
                        if not PriceListHeader.Get(SalesPriceMaintenanceSetup."Sales Code") then
                            CreatePriceListHeader(SalesPriceMaintenanceSetup."Sales Code");
                        PriceListLine.Init();
                        PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
                        PriceListLine.Validate("Asset No.", Item."No.");
                        PriceListLine.Validate("Source Type", GetSourceType(SalesPriceMaintenanceSetup."Sales Type"));
                        PriceListLine.Validate("Source No.", SalesPriceMaintenanceSetup."Sales Code");
                        PriceListLine.Validate("Currency Code", SalesPriceMaintenanceSetup."Currency Code");
                        PriceListLine.Validate("Price Type", PriceListLine."Price Type"::Sale);
                        PriceListLine.Validate("Amount Type", PriceListLine."Amount Type"::Price);
                        PriceListLine.Validate(Status, PriceListLine.Status::Active);
                        PriceListLine.Insert(true);
                    end;

                    case SalesPriceMaintenanceSetup."Sales Type" of
                        SalesPriceMaintenanceSetup."Sales Type"::"All Customers":
                            begin
                                if VATPostingSetup.Get(SalesPriceMaintenanceSetup."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                                    POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                                    VATPct := VATPostingSetup."VAT %";
                                    VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                                end;
                            end;
                        SalesPriceMaintenanceSetup."Sales Type"::Campaign:
                            begin
                                //Do we need this??
                            end;
                        SalesPriceMaintenanceSetup."Sales Type"::Customer:
                            begin
                                Customer.Get(SalesPriceMaintenanceSetup."Sales Code");
                                if Customer."VAT Bus. Posting Group" <> '' then
                                    if VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then begin
                                        POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                                        VATPct := VATPostingSetup."VAT %";
                                        VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                                    end;
                            end;
                        SalesPriceMaintenanceSetup."Sales Type"::"Customer Price Group":
                            begin
                                CustomerPriceGroup.Get(SalesPriceMaintenanceSetup."Sales Code");
                                if CustomerPriceGroup."Price Includes VAT" and (CustomerPriceGroup."VAT Bus. Posting Gr. (Price)" <> '') then
                                    if VATPostingSetup.Get(CustomerPriceGroup."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                                        POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                                        VATPct := VATPostingSetup."VAT %";
                                        VATBusPostingGrp := VATPostingSetup."VAT Bus. Posting Group";
                                    end;
                            end;
                    end;

                    if SalesPriceMaintenanceSetup.Factor = 0 then
                        SalesPriceMaintenanceSetup.Factor := 1;

                    if (SalesPriceMaintenanceSetup."Currency Code" <> '') and (SalesPriceMaintenanceSetup."Currency Code" <> GeneralLedgerSetup."LCY Code") then begin
                        if Currency.Get(SalesPriceMaintenanceSetup."Currency Code") then begin
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
                                if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                                    UnitPrice := Item."Unit Cost" * SalesPriceMaintenanceSetup.Factor
                                else
                                    UnitPrice := (Item."Unit Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                            end;
                        SalesPriceMaintenanceSetup."Internal Unit Price"::"Last Direct Cost":
                            begin
                                if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                                    UnitPrice := Item."Last Direct Cost" * SalesPriceMaintenanceSetup.Factor
                                else
                                    UnitPrice := (Item."Last Direct Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                            end;
                        SalesPriceMaintenanceSetup."Internal Unit Price"::"Standard Cost":
                            begin
                                if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                                    UnitPrice := Item."Standard Cost" * SalesPriceMaintenanceSetup.Factor
                                else
                                    UnitPrice := (Item."Standard Cost" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                            end;
                        SalesPriceMaintenanceSetup."Internal Unit Price"::"Unit Price":
                            begin
                                if not SalesPriceMaintenanceSetup."Prices Including VAT" then
                                    UnitPrice := Item."Unit Price" * SalesPriceMaintenanceSetup.Factor
                                else
                                    UnitPrice := (Item."Unit Price" * (1 + (VATPct / 100))) * SalesPriceMaintenanceSetup.Factor;
                            end;
                    end;

                    ConvertPriceLCYToFCY(PricesInCurrency, ExchRateDate, Currency, UnitPrice, CurrencyFactor);
                    PriceListLine.Status := PriceListLine.Status::Draft;
                    PriceListLine.Validate("Unit Price", UnitPrice);

                    PriceListLine.Validate("Price Includes VAT", SalesPriceMaintenanceSetup."Prices Including VAT");
                    PriceListLine.Validate("Allow Invoice Disc.", SalesPriceMaintenanceSetup."Allow Invoice Disc.");
                    PriceListLine.Validate("Allow Line Disc.", SalesPriceMaintenanceSetup."Allow Line Disc.");
                    PriceListLine.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGrp);
                    PriceListLine.Status := PriceListLine.Status::Active;
                    PriceListLine.Modify(true)
                end;
            until SalesPriceMaintenanceSetup.Next() = 0;
        end;
    end;

    local procedure ExcludeItemGroup(Current_ItemGroup: Code[20]; ItemCategory_To_Exclude: Code[20]): Boolean
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

    local procedure CreatePriceListHeader(WorksheetTemplateName: Code[10])
    var
        PriceListHeader: Record "Price List Header";
    begin
        PriceListHeader.Init();
        PriceListHeader.Code := WorksheetTemplateName;
        PriceListHeader.Insert(true);
        PriceListHeader.Validate("Source Group", PriceListHeader."Source Group"::All);
        PriceListHeader.Validate(Status, PriceListHeader.Status::Active);
        PriceListHeader.Modify(true);
    end;
}

