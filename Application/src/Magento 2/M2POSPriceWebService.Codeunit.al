codeunit 6151145 "NPR M2 POS Price WebService"
{
    trigger OnRun()
    begin
        // TEST_SOAP_PosPrice ();
        // TEST_SOAP_ItemPrice ();
    end;

    procedure POSQuote(var POSPriceRequest: XMLport "NPR M2 POS Sv. Sale Price Req.")
    var
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
    begin
        SelectLatestVersion();

        POSPriceRequest.Import();
        POSPriceRequest.GetRequest(TempSalePOS, TempSaleLinePOS);

        if (TryPosQuoteRequest(TempSalePOS, TempSaleLinePOS)) then begin
            OnBeforeSetPOSQuoteResponse(TempSalePOS, TempSaleLinePOS);
            POSPriceRequest.SetResponse(TempSalePOS, TempSaleLinePOS);
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
        TempSaleLinePOS2: Record "NPR POS Sale Line" temporary;
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

                TempSaleLinePOS2.TransferFields(TmpSaleLinePOS, true);
                TempSaleLinePOS2.Insert();

            until (TmpSaleLinePOS.Next() = 0);
        end;

        TmpSaleLinePOS.FindFirst();
        TempSaleLinePOS2.FindFirst();

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

                POSSalesDiscountCalcMgt.ApplyDiscount(DiscountPriority, TmpSalePOS, TempSaleLinePOS2, TmpSaleLinePOS, TmpSaleLinePOS, 0, true);
            until (DiscountPriority.Next() = 0);
        end;

        // Get the result back, find source record and update
        TempSaleLinePOS2.Reset();
        if (TempSaleLinePOS2.FindSet()) then begin
            repeat
                TmpSaleLinePOS.Get(TempSaleLinePOS2."Register No.", TempSaleLinePOS2."Sales Ticket No.", TempSaleLinePOS2.Date, TempSaleLinePOS2."Sale Type", TempSaleLinePOS2."Line No.");

                TmpSaleLinePOS.TransferFields(TempSaleLinePOS2, false);
                TmpSaleLinePOS.UpdateAmounts(TmpSaleLinePOS);
                TmpSaleLinePOS.Modify();
            until (TempSaleLinePOS2.Next() = 0);
        end;
    end;

    procedure ItemPrice(var ItemPriceRequest: XMLport "NPR M2 Item Price Request")
    var
        TempSalesPriceRequest: Record "NPR M2 Price Calc. Buffer" temporary;
        TempPricePointResponse: Record "NPR M2 Price Calc. Buffer" temporary;
        TempSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary;
        ResponseMessage: Text;
        ResponseCode: Code[10];
    begin
        SelectLatestVersion();

        ItemPriceRequest.Import();
        ItemPriceRequest.GetSalesPriceRequest(TempSalesPriceRequest);

        if (TryItemPriceRequest(TempSalesPriceRequest, TempPricePointResponse, TempSalesPriceResponse, ResponseMessage, ResponseCode)) then begin
            OnBeforeSetSalesPriceResponse(TempPricePointResponse, TempSalesPriceResponse);
            ItemPriceRequest.SetSalesPriceResponse(TempPricePointResponse, TempSalesPriceResponse, ResponseMessage, ResponseCode);
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
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        TempQtyBracket: Record "NPR M2 Price Calc. Buffer" temporary;
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

        TempSalesHeader."Order Date" := TmpSalesPriceResponse."Price End Date";

        TempSalesHeader.Validate("Currency Code", TmpSalesPriceResponse."Currency Code"); // Request Parameters, could be blank
        TempSalesHeader."Bill-to Customer No." := Customer."No.";
        TempSalesHeader."Sell-to Customer No." := Customer."No.";
        TempSalesHeader."Prices Including VAT" := false;

        TempSalesLine.Type := TempSalesLine.Type::Item;
        TempSalesLine."No." := TmpSalesPriceResponse."Item No.";
        TempSalesLine."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TempSalesLine."Bill-to Customer No." := TempSalesHeader."Bill-to Customer No.";

        TempSalesLine."VAT Calculation Type" := TempSalesLine."VAT Calculation Type"::"Normal VAT";
        TempSalesLine."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        TempSalesLine."VAT %" := VATPostingSetup."VAT %";

        TempSalesLine."Unit of Measure Code" := TmpSalesPriceResponse."Unit of Measure Code"; // Request Parameters, could be blank

        // Build the qty bracket for which we will return prices
        TempQtyBracket.DeleteAll();
        TempQtyBracket."Item No." := TmpSalesPriceResponse."Item No.";
        TempQtyBracket."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TempQtyBracket."Currency Code" := TmpSalesPriceResponse."Currency Code";
        TempQtyBracket."Minimum Quantity" := 1;
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
            TempQtyBracket."Minimum Quantity" := TmpSalesPriceResponse."Minimum Quantity";

        if (not TempQtyBracket.Insert()) then;

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
                    TempQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                    TempQtyBracket."Minimum Quantity" := SalesPrice."Minimum Quantity";
                    TempQtyBracket."Price End Date" := SalesPrice."Ending Date";
                    TempQtyBracket."Unit Price Base" := SalesPrice."Unit Price";

                    if (not TempQtyBracket.Insert()) then begin
                        TempQtyBracket.Get(TempQtyBracket."Item No.", TempQtyBracket."Source Type", TempQtyBracket."Source Code", TempQtyBracket."Starting Date",
                            TempQtyBracket."Currency Code", TempQtyBracket."Variant Code", TempQtyBracket."Unit of Measure Code", TempQtyBracket."Minimum Quantity", TempQtyBracket."Request ID");

                        // This will break when VAT is included in one of the prices but not the other. (The ending date could be wrong)
                        if (TempQtyBracket."Unit Price Base" > SalesPrice."Unit Price") then begin
                            TempQtyBracket."Unit Price Base" := SalesPrice."Unit Price";
                            TempQtyBracket."Price End Date" := SalesPrice."Ending Date";
                            TempQtyBracket.Modify();
                        end;
                    end;
                until (SalesPrice.Next() = 0);
            end;

            if (SalesLineDiscount.FindSet()) then begin
                repeat
                    TempQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                    TempQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                    TempQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                    TempQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

                    if (not TempQtyBracket.Insert()) then begin
                        TempQtyBracket.Get(TempQtyBracket."Item No.", TempQtyBracket."Source Type", TempQtyBracket."Source Code", TempQtyBracket."Starting Date", TempQtyBracket."Currency Code",
                            TempQtyBracket."Variant Code", TempQtyBracket."Unit of Measure Code", TempQtyBracket."Minimum Quantity", TempQtyBracket."Request ID");
                        if (TempQtyBracket."Line Discount %" < SalesLineDiscount."Line Discount %") then begin
                            TempQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                            TempQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                            TempQtyBracket.Modify();
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
                        TempQtyBracket.TransferFields(TmpSalesPriceResponse, true);
                        TempQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                        TempQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                        TempQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

                        if (not TempQtyBracket.Insert()) then begin
                            TempQtyBracket.Get(TempQtyBracket."Item No.", TempQtyBracket."Source Type", TempQtyBracket."Source Code", TempQtyBracket."Starting Date",
                                TempQtyBracket."Currency Code", TempQtyBracket."Variant Code", TempQtyBracket."Unit of Measure Code", TempQtyBracket."Minimum Quantity", TempQtyBracket."Request ID");
                            if (TempQtyBracket."Line Discount %" > SalesLineDiscount."Line Discount %") then begin
                                TempQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                                TempQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                                TempQtyBracket.Modify();
                            end;
                        end;

                    until (SalesLineDiscount.Next() = 0);
                end;
            end;
        end;

        // Calculate the unit price and discount for all brackets
        TempQtyBracket.Reset();
        if (TempQtyBracket.FindSet()) then begin
            repeat
                TempSalesLine.Quantity := TempQtyBracket."Minimum Quantity";
                TempSalesLine."Qty. per Unit of Measure" := 1;
                if (TempSalesLine."Unit of Measure Code" <> '') then
                    if (ItemUnitofMeasure.Get(TempSalesLine."No.", TempSalesLine."Unit of Measure Code")) then
                        if (ItemUnitofMeasure."Qty. per Unit of Measure" > 0) then
                            TempSalesLine."Qty. per Unit of Measure" := ItemUnitofMeasure."Qty. per Unit of Measure";

                TempSalesLine."Customer Disc. Group" := Customer."Customer Disc. Group";
                TempSalesLine."Customer Price Group" := Customer."Customer Price Group";

                SalesPriceCalcMgt.FindSalesLinePrice(TempSalesHeader, TempSalesLine, 0);

                if (TempSalesLine."Allow Line Disc.") then
                    SalesPriceCalcMgt.FindSalesLineLineDisc(TempSalesHeader, TempSalesLine);

                TmpPricePoint.TransferFields(TmpSalesPriceResponse);
                TmpPricePoint."Unit Price Base" := TempSalesLine."Unit Price";
                TmpPricePoint."Unit Price" := TempSalesLine."Unit Price" - TempSalesLine."Unit Price" * TempSalesLine."Line Discount %" / 100;
                TmpPricePoint."Minimum Quantity" := TempSalesLine.Quantity;
                TmpPricePoint."Line Discount %" := TempSalesLine."Line Discount %";
                TmpPricePoint."Price End Date" := TempQtyBracket."Price End Date";
                TmpPricePoint."Discount End Date" := TempQtyBracket."Discount End Date";

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

            until (TempQtyBracket.Next() = 0);
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