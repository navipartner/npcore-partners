codeunit 6151145 "NPR M2 POS Price WebService"
{
    trigger OnRun()
    begin
        // TEST_SOAP_PosPrice ();
        // TEST_SOAP_ItemPrice ();
    end;

    procedure POSQuote(var POSPriceRequest: XMLport "NPR M2 POS Sv. Sale Price Req.")
    var
        TmpSalePOS: Record "NPR POS Sale" temporary;
        TmpSaleLinePOS: Record "NPR POS Sale Line" temporary;
    begin
        SelectLatestVersion();

        POSPriceRequest.Import();
        POSPriceRequest.GetRequest(TmpSalePOS, TmpSaleLinePOS);

        if (TryPosQuoteRequest(TmpSalePOS, TmpSaleLinePOS)) then begin
            OnBeforeSetPOSQuoteResponse(TmpSalePOS, TmpSaleLinePOS);
            POSPriceRequest.SetResponse(TmpSalePOS, TmpSaleLinePOS);
        end else begin
            POSPriceRequest.SetErrorResponse(GetLastErrorText);
        end;
    end;

    [TryFunction]
    local procedure TryPosQuoteRequest(var TmpSalePOS: Record "NPR POS Sale" temporary; var TmpSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        Customer: Record Customer;
        VATBusPostingGroup: Code[20];
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DiscountPriority: Record "NPR Discount Priority";
        TmpSaleLinePOS2: Record "NPR POS Sale Line" temporary;
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
        Item: Record Item;
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CurrencyDiscCalcNotSupported: Label 'Discount module "%1" does not support discount calculations when exchange rates apply (%2 -> %3).';
    begin
        // Prepare Lines for VAT
        TmpSalePOS."Prices Including VAT" := true;

        VATBusPostingGroup := '';
        if (TmpSalePOS."Customer No." <> '') then begin
            if (Customer.Get(TmpSalePOS."Customer No.")) then begin
                VATBusPostingGroup := Customer."VAT Bus. Posting Group";
                TmpSalePOS."Customer No." := Customer."No.";
                TmpSalePOS."Prices Including VAT" := Customer."Prices Including VAT";
                TmpSalePOS."Customer Price Group" := Customer."Customer Price Group";
                TmpSalePOS."Customer Disc. Group" := Customer."Customer Disc. Group";
            end;
        end;

        TmpSaleLinePOS.Reset();
        if (TmpSaleLinePOS.FindSet()) then begin
            repeat
                if (Item.Get(TmpSaleLinePOS."No.")) then begin
                    if (VATBusPostingGroup = '') then begin
                        Item.TestField("VAT Bus. Posting Gr. (Price)");
                        VATBusPostingGroup := Item."VAT Bus. Posting Gr. (Price)";
                    end;

                    VATPostingSetup.Get(VATBusPostingGroup, Item."VAT Prod. Posting Group");

                    TmpSaleLinePOS."Sale Type" := TmpSaleLinePOS."Sale Type"::Sale;
                    TmpSaleLinePOS.Type := TmpSaleLinePOS.Type::Item;
                    TmpSaleLinePOS.Description := Item.Description;

                    TmpSaleLinePOS."Price Includes VAT" := TmpSalePOS."Prices Including VAT";
                    TmpSaleLinePOS."VAT %" := VATPostingSetup."VAT %";
                    TmpSaleLinePOS."VAT Calculation Type" := TmpSaleLinePOS."VAT Calculation Type"::"Normal VAT";
                    TmpSaleLinePOS."VAT Bus. Posting Group" := VATBusPostingGroup;
                    TmpSaleLinePOS."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";

                    TmpSaleLinePOS."Customer Price Group" := TmpSalePOS."Customer Price Group";
                    TmpSaleLinePOS."Item Disc. Group" := Item."Item Disc. Group";
                    TmpSaleLinePOS.SetSkipUpdateDependantQuantity(true);

                    POSSalesPriceCalcMgt.FindItemPrice(TmpSalePOS, TmpSaleLinePOS);
                    TmpSaleLinePOS.UpdateAmounts(TmpSaleLinePOS);

                end else begin
                    TmpSaleLinePOS.Type := TmpSaleLinePOS.Type::Comment;

                end;
                TmpSaleLinePOS.Modify();

                TmpSaleLinePOS2.TransferFields(TmpSaleLinePOS, true);
                TmpSaleLinePOS2.Insert();

            until (TmpSaleLinePOS.Next() = 0);
        end;

        TmpSaleLinePOS.FindFirst();
        TmpSaleLinePOS2.FindFirst();

        GeneralLedgerSetup.Get();

        DiscountPriority.SetCurrentKey(Priority);
        DiscountPriority.SetRange(Disabled, false);
        if (DiscountPriority.FindSet()) then begin
            repeat
                if (DiscountPriority."Table ID" = Database::"NPR Quantity Discount Header") and
                   (TmpSaleLinePOS."Currency Code" <> '') and (TmpSaleLinePOS."Currency Code" <> GeneralLedgerSetup."LCY Code")
                then begin
                    DiscountPriority.CalcFields("Table Name");
                    Error(CurrencyDiscCalcNotSupported, DiscountPriority."Table Name", GeneralLedgerSetup."LCY Code", TmpSaleLinePOS."Currency Code");
                end;

                POSSalesDiscountCalcMgt.ApplyDiscount(DiscountPriority, TmpSalePOS, TmpSaleLinePOS2, TmpSaleLinePOS, TmpSaleLinePOS, 0, true);
            until (DiscountPriority.Next() = 0);
        end;

        // Get the result back, find source record and update
        TmpSaleLinePOS2.Reset();
        if (TmpSaleLinePOS2.FindSet()) then begin
            repeat
                TmpSaleLinePOS.Get(TmpSaleLinePOS2."Register No.", TmpSaleLinePOS2."Sales Ticket No.", TmpSaleLinePOS2.Date, TmpSaleLinePOS2."Sale Type", TmpSaleLinePOS2."Line No.");

                TmpSaleLinePOS.TransferFields(TmpSaleLinePOS2, false);
                TmpSaleLinePOS.UpdateAmounts(TmpSaleLinePOS);
                TmpSaleLinePOS.Modify();
            until (TmpSaleLinePOS2.Next() = 0);
        end;
    end;

    procedure ItemPrice(var ItemPriceRequest: XMLport "NPR M2 Item Price Request")
    var
        TmpSalesPriceRequest: Record "NPR M2 Price Calc. Buffer" temporary;
        TmpPricePointResponse: Record "NPR M2 Price Calc. Buffer" temporary;
        TmpSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary;
        ResponseMessage: Text;
        ResponseCode: Code[10];
    begin
        SelectLatestVersion();

        ItemPriceRequest.Import();
        ItemPriceRequest.GetSalesPriceRequest(TmpSalesPriceRequest);

        if (TryItemPriceRequest(TmpSalesPriceRequest, TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode)) then begin
            OnBeforeSetSalesPriceResponse(TmpPricePointResponse, TmpSalesPriceResponse);
            ItemPriceRequest.SetSalesPriceResponse(TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode);
        end else begin
            ItemPriceRequest.SetErrorResponse(GetLastErrorText);
        end;
    end;

    [TryFunction]
    local procedure TryItemPriceRequest(var TmpSalesPriceRequest: Record "NPR M2 Price Calc. Buffer" temporary; var TmpPricePoint: Record "NPR M2 Price Calc. Buffer" temporary; var TmpSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary; var ResponseMessage: Text; var ResponseCode: Code[10])
    var
        Item: Record Item;
        Customer: Record Customer;
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RequestLineErrorMessage: Text;
        RequestLineError1Msg: Label 'Currency code "%1" is not valid.;';
        RequestLineError2Msg: Label 'There is no Currency Exchange Rate within the filter "%1" "..%2".;';
        RequestLineError3Msg: Label 'Unit of Measure Code "%1" is not valid for item "%2".;';
        RequestLineError4Msg: Label 'Customer number "%1" is not valid.;';
        RequestLineError5Msg: Label 'Item number "%1" is not valid.;';
    begin
        TmpSalesPriceRequest.Reset();
        if (not TmpSalesPriceRequest.FindSet()) then
            exit;

        GeneralLedgerSetup.Get();
        Clear(Customer);

        // Validate the Request
        repeat
            RequestLineErrorMessage := '';

            // Requires
            TmpSalesPriceResponse.Init();
            TmpSalesPriceResponse."Item No." := TmpSalesPriceRequest."Item No.";
            TmpSalesPriceResponse."Source Code" := TmpSalesPriceRequest."Source Code";
            TmpSalesPriceResponse."Request ID" := TmpSalesPriceRequest."Request ID";

            // Optional
            TmpSalesPriceResponse."Variant Code" := TmpSalesPriceRequest."Variant Code";
            TmpSalesPriceResponse."Unit of Measure Code" := TmpSalesPriceRequest."Unit of Measure Code";
            TmpSalesPriceResponse."Currency Code" := TmpSalesPriceRequest."Currency Code";
            TmpSalesPriceResponse."Show Details" := TmpSalesPriceRequest."Show Details";
            TmpSalesPriceResponse."Minimum Quantity" := TmpSalesPriceRequest."Minimum Quantity";

            TmpSalesPriceResponse."Price End Date" := TmpSalesPriceRequest."Price End Date";
            if (TmpSalesPriceResponse."Price End Date" < Today) then
                TmpSalesPriceResponse."Price End Date" := Today();

            // Provide Defaults
            if (Item.Get(TmpSalesPriceRequest."Item No.")) then begin

                if (TmpSalesPriceRequest."Currency Code" = '') then
                    TmpSalesPriceResponse."Currency Code" := GeneralLedgerSetup."LCY Code";

                if (not Currency.Get(TmpSalesPriceResponse."Currency Code")) then
                    RequestLineErrorMessage += StrSubstNo(RequestLineError1Msg, TmpSalesPriceResponse."Currency Code");

                CurrencyExchangeRate.SetFilter("Currency Code", '=%1', TmpSalesPriceResponse."Currency Code");

                CurrencyExchangeRate.SetFilter("Starting Date", '..%1', TmpSalesPriceResponse."Price End Date");
                if (CurrencyExchangeRate.IsEmpty()) then
                    RequestLineErrorMessage += StrSubstNo(RequestLineError2Msg, TmpSalesPriceResponse."Currency Code", TmpSalesPriceResponse."Price End Date");

                if (TmpSalesPriceResponse."Unit of Measure Code" = '') then
                    TmpSalesPriceResponse."Unit of Measure Code" := Item."Sales Unit of Measure";

                if (TmpSalesPriceResponse."Unit of Measure Code" = '') then
                    TmpSalesPriceResponse."Unit of Measure Code" := Item."Base Unit of Measure";

                if (not ItemUnitofMeasure.Get(Item."No.", TmpSalesPriceResponse."Unit of Measure Code")) then
                    RequestLineErrorMessage += StrSubstNo(RequestLineError3Msg, TmpSalesPriceResponse."Unit of Measure Code", Item."No.");

                TmpSalesPriceResponse."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";

                // Validate the customer
                if (Customer."No." <> TmpSalesPriceRequest."Source Code") then
                    Clear(Customer);

                if (TmpSalesPriceRequest."Source Code" <> '') then begin
                    if (not Customer.Get(TmpSalesPriceRequest."Source Code")) then begin
                        RequestLineErrorMessage += StrSubstNo(RequestLineError4Msg, TmpSalesPriceRequest."Source Code");
                        Clear(Customer);
                    end;
                end;

            end else begin
                RequestLineErrorMessage += StrSubstNo(RequestLineError5Msg, TmpSalesPriceRequest."Item No.");
            end;

            if (RequestLineErrorMessage <> '') then
                TmpSalesPriceResponse."Response Message" := CopyStr(CopyStr(RequestLineErrorMessage, 1, StrLen(RequestLineErrorMessage) - 1), 1, MaxStrLen(TmpSalesPriceResponse."Response Message"));

            TmpSalesPriceResponse.Insert();

        until (TmpSalesPriceRequest.Next() = 0);

        // Iterate the response set and find the price points
        TmpSalesPriceResponse.Reset();
        TmpSalesPriceResponse.SetFilter("Response Message", '=%1', '');
        if (TmpSalesPriceResponse.FindSet()) then begin
            repeat
                if (not FindPricePoints(TmpSalesPriceResponse, TmpPricePoint)) then begin
                    TmpSalesPriceResponse."Response Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(TmpSalesPriceResponse."Response Message"));
                    TmpSalesPriceResponse.Modify();
                end;
            until (TmpSalesPriceResponse.Next() = 0);
        end;

        // Set the overall result
        TmpSalesPriceResponse.Reset();
        TmpSalesPriceResponse.SetFilter("Response Message", '<>%1', '');
        if (not TmpSalesPriceResponse.IsEmpty()) then
            ResponseMessage += 'Partial resultset, result contains errors.';

        ResponseCode := 'OK';
        if (ResponseMessage <> '') then
            ResponseCode := 'ERROR';

        TmpSalesPriceRequest.Reset();
        TmpSalesPriceResponse.Reset();
        TmpPricePoint.Reset();
    end;

    [TryFunction]
    local procedure FindPricePoints(var TmpSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary; var TmpPricePoint: Record "NPR M2 Price Calc. Buffer" temporary)
    var
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        Customer: Record Customer;
        Item: Record Item;
        TmpSalesHeader: Record "Sales Header" temporary;
        TmpSalesLine: Record "Sales Line" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        TmpQtyBracket: Record "NPR M2 Price Calc. Buffer" temporary;
        TmpPricePointNew: Record "NPR M2 Price Calc. Buffer";
        SalesType: Enum "Sales Price Type";
        CampaignCode: Code[20];
    begin

        if (TmpSalesPriceResponse."Source Code" <> '') then
            if (not Customer.Get(TmpSalesPriceResponse."Source Code")) then
                Clear(Customer);

        Item.Get(TmpSalesPriceResponse."Item No.");
        TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
        Item.TestField("VAT Bus. Posting Gr. (Price)");

        if (Customer."VAT Bus. Posting Group" <> '') then begin
            Customer.TestField("VAT Bus. Posting Group");
            TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)" := Customer."VAT Bus. Posting Group";
        end;

        if (VATPostingSetup.Get(TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)", TmpSalesPriceResponse."VAT Prod. Posting Group")) then
            TmpSalesPriceResponse."Total VAT %" := VATPostingSetup."VAT %";

        TmpSalesHeader."Order Date" := TmpSalesPriceResponse."Price End Date";

        TmpSalesHeader.Validate("Currency Code", TmpSalesPriceResponse."Currency Code"); // Request Parameters, could be blank
        TmpSalesHeader."Bill-to Customer No." := Customer."No.";
        TmpSalesHeader."Sell-to Customer No." := Customer."No.";
        TmpSalesHeader."Prices Including VAT" := false;

        TmpSalesLine.Type := TmpSalesLine.Type::Item;
        TmpSalesLine."No." := TmpSalesPriceResponse."Item No.";
        TmpSalesLine."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TmpSalesLine."Bill-to Customer No." := TmpSalesHeader."Bill-to Customer No.";

        TmpSalesLine."VAT Calculation Type" := TmpSalesLine."VAT Calculation Type"::"Normal VAT";
        TmpSalesLine."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        TmpSalesLine."VAT %" := VATPostingSetup."VAT %";

        TmpSalesLine."Unit of Measure Code" := TmpSalesPriceResponse."Unit of Measure Code"; // Request Parameters, could be blank

        // Build the qty bracket for which we will return prices
        TmpQtyBracket.DeleteAll();
        TmpQtyBracket."Item No." := TmpSalesPriceResponse."Item No.";
        TmpQtyBracket."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TmpQtyBracket."Currency Code" := TmpSalesPriceResponse."Currency Code";
        TmpQtyBracket."Minimum Quantity" := 1;
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
            TmpQtyBracket."Minimum Quantity" := TmpSalesPriceResponse."Minimum Quantity";

        if (not TmpQtyBracket.Insert()) then;

        // Unit Price Brackets
        SalesPrice.SetFilter("Item No.", '=%1', TmpSalesPriceResponse."Item No.");
        SalesPrice.SetFilter("Starting Date", '=%1|<=%2', 0D, TmpSalesPriceResponse."Price End Date");
        SalesPrice.SetFilter("Ending Date", '=%1|>=%2', 0D, TmpSalesPriceResponse."Price End Date");

        SalesPrice.SetFilter("Variant Code", '=%1|=%2', '', TmpSalesPriceResponse."Variant Code");
        SalesPrice.SetFilter("Currency Code", '=%1|=%2', '', TmpSalesPriceResponse."Currency Code");
        SalesPrice.SetFilter("Unit of Measure Code", '=%1|=%2', '', TmpSalesPriceResponse."Unit of Measure Code");
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
            SalesPrice.SetFilter("Minimum Quantity", '=%1', TmpSalesPriceResponse."Minimum Quantity");


        // Item Discount % Brackets
        SalesLineDiscount.Reset();
        SalesLineDiscount.SetFilter(Type, '=%1', SalesLineDiscount.Type::Item);
        SalesLineDiscount.SetFilter(Code, '=%1', TmpSalesPriceResponse."Item No.");
        SalesLineDiscount.SetFilter("Starting Date", '=%1|<=%2', 0D, TmpSalesPriceResponse."Price End Date");
        SalesLineDiscount.SetFilter("Ending Date", '=%1|>=%2', 0D, TmpSalesPriceResponse."Price End Date");

        SalesLineDiscount.SetFilter("Variant Code", '=%1|=%2', '', TmpSalesPriceResponse."Variant Code");
        SalesLineDiscount.SetFilter("Currency Code", '=%1|=%2', '', TmpSalesPriceResponse."Currency Code");
        SalesLineDiscount.SetFilter("Unit of Measure Code", '=%1|=%2', '', TmpSalesPriceResponse."Unit of Measure Code");
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
            SalesLineDiscount.SetFilter("Minimum Quantity", '=%1', TmpSalesPriceResponse."Minimum Quantity");

        // SalesPrice: Customer,Customer Price Group,All Customers,Campaign
        // SaleLineDiscount: Customer,Customer Disc. Group,All Customers,Campaign
        for SalesType := SalesPrice."Sales Type"::Customer to SalesPrice."Sales Type"::Campaign do begin
            SalesPrice.SetFilter("Sales Type", '=%1', SalesType);
            SalesLineDiscount.SetFilter(Type, '=%1', SalesLineDiscount.Type::Item);
            SalesLineDiscount.SetFilter(Code, '=%1', TmpSalesPriceResponse."Item No.");

            case SalesType of
                SalesType::Customer:
                    begin
                        SalesPrice.SetFilter("Sales Code", '=%1', Customer."No.");
                        SalesLineDiscount.SetFilter("Sales Code", '=%1', Customer."No.");
                    end;
                SalesType::"Customer Price Group":
                    begin
                        SalesPrice.SetFilter("Sales Code", '=%1', Customer."Customer Price Group");
                        SalesLineDiscount.SetFilter("Sales Code", '=%1', Customer."Customer Disc. Group");
                    end;
                SalesType::"All Customers":
                    begin
                        SalesPrice.SetFilter("Sales Code", '=%1', '');
                        SalesLineDiscount.SetFilter("Sales Code", '=%1', '');
                    end;
                SalesType::Campaign:
                    begin
                        SalesPrice.SetFilter("Sales Code", '=%1', CampaignCode);
                        SalesLineDiscount.SetFilter("Sales Code", '=%1', CampaignCode);
                    end;
            end;

            if (SalesPrice.FindSet()) then begin
                repeat
                    TmpQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                    TmpQtyBracket."Minimum Quantity" := SalesPrice."Minimum Quantity";
                    TmpQtyBracket."Price End Date" := SalesPrice."Ending Date";
                    TmpQtyBracket."Unit Price Base" := SalesPrice."Unit Price";

                    if (not TmpQtyBracket.Insert()) then begin
                        TmpQtyBracket.Get(TmpQtyBracket."Item No.", TmpQtyBracket."Source Type", TmpQtyBracket."Source Code", TmpQtyBracket."Starting Date",
                            TmpQtyBracket."Currency Code", TmpQtyBracket."Variant Code", TmpQtyBracket."Unit of Measure Code", TmpQtyBracket."Minimum Quantity", TmpQtyBracket."Request ID");

                        // This will break when VAT is included in one of the prices but not the other. (The ending date could be wrong)
                        if (TmpQtyBracket."Unit Price Base" > SalesPrice."Unit Price") then begin
                            TmpQtyBracket."Unit Price Base" := SalesPrice."Unit Price";
                            TmpQtyBracket."Price End Date" := SalesPrice."Ending Date";
                            TmpQtyBracket.Modify();
                        end;
                    end;
                until (SalesPrice.Next() = 0);
            end;

            if (SalesLineDiscount.FindSet()) then begin
                repeat
                    TmpQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                    TmpQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                    TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                    TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

                    if (not TmpQtyBracket.Insert()) then begin
                        TmpQtyBracket.Get(TmpQtyBracket."Item No.", TmpQtyBracket."Source Type", TmpQtyBracket."Source Code", TmpQtyBracket."Starting Date", TmpQtyBracket."Currency Code",
                            TmpQtyBracket."Variant Code", TmpQtyBracket."Unit of Measure Code", TmpQtyBracket."Minimum Quantity", TmpQtyBracket."Request ID");
                        if (TmpQtyBracket."Line Discount %" < SalesLineDiscount."Line Discount %") then begin
                            TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                            TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                            TmpQtyBracket.Modify();
                        end;
                    end;

                until (SalesLineDiscount.Next() = 0);
            end;

            // Item Group Discount % Brackets
            if (Item."Item Disc. Group" <> '') then begin
                SalesLineDiscount.SetFilter(Type, '=%1', SalesLineDiscount.Type::"Item Disc. Group");
                SalesLineDiscount.SetFilter(Code, '=%1', Item."Item Disc. Group");
                if (SalesLineDiscount.FindSet()) then begin
                    repeat
                        TmpQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                        TmpQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                        TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                        TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

                        if (not TmpQtyBracket.Insert()) then begin
                            TmpQtyBracket.Get(TmpQtyBracket."Item No.", TmpQtyBracket."Source Type", TmpQtyBracket."Source Code", TmpQtyBracket."Starting Date",
                                TmpQtyBracket."Currency Code", TmpQtyBracket."Variant Code", TmpQtyBracket."Unit of Measure Code", TmpQtyBracket."Minimum Quantity", TmpQtyBracket."Request ID");
                            if (TmpQtyBracket."Line Discount %" > SalesLineDiscount."Line Discount %") then begin
                                TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                                TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                                TmpQtyBracket.Modify();
                            end;
                        end;

                    until (SalesLineDiscount.Next() = 0);
                end;
            end;
        end;

        // Calculate the unit price and discount for all brackets
        TmpQtyBracket.Reset();
        if (TmpQtyBracket.FindSet()) then begin
            repeat
                TmpSalesLine.Quantity := TmpQtyBracket."Minimum Quantity";
                TmpSalesLine."Qty. per Unit of Measure" := 1;
                if (TmpSalesLine."Unit of Measure Code" <> '') then
                    if (ItemUnitofMeasure.Get(TmpSalesLine."No.", TmpSalesLine."Unit of Measure Code")) then
                        if (ItemUnitofMeasure."Qty. per Unit of Measure" > 0) then
                            TmpSalesLine."Qty. per Unit of Measure" := ItemUnitofMeasure."Qty. per Unit of Measure";

                TmpSalesLine."Customer Disc. Group" := Customer."Customer Disc. Group";
                TmpSalesLine."Customer Price Group" := Customer."Customer Price Group";

                SalesPriceCalcMgt.FindSalesLinePrice(TmpSalesHeader, TmpSalesLine, 0);

                if (TmpSalesLine."Allow Line Disc.") then
                    SalesPriceCalcMgt.FindSalesLineLineDisc(TmpSalesHeader, TmpSalesLine);

                TmpPricePoint.TransferFields(TmpSalesPriceResponse);
                TmpPricePoint."Unit Price Base" := TmpSalesLine."Unit Price";
                TmpPricePoint."Unit Price" := TmpSalesLine."Unit Price" - TmpSalesLine."Unit Price" * TmpSalesLine."Line Discount %" / 100;
                TmpPricePoint."Minimum Quantity" := TmpSalesLine.Quantity;
                TmpPricePoint."Line Discount %" := TmpSalesLine."Line Discount %";
                TmpPricePoint."Price End Date" := TmpQtyBracket."Price End Date";
                TmpPricePoint."Discount End Date" := TmpQtyBracket."Discount End Date";

                if (not TmpPricePoint.Insert()) then begin
                    Clear(TmpPricePointNew);
                    TmpPricePointNew.TransferFields(TmpPricePoint, true);

                    TmpPricePoint.Get(TmpPricePoint."Item No.", TmpPricePoint."Source Type", TmpPricePoint."Source Code", TmpPricePoint."Starting Date",
                        TmpPricePoint."Currency Code", TmpPricePoint."Variant Code", TmpPricePoint."Unit of Measure Code", TmpPricePoint."Minimum Quantity", TmpPricePoint."Request ID");

                    if (TmpPricePointNew."Unit Price" < TmpPricePoint."Unit Price") then begin
                        TmpPricePoint.TransferFields(TmpPricePointNew, false);
                        TmpPricePoint.Modify();
                    end;
                end;

            until (TmpQtyBracket.Next() = 0);
        end;
    end;

    procedure ItemAvailabilityByPeriod(var ItemAvailabilityByPeriod: XMLport "NPR M2 Item Availab. By Period")
    begin
        ItemAvailabilityByPeriod.Import();
        ItemAvailabilityByPeriod.CalculateAvailability();
        // All logic in XML port to generate output on export
    end;

    procedure CustomerItemByPeriod(var CustomerItemByPeriod: XMLport "NPR M2 Customer Item By Period")
    begin
        CustomerItemByPeriod.Import();
        CustomerItemByPeriod.ValidateRequest();
        // All logic in XML port to generate output on export
    end;

    procedure EstimateDeliveryDate(var EstimateDeliveryDate: XMLport "NPR M2 Estimate Delivery Date")
    begin
        EstimateDeliveryDate.Import();
        EstimateDeliveryDate.PrepareResult();
    end;

    procedure GetWorkingDayCalendar(var GetWorkingDayCalendar: XMLport "NPR M2 Get WorkingDay Calendar")
    begin
        GetWorkingDayCalendar.Import();
        GetWorkingDayCalendar.PrepareResponse();
    end;

    #region Events
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSalesPriceResponse(var TmpPricePointResponse: Record "NPR M2 Price Calc. Buffer" temporary; var TmpSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPOSQuoteResponse(var TmpSalePOS: Record "NPR POS Sale" temporary; var TmpSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
    end;
    #endregion
}