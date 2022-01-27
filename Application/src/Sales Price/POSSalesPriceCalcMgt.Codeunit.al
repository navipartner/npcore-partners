codeunit 6014453 "NPR POS Sales Price Calc. Mgt."
{
    Access = Internal;
    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        PricesInclVATCantBeCalcErr: Label 'Prices including VAT cannot be calculated when %1 is %2.', Comment = '%1=VATPostingSetup.FieldCaption("VAT Calculation Type");%2=VATPostingSetup."VAT Calculation Type")';
        Currency: Record Currency;
        TempSalesPriceListLine: Record "Price List Line" temporary;
        TempSalesPriceLineDisc: Record "Price List Line" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        AllowLineDisc: Boolean;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATCalcType: Enum "Tax Calculation Type";
        VATBusPostingGr: Code[20];
        QtyPerUOM: Decimal;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        FoundSalesPrice: Boolean;



    procedure InitTempPOSItemSale(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSalePOS: Record "NPR POS Sale" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
            exit;

        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
        POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);

        TempSalePOS.Date := Today();
        TempSalePOS."Prices Including VAT" := TempSaleLinePOS."Price Includes VAT";
        TempSaleLinePOS."VAT %" := VATPostingSetup."VAT %";
        TempSaleLinePOS."VAT Calculation Type" := TempSaleLinePOS."VAT Calculation Type"::"Normal VAT";
        TempSaleLinePOS."VAT Bus. Posting Group" := Item."VAT Bus. Posting Gr. (Price)";
    end;

    procedure FindItemPrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        POSPricingProfile: Record "NPR POS Pricing Profile";
        Handled: Boolean;
    begin
        if POSUnit.Get(SalePOS."Register No.") then;
        POSUnit.GetProfile(POSPricingProfile);

        if POSPricingProfile."Item Price Function" <> '' then begin
            OnFindItemPrice(POSPricingProfile, SalePOS, SaleLinePOS, Handled);
            if Handled then
                exit;
        end;

        FindSalesLinePrice(SalePOS, SaleLinePOS);

        OnAfterFindSalesLinePrice(SalePOS, SaleLinePOS);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindItemPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterFindSalesLinePrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Price Calc. Mgt.", 'OnFindItemPrice', '', true, true)]
    local procedure FindBestRetailPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    begin
        if POSPricingProfile."Item Price Codeunit ID" <> GetPublisherCodeunitId() then
            exit;
        if POSPricingProfile."Item Price Function" <> GetPublisherRetailFunction() then
            exit;

        Handled := true;
        FindSalesLinePrice(SalePOS, SaleLinePOS);

        OnAfterFindSalesLinePrice(SalePOS, SaleLinePOS);
    end;

    local procedure FindSalesLinePrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;

        SetCurrency(SaleLinePOS."Currency Code", GetCurrencyFactor(SaleLinePOS."Currency Code", SalePOS.Date), SalePOS.Date);

        SetVAT(SalePOS."Prices Including VAT", SaleLinePOS."VAT %", SaleLinePOS."VAT Calculation Type", SaleLinePOS."VAT Bus. Posting Group");

        SetUoM(Abs(SaleLinePOS.Quantity), SaleLinePOS."Qty. per Unit of Measure");

        SetLineDisc(SaleLinePOS."Discount %", SaleLinePOS."Allow Line Discount");

        Item.Get(SaleLinePOS."No.");

        if Item."NPR Group sale" or SaleLinePOS."Custom Price" then begin
            TempSalesPriceListLine.DeleteAll();
            TempSalesPriceListLine."Source Type" := TempSalesPriceListLine."Source Type"::"All Customers";
            TempSalesPriceListLine."Asset Type" := TempSalesPriceListLine."Asset Type"::Item;
            TempSalesPriceListLine."Asset No." := SaleLinePOS."No.";
            TempSalesPriceListLine."VAT Bus. Posting Gr. (Price)" := SaleLinePOS."VAT Bus. Posting Group";
            TempSalesPriceListLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            TempSalesPriceListLine."Currency Code" := SaleLinePOS."Currency Code";
            TempSalesPriceListLine."Unit Price" := SaleLinePOS."Unit Price";
            TempSalesPriceListLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
            TempSalesPriceListLine.Insert();
        end else
            SalesLinePriceExists(SalePOS, SaleLinePOS);

        CalcBestUnitPrice(TempSalesPriceListLine);

        if Item.Get(SaleLinePOS."No.") and Item."NPR Explode BOM auto" then
            SaleLinePOS."Unit Price" := 0
        else
            SaleLinePOS."Unit Price" := TempSalesPriceListLine."Unit Price";

        SaleLinePOS."Price Includes VAT" := SalePOS."Prices Including VAT";
        SaleLinePOS."Allow Line Discount" := TempSalesPriceListLine."Allow Line Disc.";
        if not SaleLinePOS."Allow Line Discount" then
            SaleLinePOS."Discount %" := 0;
    end;

    procedure FindSalesLineLineDisc(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS.Type <> SaleLinePOS.Type then
            exit;
        SetCurrency('', 0, 0D);
        SetUoM(Abs(SaleLinePOS.Quantity), 1);

        SalesLineLineDiscExists(SalePOS, SaleLinePOS, false);

        CalcBestLineDisc(TempSalesPriceLineDisc);

        SaleLinePOS."Discount %" := TempSalesPriceLineDisc."Line Discount %";
    end;

    local procedure SalesLinePriceExists(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        LineWithPrice: Interface "Line With Price";
        PriceCalculation: Interface "Price Calculation";
    begin
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;


        SalesLine.Init();
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        SalesLine."Variant Code" := SaleLinePOS."Variant Code";
        SalesLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        SalesLine."Posting Date" := SalePOS.Date;
        SalesHeader."Posting Date" := SalePOS.Date;
        SalesHeader."Currency Code" := Currency.Code;
        SalesHeader.UpdateCurrencyFactor();

        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            if Customer.Get(SalePOS."Customer No.") then begin
                SalesHeader."Bill-to Customer No." := Customer."No.";
                SalesHeader."Customer Price Group" := Customer."Customer Price Group";
                SalesLine."Customer Price Group" := Customer."Customer Price Group";
                SalesLine."Customer Disc. Group" := Customer."Customer Disc. Group";
            end;

        SalesLine.GetLineWithPrice(LineWithPrice);
        LineWithPrice.SetLine(TempSalesPriceListLine."Price Type"::Sale, SalesHeader, SalesLine);

        PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
        PriceCalculation.FindPrice(TempSalesPriceListLine, false);
        exit(TempSalesPriceListLine.FindFirst());
    end;

    procedure SalesLineLineDiscExists(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; ShowAll: Boolean): Boolean
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        LineWithPrice: Interface "Line With Price";
        PriceCalculation: Interface "Price Calculation";
    begin
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;


        SalesLine.Init();
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        SalesLine."Variant Code" := SaleLinePOS."Variant Code";
        SalesLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        SalesLine."Posting Date" := SalePOS.Date;
        SalesHeader."Posting Date" := SalePOS.Date;
        SalesHeader."Currency Code" := Currency.Code;
        SalesHeader.UpdateCurrencyFactor();
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            if Customer.Get(SalePOS."Customer No.") then begin
                SalesHeader."Bill-to Customer No." := Customer."No.";
                SalesHeader."Customer Price Group" := Customer."Customer Price Group";
                SalesLine."Customer Price Group" := Customer."Customer Price Group";
                SalesLine."Customer Disc. Group" := Customer."Customer Disc. Group";
            end;
        SalesLine.GetLineWithPrice(LineWithPrice);
        LineWithPrice.SetLine(TempSalesPriceLineDisc."Price Type"::Sale, SalesHeader, SalesLine);

        PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
        PriceCalculation.FindDiscount(TempSalesPriceLineDisc, false);
        exit(TempSalesPriceLineDisc.FindFirst());
    end;

    local procedure CalcBestUnitPrice(var PriceListLine: Record "Price List Line")
    var
        BestPriceListLine: Record "Price List Line";
        BestSalesPriceFound: Boolean;
    begin
        FoundSalesPrice := PriceListLine.FindSet();
        if FoundSalesPrice then
            repeat
                if IsInMinQty(PriceListLine."Unit of Measure Code", PriceListLine."Minimum Quantity") then begin
                    ConvertPriceToVAT(
                        PriceListLine."Price Includes VAT", Item."VAT Prod. Posting Group",
                        PriceListLine."VAT Bus. Posting Gr. (Price)", PriceListLine."Unit Price");
                    ConvertPriceToUoM(PriceListLine."Unit of Measure Code", PriceListLine."Unit Price");
                    ConvertPriceLCYToFCY(PriceListLine."Currency Code", PriceListLine."Unit Price");

                    if (BestPriceListLine."Unit Price" = 0) or
                                (CalcLineAmount(BestPriceListLine) > CalcLineAmount(PriceListLine))
                            then begin
                        BestPriceListLine := PriceListLine;
                        BestSalesPriceFound := true;
                    end;
                end;
            until PriceListLine.Next() = 0;

        // No price found in agreement
        if not BestSalesPriceFound then begin
            ConvertPriceToVAT(
              Item."Price Includes VAT", Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)", Item."Unit Price");
            ConvertPriceToUoM('', Item."Unit Price");
            ConvertPriceLCYToFCY('', Item."Unit Price");

            Clear(BestPriceListLine);
            BestPriceListLine."Unit Price" := Item."Unit Price";
            BestPriceListLine."Allow Line Disc." := AllowLineDisc;
        end;

        PriceListLine := BestPriceListLine;
    end;

    local procedure CalcBestLineDisc(var PriceListLine: Record "Price List Line")
    var
        BestPriceListLine: Record "Price List Line";
    begin
        if PriceListLine.FindSet() then
            repeat
                if IsInMinQty(PriceListLine."Unit of Measure Code", PriceListLine."Minimum Quantity") then
                    if BestPriceListLine."Line Discount %" < PriceListLine."Line Discount %" then
                        BestPriceListLine := PriceListLine;
            until PriceListLine.Next() = 0;

        PriceListLine := BestPriceListLine;
    end;

    local procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date)
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        if PricesInCurrency then begin
            Currency.Get(CurrencyCode2);
            Currency.TestField("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        end else
            GLSetup.Get();
    end;

    local procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATCalcType2: Enum "Tax Calculation Type"; VATBusPostingGr2: Code[20])
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATCalcType := VATCalcType2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure SetLineDisc(LineDiscPerCent2: Decimal; AllowLineDisc2: Boolean)
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    local procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);
            POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      PricesInclVATCantBeCalcErr,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            case VATCalcType of
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax":
                    begin
                        if PricesInclVAT then begin
                            if VATBusPostingGr <> FromVATBusPostingGr then
                                UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                        end else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                VATCalcType::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
        end else
            if PricesInclVAT then
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            if CurrencyCode = '' then
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end else
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(PriceListLine: Record "Price List Line"): Decimal
    begin
        if PriceListLine."Allow Line Disc." then
            exit(PriceListLine."Unit Price" * (1 - LineDiscPerCent / 100));
        exit(PriceListLine."Unit Price");
    end;

    local procedure GetCurrencyFactor(CurrencyCode: Code[10]; CurrencyDate: Date) Rate: Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if (CurrencyCode <> '') then begin
            if (CurrencyDate = 0D) then
                CurrencyDate := WorkDate();
            Rate := CurrExchRate.ExchangeRate(CurrencyDate, CurrencyCode);
        end else begin
            Rate := 0;
        end;
    end;

    local procedure GetPublisherCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sales Price Calc. Mgt.");
    end;

    local procedure GetPublisherFunction(): Text
    begin
        exit('OnFindItemPrice');
    end;

    local procedure GetPublisherRetailFunction(): Text
    begin
        exit('FindBestRetailPrice');
    end;

    procedure FilterPublishedFunction(var EventSubscription: Record "Event Subscription")

    begin
        EventSubscription.Reset();
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", GetPublisherCodeunitId());
        EventSubscription.SetRange("Published Function", GetPublisherFunction());
    end;

    procedure SelectPublishedFunction(var POSPricingProfile: Record "NPR POS Pricing Profile")
    var
        EventSubscription: Record "Event Subscription";
    begin
        FilterPublishedFunction(EventSubscription);
        if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
            exit;

        POSPricingProfile."Item Price Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
        POSPricingProfile."Item Price Function" := EventSubscription."Subscriber Function";
    end;

    procedure FilterSubscribedFunction(var EventSubscription: Record "Event Subscription"; POSPricingProfile: Record "NPR POS Pricing Profile")
    begin
        FilterPublishedFunction(EventSubscription);
        EventSubscription.SetRange("Subscriber Codeunit ID", POSPricingProfile."Item Price Codeunit ID");
        if POSPricingProfile."Item Price Function" <> '' then
            EventSubscription.SetRange("Subscriber Function", POSPricingProfile."Item Price Function");
    end;

    procedure SelectFirstSubscribedFunction(var POSPricingProfile: Record "NPR POS Pricing Profile")
    var
        EventSubscription: Record "Event Subscription";
    begin
        if POSPricingProfile."Item Price Function" = '' then begin
            POSPricingProfile."Item Price Codeunit ID" := 0;
            exit;
        end;
        FilterSubscribedFunction(EventSubscription, POSPricingProfile);
        EventSubscription.FindFirst();
    end;


}

