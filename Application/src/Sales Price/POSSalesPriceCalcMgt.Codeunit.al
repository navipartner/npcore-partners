codeunit 6014453 "NPR POS Sales Price Calc. Mgt."
{
    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        PricesInclVATCantBeCalcErr: Label 'Prices including VAT cannot be calculated when %1 is %2.', Comment = '%1=VATPostingSetup.FieldCaption("VAT Calculation Type");%2=VATPostingSetup."VAT Calculation Type")';
        Currency: Record Currency;
        TempSalesPrice: Record "Sales Price" temporary;
        TempSalesLineDisc: Record "Sales Line Discount" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATCalcType: Enum "Tax Calculation Type";
        VATBusPostingGr: Code[20];
        QtyPerUOM: Decimal;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        FoundSalesPrice: Boolean;
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";

    procedure InitTempPOSItemSale(var TempSaleLinePOS: Record "NPR Sale Line POS" temporary; var TempSalePOS: Record "NPR Sale POS" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
        Handled: Boolean;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
            exit;

        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
        POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);

        TempSalePOS.Date := Today();
        TempSalePOS."Prices Including VAT" := TempSaleLinePOS."Price Includes VAT";
        TempSaleLinePOS."VAT %" := VATPostingSetup."VAT %";
        TempSaleLinePOS."VAT Calculation Type" := TempSaleLinePOS."VAT Calculation Type"::"Normal VAT";
        TempSaleLinePOS."VAT Bus. Posting Group" := Item."VAT Bus. Posting Gr. (Price)";
    end;

    procedure FindItemPrice(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS")
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
    local procedure OnFindItemPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterFindSalesLinePrice(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Price Calc. Mgt.", 'OnFindItemPrice', '', true, true)]
    local procedure FindBestRetailPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; var Handled: Boolean)
    begin
        if POSPricingProfile."Item Price Codeunit ID" <> GetPublisherCodeunitId() then
            exit;
        if POSPricingProfile."Item Price Function" <> GetPublisherRetailFunction() then
            exit;

        Handled := true;
        FindSalesLinePrice(SalePOS, SaleLinePOS);

        OnAfterFindSalesLinePrice(SalePOS, SaleLinePOS);
    end;

    local procedure FindSalesLinePrice(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS")
    var
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
    begin
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;

        SetCurrency(SaleLinePOS."Currency Code", GetCurrencyFactor(SaleLinePOS."Currency Code", SalePOS.Date), SalePOS.Date);

        SetVAT(SalePOS."Prices Including VAT", SaleLinePOS."VAT %", SaleLinePOS."VAT Calculation Type", SaleLinePOS."VAT Bus. Posting Group");

        SetUoM(Abs(SaleLinePOS.Quantity), SaleLinePOS."Qty. per Unit of Measure");

        SetLineDisc(SaleLinePOS."Discount %", SaleLinePOS."Allow Line Discount", SaleLinePOS."Allow Invoice Discount");

        Item.Get(SaleLinePOS."No.");

        if Item."NPR Group sale" or SaleLinePOS."Custom Price" then begin
            TempSalesPrice.DeleteAll();
            TempSalesPrice."Sales Type" := TempSalesPrice."Sales Type"::"All Customers";
            TempSalesPrice."Item No." := SaleLinePOS."No.";
            TempSalesPrice."VAT Bus. Posting Gr. (Price)" := SaleLinePOS."VAT Bus. Posting Group";
            TempSalesPrice."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            TempSalesPrice."Currency Code" := SaleLinePOS."Currency Code";
            TempSalesPrice."Unit Price" := SaleLinePOS."Unit Price";
            TempSalesPrice."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
            TempSalesPrice.Insert();
        end else
            SalesLinePriceExists(SalePOS, SaleLinePOS, false);

        CalcBestUnitPrice(TempSalesPrice);

        if Item.Get(SaleLinePOS."No.") and Item."NPR Explode BOM auto" then
            SaleLinePOS."Unit Price" := 0
        else
            SaleLinePOS."Unit Price" := TempSalesPrice."Unit Price";

        SaleLinePOS."Price Includes VAT" := SalePOS."Prices Including VAT";
        SaleLinePOS."Allow Line Discount" := TempSalesPrice."Allow Line Disc.";
        SaleLinePOS."Allow Invoice Discount" := TempSalesPrice."Allow Invoice Disc.";
        if not SaleLinePOS."Allow Line Discount" then
            SaleLinePOS."Discount %" := 0;
    end;

    procedure FindSalesLineLineDisc(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        if SaleLinePOS.Type <> SaleLinePOS.Type then
            exit;
        SetCurrency('', 0, 0D);
        SetUoM(Abs(SaleLinePOS.Quantity), 1);

        SalesLineLineDiscExists(SalePOS, SaleLinePOS, false);
        CalcBestLineDisc(TempSalesLineDisc);

        SaleLinePOS."Discount %" := TempSalesLineDisc."Line Discount %";
    end;

    local procedure SalesLinePriceExists(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; ShowAll: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;

        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            if Customer.Get(SalePOS."Customer No.") then;

        SalesPriceCalcMgt.FindSalesPrice(
            TempSalesPrice, Customer."No.", '',
            SalePOS."Customer Price Group", '',
            SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code",
            '', SalePOS.Date, ShowAll);
        exit(TempSalesPrice.FindFirst());
    end;

    procedure SalesLineLineDiscExists(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; ShowAll: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;

        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            if Customer.Get(SalePOS."Customer No.") then;

        SalesPriceCalcMgt.FindSalesLineDisc(
            TempSalesLineDisc, Customer."No.", '',
            SalePOS."Customer Disc. Group", '', SaleLinePOS."No.", Item."Item Disc. Group", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code",
            '', SalePOS.Date, ShowAll);
        exit(TempSalesLineDisc.FindFirst);
    end;

    local procedure CalcBestUnitPrice(var SalesPrice: Record "Sales Price")
    var
        BestSalesPrice: Record "Sales Price";
        BestSalesPriceFound: Boolean;
    begin
        FoundSalesPrice := SalesPrice.FindSet();
        if FoundSalesPrice then
            repeat
                if IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") then begin
                    ConvertPriceToVAT(
                        SalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                        SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    case true of
                        ((BestSalesPrice."Currency Code" = '') and (SalesPrice."Currency Code" <> '')) or
                        ((BestSalesPrice."Variant Code" = '') and (SalesPrice."Variant Code" <> '')):
                            begin
                                BestSalesPrice := SalesPrice;
                                BestSalesPriceFound := true;
                            end;
                        ((BestSalesPrice."Currency Code" = '') or (SalesPrice."Currency Code" <> '')) and
                        ((BestSalesPrice."Variant Code" = '') or (SalesPrice."Variant Code" <> '')):
                            if (BestSalesPrice."Unit Price" = 0) or
                                (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                            then begin
                                BestSalesPrice := SalesPrice;
                                BestSalesPriceFound := true;
                            end;
                    end;
                end;
            until SalesPrice.Next() = 0;

        // No price found in agreement
        if not BestSalesPriceFound then begin
            ConvertPriceToVAT(
              Item."Price Includes VAT", Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)", Item."Unit Price");
            ConvertPriceToUoM('', Item."Unit Price");
            ConvertPriceLCYToFCY('', Item."Unit Price");

            Clear(BestSalesPrice);
            BestSalesPrice."Unit Price" := Item."Unit Price";
            BestSalesPrice."Allow Line Disc." := AllowLineDisc;
            BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;
        end;

        SalesPrice := BestSalesPrice;
    end;

    local procedure CalcBestLineDisc(var SalesLineDisc: Record "Sales Line Discount")
    var
        BestSalesLineDisc: Record "Sales Line Discount";
    begin
        if SalesLineDisc.FindSet() then
            repeat
                if IsInMinQty(SalesLineDisc."Unit of Measure Code", SalesLineDisc."Minimum Quantity") then
                    case true of
                        ((BestSalesLineDisc."Currency Code" = '') and (SalesLineDisc."Currency Code" <> '')) or
                        ((BestSalesLineDisc."Variant Code" = '') and (SalesLineDisc."Variant Code" <> '')):
                            BestSalesLineDisc := SalesLineDisc;
                        ((BestSalesLineDisc."Currency Code" = '') or (SalesLineDisc."Currency Code" <> '')) and
                        ((BestSalesLineDisc."Variant Code" = '') or (SalesLineDisc."Variant Code" <> '')):
                            if BestSalesLineDisc."Line Discount %" < SalesLineDisc."Line Discount %" then
                                BestSalesLineDisc := SalesLineDisc;
                    end;
            until SalesLineDisc.Next() = 0;

        SalesLineDisc := BestSalesLineDisc;
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

    local procedure SetLineDisc(LineDiscPerCent2: Decimal; AllowLineDisc2: Boolean; AllowInvDisc2: Boolean)
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
        AllowInvDisc := AllowInvDisc2;
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
        POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
        Handled: Boolean;
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);
            POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);

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

    local procedure CalcLineAmount(SalesPrice: Record "Sales Price"): Decimal
    begin
        if SalesPrice."Allow Line Disc." then
            exit(SalesPrice."Unit Price" * (1 - LineDiscPerCent / 100));
        exit(SalesPrice."Unit Price");
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

