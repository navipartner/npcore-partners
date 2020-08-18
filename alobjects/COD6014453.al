codeunit 6014453 "POS Sales Price Calc. Mgt."
{
    // NPR5.29/TJ  /20161223  CASE 249723 Copied custom functions (and some standard) from codeunit 7000
    // NPR5.31/MHA /20170113  CASE 263093 SalePOS."Customer Disc. Group" is used instead of Customer."Customer Disc. Group"
    // NPR5.41/JC  /20180404  CASE 309047 Fix error divide by zero on 100% discount & item with 0 unit price to not overwrite unit price on Sale POS
    // NPR5.45/MHA /20180803  CASE 323705 Deleted GetItemSalesPrice() and added InitDefaultPOSSale(),FindItemPrice(),OnFindItemPrice(),FindBestRetailPrice()
    // NPR5.48/JDH /20181114 CASE 335967  Unit of Measure implementation
    // NPR5.48/TSA /20181211 CASE 339549 Fixing the price calc function to work with currency code.
    // NPR5.50/TSA /20190509 CASE 354578 Added OnAfterFindSalesLinePrice() publisher
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() in InitTempPOSItemSale() and ConvertPriceToVAT()
    // NPR5.55/BHR /20200408 CASE 399443 Remove general setup for ItemPrice function.
    // NPR5.55/ALPO/20200605 CASE 407968 Do not ignore zero prices when calculating best unit price (same behaviour as in standard NAV starting from NAV2018)
    // NPR5.55/ALPO/20200702 CASE 412236 Removed redundant price recalculation


    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        Text010: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        Currency: Record Currency;
        TempSalesPrice: Record "Sales Price" temporary;
        TempSalesLineDisc: Record "Sales Line Discount" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        VATBusPostingGr: Code[10];
        QtyPerUOM: Decimal;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        FoundSalesPrice: Boolean;
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";

    procedure InitTempPOSItemSale(var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSalePOS: Record "Sale POS" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSTaxCalculation: Codeunit "POS Tax Calculation";
        Handled: Boolean;
    begin
        //-NPR5.45 [323705]
        if not Item.Get(TempSaleLinePOS."No.") then
          exit;

        //-NPR5.51 [358985]
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)",Item."VAT Prod. Posting Group");
        POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
        //+NPR5.51 [358985]

        TempSalePOS.Date := Today;
        TempSalePOS."Prices Including VAT" := TempSaleLinePOS."Price Includes VAT";
        TempSaleLinePOS."VAT %" := VATPostingSetup."VAT %";
        TempSaleLinePOS."VAT Calculation Type" := TempSaleLinePOS."VAT Calculation Type"::"Normal VAT";
        TempSaleLinePOS."VAT Bus. Posting Group" := Item."VAT Bus. Posting Gr. (Price)";
        //+NPR5.45 [323705]
    end;

    procedure FindItemPrice(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSUnit: Record "POS Unit";
        Handled: Boolean;
    begin
        //-NPR5.45 [323705]
        if POSUnit.Get(SalePOS."Register No.") then;
        //-NPR5.55 [399443]
        // IF NPRetailSetup.GET THEN;
        //
        // IF POSUnit."Item Price Function" = '' THEN BEGIN
        //  POSUnit."Item Price Codeunit ID" := NPRetailSetup."Item Price Codeunit ID";
        //  POSUnit."Item Price Function" := NPRetailSetup."Item Price Function";
        // END;
        //+NPR5.55 [399443]
        if POSUnit."Item Price Function" <> '' then begin
          OnFindItemPrice(POSUnit,SalePOS,SaleLinePOS,Handled);
          if Handled then
            exit;
        end;

        FindSalesLinePrice(SalePOS,SaleLinePOS);
        //+NPR5.45 [323705]

        //-NPR5.50 [354578]
        OnAfterFindSalesLinePrice (SalePOS, SaleLinePOS);
        //+NPR5.50 [354578]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindItemPrice(POSUnit: Record "POS Unit";SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS";var Handled: Boolean)
    begin
        //-NPR5.45 [323705]
        //+NPR5.45 [323705]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterFindSalesLinePrice(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014453, 'OnFindItemPrice', '', true, true)]
    local procedure FindBestRetailPrice(POSUnit: Record "POS Unit";SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS";var Handled: Boolean)
    begin
        //-NPR5.45 [323705]
        if POSUnit."Item Price Codeunit ID" <>  CODEUNIT::"POS Sales Price Calc. Mgt." then
          exit;
        if POSUnit."Item Price Function" <> 'FindBestRetailPrice' then
          exit;

        Handled := true;
        FindSalesLinePrice(SalePOS,SaleLinePOS);
        //+NPR5.45 [323705]

        //-NPR5.50 [354578]
        OnAfterFindSalesLinePrice (SalePOS, SaleLinePOS);
        //+NPR5.50 [354578]
    end;

    local procedure FindSalesLinePrice(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    var
        TempSaleLinePOS: Record "Sale Line POS" temporary;
    begin
        //-NPR5.45 [323705]
        with SaleLinePOS do begin
          //-NPR5.45 [323705]
          //SetCurrency(
          //  '',0,SalePOS.Date);
        
        
          //-NPR5.48 [339549]
          // SetCurrency("Currency Code",0,SalePOS.Date);
          SetCurrency ("Currency Code", GetCurrencyFactor ("Currency Code", SalePOS.Date), SalePOS.Date);
          //+NPR5.48 [339549]
        
          //+NPR5.45 [323705]
          SetVAT(SalePOS."Prices Including VAT","VAT %","VAT Calculation Type","VAT Bus. Posting Group");
          //-NPR5.48 [335967]
          //SetUoM(ABS(Quantity),1);
          SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
          //+NPR5.48 [335967]
        
          SetLineDisc("Discount %",SaleLinePOS."Allow Line Discount",SaleLinePOS."Allow Invoice Discount");
          //-NPR5.45 [323705]
          // CASE Type OF
          //   Type::Item:
          //     BEGIN
          if Type <>  Type::Item then
            exit;
          //+NPR5.45 [323705]
          Item.Get("No.");
          //SalesLinePriceExists(SalePOS,SaleLinePOS,FALSE);  //NPR5.55 [412236]-revoked
        
          if Item."Group sale" or "Custom Price" then begin
            TempSalesPrice.DeleteAll;
            TempSalesPrice."Sales Type"                   := TempSalesPrice."Sales Type"::"All Customers";
            TempSalesPrice."Item No."                     := SaleLinePOS."No.";
            TempSalesPrice."VAT Bus. Posting Gr. (Price)" := SaleLinePOS."VAT Bus. Posting Group";
            //-NPR5.55 [412236]-revoked
            /*
            IF Quantity > 0 THEN
              //-NPR5.41 [309047]
              IF "Discount %" = 100 THEN
                TempSalesPrice."Unit Price" := 0
              ELSE
              //+NPR5.41
                TempSalesPrice."Unit Price"                 := (("VAT Base Amount") /
                                                              ((100 - "Discount %") / 100))/Quantity;
        
            TempSalesPrice."Price Includes VAT"           := FALSE;
            */
            //+NPR5.55 [412236]-revoked
            //-NPR5.55 [412236]
            TempSalesPrice."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            TempSalesPrice."Currency Code" := SaleLinePOS."Currency Code";
            TempSalesPrice."Unit Price" := SaleLinePOS."Unit Price";
            TempSalesPrice."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
            //+NPR5.55 [412236]
            TempSalesPrice.Insert;
          end else  //NPR5.55 [412236]-ELSE added
            SalesLinePriceExists(SalePOS,SaleLinePOS,false);  //NPR5.55 [412236]
        
          CalcBestUnitPrice(TempSalesPrice);
        
          if Item.Get("No.") and Item."Explode BOM auto" then
            "Unit Price"                     := 0
          else
            //-NPR5.55 [407968]-revoked
            /*
            //-NPR5.41 [309047]
            IF TempSalesPrice."Unit Price" = 0 THEN
              "Unit Price"                     := "Unit Price"
            ELSE
            //+NPR5.41
            */
            //+NPR5.55 [407968]-revoked
              "Unit Price"                     := TempSalesPrice."Unit Price";
        
          "Price Includes VAT"             := SalePOS."Prices Including VAT";
          "Allow Line Discount"            := TempSalesPrice."Allow Line Disc.";
          "Allow Invoice Discount"         := TempSalesPrice."Allow Invoice Disc.";
          if not "Allow Line Discount" then
            "Discount %" := 0;
        end;
        //+NPR5.45 [323705]

    end;

    procedure FindSalesLineLineDisc(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS")
    begin
        with SaleLinePOS do begin
          SetCurrency('',0,0D);
          SetUoM(Abs(Quantity),1);

          if Type = Type::Item then begin
            SalesLineLineDiscExists(SalePOS,SaleLinePOS,false);
            CalcBestLineDisc(TempSalesLineDisc);

            "Discount %" := TempSalesLineDisc."Line Discount %";
          end;
        end;
    end;

    local procedure SalesLinePriceExists(SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS";ShowAll: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
          if Customer.Get(SalePOS."Customer No.") then;

        with SaleLinePOS do
          if (Type = Type::Item) and Item.Get("No.") then begin
            SalesPriceCalcMgt.FindSalesPrice(
              TempSalesPrice,Customer."No.",'',
              SalePOS."Customer Price Group",'',"No.","Variant Code",SaleLinePOS."Unit of Measure Code",
              '',SalePOS.Date,ShowAll);
            exit(TempSalesPrice.FindFirst);
          end;
        exit(false);
    end;

    procedure SalesLineLineDiscExists(SalePOS: Record "Sale POS";var SalesLine: Record "Sale Line POS";ShowAll: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
          if Customer.Get(SalePOS."Customer No.") then;

        with SalesLine do
          if (Type = Type::Item) and Item.Get("No.") then begin
            SalesPriceCalcMgt.FindSalesLineDisc(
              TempSalesLineDisc,Customer."No.",'',
              //-NPR5.31 [263093]
              //Customer."Customer Disc. Group",'',"No.",Item."Item Disc. Group","Variant Code",Unit,
              SalePOS."Customer Disc. Group",'',"No.",Item."Item Disc. Group","Variant Code","Unit of Measure Code",
              //+NPR5.31 [263093]
              '',SalePOS.Date,ShowAll);
            exit(TempSalesLineDisc.FindFirst);
          end;
        exit(false);
    end;

    local procedure CalcBestUnitPrice(var SalesPrice: Record "Sales Price")
    var
        BestSalesPrice: Record "Sales Price";
        BestSalesPriceFound: Boolean;
    begin
        with SalesPrice do begin
          FoundSalesPrice := FindSet;
          if FoundSalesPrice then
            repeat
              if IsInMinQty("Unit of Measure Code","Minimum Quantity") then begin
                ConvertPriceToVAT(
                  "Price Includes VAT",Item."VAT Prod. Posting Group",
                  "VAT Bus. Posting Gr. (Price)","Unit Price");
                ConvertPriceToUoM("Unit of Measure Code","Unit Price");
                ConvertPriceLCYToFCY("Currency Code","Unit Price");

                case true of
                  ((BestSalesPrice."Currency Code" = '') and ("Currency Code" <> '')) or
                  ((BestSalesPrice."Variant Code" = '') and ("Variant Code" <> '')):
                    begin  //NPR5.55 [407968]
                      BestSalesPrice := SalesPrice;
                    //-NPR5.55 [407968]
                      BestSalesPriceFound := true;
                    end;
                    //+NPR5.55 [407968]
                  ((BestSalesPrice."Currency Code" = '') or ("Currency Code" <> '')) and
                  ((BestSalesPrice."Variant Code" = '') or ("Variant Code" <> '')):
                    if (BestSalesPrice."Unit Price" = 0) or
                       (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                    then begin  //NPR5.55 [407968] (BEGIN added)
                      BestSalesPrice := SalesPrice;
                    //-NPR5.55 [407968]
                      BestSalesPriceFound := true;
                    end;
                    //+NPR5.55 [407968]
                end;
              end;
            until Next = 0;
        end;

        // No price found in agreement
        //IF BestSalesPrice."Unit Price" = 0 THEN BEGIN  //NPR5.55 [407968]-revoked
        if not BestSalesPriceFound then begin  //NPR5.55 [407968]
          ConvertPriceToVAT(
            Item."Price Includes VAT",Item."VAT Prod. Posting Group",
            Item."VAT Bus. Posting Gr. (Price)",Item."Unit Price");
          ConvertPriceToUoM('',Item."Unit Price");
          ConvertPriceLCYToFCY('',Item."Unit Price");

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
        with SalesLineDisc do begin
          if FindSet then
            repeat
              if IsInMinQty("Unit of Measure Code","Minimum Quantity") then
                case true of
                  ((BestSalesLineDisc."Currency Code" = '') and ("Currency Code" <> '')) or
                  ((BestSalesLineDisc."Variant Code" = '') and ("Variant Code" <> '')):
                    BestSalesLineDisc := SalesLineDisc;
                  ((BestSalesLineDisc."Currency Code" = '') or ("Currency Code" <> '')) and
                  ((BestSalesLineDisc."Variant Code" = '') or ("Variant Code" <> '')):
                    if BestSalesLineDisc."Line Discount %" < "Line Discount %" then
                      BestSalesLineDisc := SalesLineDisc;
                end;
            until Next = 0;
        end;

        SalesLineDisc := BestSalesLineDisc;
    end;

    local procedure SetCurrency(CurrencyCode2: Code[10];CurrencyFactor2: Decimal;ExchRateDate2: Date)
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        if PricesInCurrency then begin
          Currency.Get(CurrencyCode2);
          Currency.TestField("Unit-Amount Rounding Precision");
          CurrencyFactor := CurrencyFactor2;
          ExchRateDate := ExchRateDate2;
        end else
          GLSetup.Get;
    end;

    local procedure SetVAT(PriceInclVAT2: Boolean;VATPerCent2: Decimal;VATCalcType2: Option;VATBusPostingGr2: Code[10])
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATCalcType := VATCalcType2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    local procedure SetUoM(Qty2: Decimal;QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure SetLineDisc(LineDiscPerCent2: Decimal;AllowLineDisc2: Boolean;AllowInvDisc2: Boolean)
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
        AllowInvDisc := AllowInvDisc2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10];MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
          exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    local procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean;FromVATProdPostingGr: Code[10];FromVATBusPostingGr: Code[10];var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSTaxCalculation: Codeunit "POS Tax Calculation";
        Handled: Boolean;
    begin
        if FromPricesInclVAT then begin
          //-NPR5.51 [358985]
          VATPostingSetup.Get(FromVATBusPostingGr,FromVATProdPostingGr);
          POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup,Handled);
          //+NPR5.51 [358985]

          case VATPostingSetup."VAT Calculation Type" of
            VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
              VATPostingSetup."VAT %" := 0;
            VATPostingSetup."VAT Calculation Type"::"Sales Tax":
              Error(
                Text010,
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

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10];var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
          UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10];var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
          if CurrencyCode = '' then
            UnitPrice :=
              CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate,Currency.Code,UnitPrice,CurrencyFactor);
          UnitPrice := Round(UnitPrice,Currency."Unit-Amount Rounding Precision");
        end else
          UnitPrice := Round(UnitPrice,GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(SalesPrice: Record "Sales Price"): Decimal
    begin
        with SalesPrice do begin
          if "Allow Line Disc." then
            exit("Unit Price" * (1 - LineDiscPerCent / 100));
          exit("Unit Price");
        end;
    end;

    local procedure GetCurrencyFactor(CurrencyCode: Code[10];CurrencyDate: Date) Rate: Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin

        //-NPR5.48 [339549]
        if (CurrencyCode <> '') then begin
          if (CurrencyDate = 0D) then
            CurrencyDate := WorkDate;

          Rate := CurrExchRate.ExchangeRate (CurrencyDate, CurrencyCode);

        end else begin
          Rate := 0;

        end;
        //+NPR5.48 [339549]
    end;
}

