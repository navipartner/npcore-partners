codeunit 6151145 "M2 POS Price WebService"
{
    // NPR5.48/TSA /20181207 CASE 320426 Initial Version
    // NPR5.49/TSA /20190305 CASE 345373 Adding Item Availability By Period Service
    // NPR5.49/TSA /20190307 CASE 345375 Added Customer Item By Period Service
    // MAG2.21/TSA /20190423 CASE 350006 Added consideration of a price date other than TODAY.
    // MAG2.21/TSA /20190423 CASE 350006 Corrected a spelling mistake.
    // MAG2.23/TSA /20190930 CASE 370652 Customer No. was not set on request record passeed to ERP Price Calculation, removed TryFunction from TryPosQuoteRequest
    // MAG2.23/TSA /20190930 CASE 370652 Unit of Measure Code was not set on request record passed to ERP Price Calculation,
    // MAG2.25/TSA /20200213 CASE 349999 Added EstimateDeliveryDate(), GetWorkingDayCalendar ()
    // MAG2.25/TSA /20200226 CASE 391299 Added a "Allow Line Disc." check on the best price calculation.
    // MAG2.25/TSA /20200323 CASE 397545 Default VAT percent setup not supplied in itemprice response


    trigger OnRun()
    begin
        // TEST_SOAP_PosPrice ();
        // TEST_SOAP_ItemPrice ();
    end;

    [Scope('Personalization')]
    procedure POSQuote(var POSPriceRequest: XMLport "M2 POS Quote Price Request")
    var
        TmpSalePOS: Record "Sale POS" temporary;
        TmpSaleLinePOS: Record "Sale Line POS" temporary;
    begin

        SelectLatestVersion ();

        POSPriceRequest.Import;
        POSPriceRequest.GetRequest (TmpSalePOS, TmpSaleLinePOS);

        if (TryPosQuoteRequest (TmpSalePOS, TmpSaleLinePOS)) then begin
          POSPriceRequest.SetResponse (TmpSalePOS, TmpSaleLinePOS);

        end else begin
          POSPriceRequest.SetErrorResponse (GetLastErrorText);

        end;

        asserterror Error (''); // rollback any changes to the database we did in TryPosQuoteRequest()
    end;

    local procedure TryPosQuoteRequest(var TmpSalePOS: Record "Sale POS" temporary;var TmpSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        Customer: Record Customer;
        VATBusPostingGroup: Code[20];
        VATPostingSetup: Record "VAT Posting Setup";
        "--": Integer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalePOS: Record "Sale POS";
        TmpDiscountPriority: Record "Discount Priority" temporary;
        DiscountPriority: Record "Discount Priority";
        TmpSaleLinePOS2: Record "Sale Line POS" temporary;
        POSSalesPriceCalcMgt: Codeunit "POS Sales Price Calc. Mgt.";
        Item: Record Item;
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin

        // Prepare Lines for VAT
        TmpSalePOS."Prices Including VAT" := true;

        VATBusPostingGroup := '';
        if (TmpSalePOS."Customer No." <> '') then begin
          if (Customer.Get (TmpSalePOS."Customer No.")) then begin
            VATBusPostingGroup := Customer."VAT Bus. Posting Group";
            TmpSalePOS."Customer No." := Customer."No.";
            TmpSalePOS."Prices Including VAT" := Customer."Prices Including VAT";
            TmpSalePOS."Customer Price Group" := Customer."Customer Price Group";
            TmpSalePOS."Customer Disc. Group" := Customer."Customer Disc. Group";
          end;
        end;

        TmpSaleLinePOS.Reset ();
        if (TmpSaleLinePOS.FindSet ()) then begin
          repeat
            if (Item.Get (TmpSaleLinePOS."No.")) then begin
              if (VATBusPostingGroup = '') then begin
                Item.TestField ("VAT Bus. Posting Gr. (Price)");
                VATBusPostingGroup := Item."VAT Bus. Posting Gr. (Price)";
              end;

              VATPostingSetup.Get (VATBusPostingGroup, Item."VAT Prod. Posting Group");

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
              TmpSaleLinePOS.Silent := true;

              POSSalesPriceCalcMgt.FindItemPrice (TmpSalePOS, TmpSaleLinePOS);
              TmpSaleLinePOS.UpdateAmounts (TmpSaleLinePOS);

            end else begin
              TmpSaleLinePOS.Type := TmpSaleLinePOS.Type::Comment;

            end;
            TmpSaleLinePOS.Modify ();

            TmpSaleLinePOS2.TransferFields (TmpSaleLinePOS, true);
            TmpSaleLinePOS2.Insert ();

          until (TmpSaleLinePOS.Next () = 0);
        end;

        TmpSaleLinePOS.FindFirst;
        TmpSaleLinePOS2.FindFirst;

        GeneralLedgerSetup.Get ();

        // Discount functions require a persistent receipt header
        SalePOS.TransferFields (TmpSalePOS, true);
        if (not SalePOS.Insert ()) then SalePOS.Modify ();

        DiscountPriority.SetCurrentKey (Priority);
        DiscountPriority.SetFilter (Disabled, '=%1', false);
        if (DiscountPriority.FindSet ()) then begin
          repeat
            if (DiscountPriority."Table ID" = 6014439) and (TmpSaleLinePOS."Currency Code" <> '') and (TmpSaleLinePOS."Currency Code" <> GeneralLedgerSetup."LCY Code") then begin
              DiscountPriority.CalcFields ("Table Name");
              Error ('Discount module "%1" does not support discount calculations when exchange rates apply (%2 -> %3).', DiscountPriority."Table Name", GeneralLedgerSetup."LCY Code", TmpSaleLinePOS."Currency Code");
            end;

            POSSalesDiscountCalcMgt.ApplyDiscount (DiscountPriority, TmpSalePOS, TmpSaleLinePOS2, TmpSaleLinePOS, TmpSaleLinePOS, 0, true);
          until (DiscountPriority.Next () = 0);
        end;

        // Get the result back, find source record and update
        TmpSaleLinePOS2.Reset ();
        if (TmpSaleLinePOS2.FindSet ()) then begin
          repeat
            //TmpSaleLinePOS2.UpdateAmounts (TmpSaleLinePOS2);

            with TmpSaleLinePOS2 do
              TmpSaleLinePOS.Get ("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.");

            TmpSaleLinePOS.TransferFields (TmpSaleLinePOS2, false);
            TmpSaleLinePOS.UpdateAmounts (TmpSaleLinePOS);
            TmpSaleLinePOS.Modify ();

          until (TmpSaleLinePOS2.Next () = 0);

        end;

        //-MAG2.23, [370652]
        exit (true);
        //+MAG2.23, [370652]
    end;

    local procedure TEST_SOAP_PosPrice()
    var
        M2POSQuotePriceRequest: XMLport "M2 POS Quote Price Request";
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TmpSalePOS: Record "Sale POS" temporary;
        TmpSaleLinePOS: Record "Sale Line POS" temporary;
    begin

        xmltext :=
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
          '<PriceQuote xmlns="urn:microsoft-dynamics-nav/xmlports/x6151145">'+
            '<Request>'+
              '<Customer Number="">'+
                 '<Line LineNumber="101" ItemNumber="73034" Quantity="3"/>'+
                 '<Line LineNumber="102" ItemNumber="73034" Quantity="7"/>'+
                 '<Line LineNumber="103" ItemNumber="80001" VariantCode="1" Quantity="7"/>'+
              '</Customer>'+
            '</Request>'+
          '</PriceQuote>';

        // Request
        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2POSQuotePriceRequest.SetSource (iStream);
        M2POSQuotePriceRequest.Import ();

        // Process
        M2POSQuotePriceRequest.GetRequest (TmpSalePOS, TmpSaleLinePOS);
        TryPosQuoteRequest (TmpSalePOS, TmpSaleLinePOS);
        M2POSQuotePriceRequest.SetResponse (TmpSalePOS, TmpSaleLinePOS);

        // Reponse
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        M2POSQuotePriceRequest.SetDestination (oStream);
        M2POSQuotePriceRequest.Export ();
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2POSQuotePriceRequest.SetSource (iStream);
        iStream.Read (xmltext);
        Message (xmltext);
    end;

    local procedure "--"()
    begin
    end;

    [Scope('Personalization')]
    procedure ItemPrice(var ItemPriceRequest: XMLport "M2 Item Price Request")
    var
        TmpSalesPriceRequest: Record "M2 Price Calculation Buffer" temporary;
        TmpPriceBracketResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpDiscountBracketResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpPricePointResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpSalesPriceResponse: Record "M2 Price Calculation Buffer" temporary;
        ResponseMessage: Text;
        ResponseCode: Code[10];
    begin

        SelectLatestVersion ();

        ItemPriceRequest.Import;
        ItemPriceRequest.GetSalesPriceRequest (TmpSalesPriceRequest);

        if (TryItemPriceRequest (TmpSalesPriceRequest, TmpPriceBracketResponse, TmpDiscountBracketResponse, TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode)) then begin
          ItemPriceRequest.SetSalesPriceResponse (TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode);

        end else begin
          ItemPriceRequest.SetErrorResponse (GetLastErrorText);

        end;

        asserterror Error (''); // rollback any changes to the database
    end;

    [TryFunction]
    local procedure TryItemPriceRequest(var TmpSalesPriceRequest: Record "M2 Price Calculation Buffer" temporary;var TmpPriceBracket: Record "M2 Price Calculation Buffer" temporary;var TmpDiscountBracket: Record "M2 Price Calculation Buffer" temporary;var TmpPricePoint: Record "M2 Price Calculation Buffer" temporary;var TmpSalesPriceResponse: Record "M2 Price Calculation Buffer" temporary;var ResponseMessage: Text;var ResponseCode: Code[10])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Customer: Record Customer;
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RequestLineErrorMessage: Text;
    begin

        TmpSalesPriceRequest.Reset;
        if (not TmpSalesPriceRequest.FindSet ()) then
          exit;

        GeneralLedgerSetup.Get ();
        Clear (Customer);

        // Validate the Request
        repeat

          RequestLineErrorMessage := '';

          // Requires
          TmpSalesPriceResponse.Init;
          TmpSalesPriceResponse."Item No." := TmpSalesPriceRequest."Item No.";
          TmpSalesPriceResponse."Source Code" := TmpSalesPriceRequest."Source Code";
          TmpSalesPriceResponse."Request ID" := TmpSalesPriceRequest."Request ID";

          // Optional
          TmpSalesPriceResponse."Variant Code" := TmpSalesPriceRequest."Variant Code";
          TmpSalesPriceResponse."Unit of Measure Code" := TmpSalesPriceRequest."Unit of Measure Code";
          TmpSalesPriceResponse."Currency Code" := TmpSalesPriceRequest."Currency Code";
          TmpSalesPriceResponse."Show Details" := TmpSalesPriceRequest."Show Details";
          TmpSalesPriceResponse."Minimum Quantity" := TmpSalesPriceRequest."Minimum Quantity";

          //-MAG2.21 [350006]
          TmpSalesPriceResponse."Price End Date" := TmpSalesPriceRequest."Price End Date";
          if (TmpSalesPriceResponse."Price End Date" < Today) then
            TmpSalesPriceResponse."Price End Date" := Today;
          //+MAG2.21 [350006]

          // Provide Defaults
          if (Item.Get (TmpSalesPriceRequest."Item No.")) then begin

            if (TmpSalesPriceRequest."Currency Code" = '') then
              TmpSalesPriceResponse."Currency Code" := GeneralLedgerSetup."LCY Code";

            if (not Currency.Get (TmpSalesPriceResponse."Currency Code")) then
              RequestLineErrorMessage += StrSubstNo ('Currency code "%1" is not valid.;', TmpSalesPriceResponse."Currency Code");

            CurrencyExchangeRate.SetFilter ("Currency Code", '=%1', TmpSalesPriceResponse."Currency Code");

            //-MAG2.21 [350006]
            // CurrencyExchangeRate.SETFILTER ("Starting Date", '..%1', TODAY);
            // IF (CurrencyExchangeRate.ISEMPTY ()) THEN
            //   RequestLineErrorMessage += STRSUBSTNO ('There is no Currency Exchange Rate within the filter "%1" "..%2".;', TmpSalesPriceResponse."Currency Code", TODAY);
            CurrencyExchangeRate.SetFilter ("Starting Date", '..%1', TmpSalesPriceResponse."Price End Date");
            if (CurrencyExchangeRate.IsEmpty ()) then
              RequestLineErrorMessage += StrSubstNo ('There is no Currency Exchange Rate within the filter "%1" "..%2".;', TmpSalesPriceResponse."Currency Code", TmpSalesPriceResponse."Price End Date");
            //+MAG2.21 [350006]

            if (TmpSalesPriceResponse."Unit of Measure Code" = '') then
              TmpSalesPriceResponse."Unit of Measure Code" := Item."Sales Unit of Measure";

            if (TmpSalesPriceResponse."Unit of Measure Code" = '') then
              TmpSalesPriceResponse."Unit of Measure Code" := Item."Base Unit of Measure";

            if (not ItemUnitofMeasure.Get (Item."No.", TmpSalesPriceResponse."Unit of Measure Code")) then
              RequestLineErrorMessage += StrSubstNo ('Unit of Measure Code "%1" is not valid for item "%2".;', TmpSalesPriceResponse."Unit of Measure Code", Item."No.");

            //-MAG2.25 [397545]
            TmpSalesPriceResponse."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
            //+MAG2.25 [397545]

            // Validate the customer
            if (Customer."No." <> TmpSalesPriceRequest."Source Code") then
              Clear (Customer);

            if (TmpSalesPriceRequest."Source Code" <> '') then begin
              if (not Customer.Get (TmpSalesPriceRequest."Source Code")) then begin
                RequestLineErrorMessage += StrSubstNo ('Customer number "%1" is not valid.;', TmpSalesPriceRequest."Source Code");
                Clear (Customer);
              end;
            end;

          end else begin
            RequestLineErrorMessage += StrSubstNo ('Item number "%1" is not valid.;', TmpSalesPriceRequest."Item No.");
          end;

          if (RequestLineErrorMessage <> '') then
            TmpSalesPriceResponse."Response Message" := CopyStr (CopyStr (RequestLineErrorMessage, 1, StrLen(RequestLineErrorMessage)-1), 1, MaxStrLen (TmpSalesPriceResponse."Response Message"));

          TmpSalesPriceResponse.Insert ();

        until (TmpSalesPriceRequest.Next () = 0);

        // Iterate the response set and find the price points
        TmpSalesPriceResponse.Reset ();
        TmpSalesPriceResponse.SetFilter ("Response Message", '=%1', '');
        if (TmpSalesPriceResponse.FindSet ()) then begin
          repeat
            if (not FindPricePoints (TmpSalesPriceResponse, TmpPricePoint)) then begin
              TmpSalesPriceResponse."Response Message" := CopyStr (GetLastErrorText, 1, MaxStrLen (TmpSalesPriceResponse."Response Message"));
              TmpSalesPriceResponse.Modify ();
            end;
          until (TmpSalesPriceResponse.Next () = 0);
        end;

        // Set the overall result
        TmpSalesPriceResponse.Reset;
        TmpSalesPriceResponse.SetFilter ("Response Message", '<>%1', '');
        if (not TmpSalesPriceResponse.IsEmpty ()) then
          ResponseMessage += 'Partial resultset, result contains errors.';

        ResponseCode := 'OK';
        if (ResponseMessage <> '') then
          ResponseCode := 'ERROR';

        TmpSalesPriceRequest.Reset ();
        TmpSalesPriceResponse.Reset ();
        TmpPricePoint.Reset ();
    end;

    [TryFunction]
    local procedure FindPricePoints(var TmpSalesPriceResponse: Record "M2 Price Calculation Buffer" temporary;var TmpPricePoint: Record "M2 Price Calculation Buffer" temporary)
    var
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        TmpSalesPrice: Record "Sales Price" temporary;
        Customer: Record Customer;
        Item: Record Item;
        TmpSalesHeader: Record "Sales Header" temporary;
        TmpSalesLine: Record "Sales Line" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        TmpQtyBracket: Record "M2 Price Calculation Buffer" temporary;
        TmpPricePointNew: Record "M2 Price Calculation Buffer";
        SalesType: Option;
        CampaignCode: Code[20];
    begin

        if (TmpSalesPriceResponse."Source Code" <> '') then
          if (not Customer.Get (TmpSalesPriceResponse."Source Code")) then
            Clear (Customer);

        Item.Get (TmpSalesPriceResponse."Item No.");
        TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
        Item.TestField ("VAT Bus. Posting Gr. (Price)");

        if (Customer."VAT Bus. Posting Group" <> '') then begin
          Customer.TestField ("VAT Bus. Posting Group");
          TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)" := Customer."VAT Bus. Posting Group";
        end;

        if (VATPostingSetup.Get (TmpSalesPriceResponse."VAT Bus. Posting Gr. (Price)" , TmpSalesPriceResponse."VAT Prod. Posting Group")) then
          TmpSalesPriceResponse."Total VAT %" := VATPostingSetup."VAT %";

        //-MAG2.21 [350006]
        // TmpSalesHeader."Order Date" := TODAY;
        TmpSalesHeader."Order Date" := TmpSalesPriceResponse."Price End Date";
        //+MAG2.21 [350006]

        TmpSalesHeader.Validate ("Currency Code", TmpSalesPriceResponse."Currency Code"); // Request Parameters, could be blank
        TmpSalesHeader."Bill-to Customer No." := Customer."No.";
        //-MAG2.23 [370652]
        TmpSalesHeader."Sell-to Customer No." := Customer."No.";
        //+MAG2.23 [370652]
        TmpSalesHeader."Prices Including VAT" := false;

        TmpSalesLine.Type := TmpSalesLine.Type::Item;
        TmpSalesLine."No." := TmpSalesPriceResponse."Item No.";
        TmpSalesLine."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TmpSalesLine."Bill-to Customer No." := TmpSalesHeader."Bill-to Customer No.";

        TmpSalesLine."VAT Calculation Type" := TmpSalesLine."VAT Calculation Type"::"Normal VAT";
        TmpSalesLine."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        TmpSalesLine."VAT %" := VATPostingSetup."VAT %";

        //-MAG2.23 [370652]
        //TmpSalesLine."Unit of Measure" := TmpSalesPriceResponse."Unit of Measure Code"; // Request Parameters, could be blank
        TmpSalesLine."Unit of Measure Code" := TmpSalesPriceResponse."Unit of Measure Code"; // Request Parameters, could be blank
        //-MAG2.23 [370652]

        // Build the qty bracket for which we will return prices
        TmpQtyBracket.DeleteAll ();
        TmpQtyBracket."Item No." := TmpSalesPriceResponse."Item No.";
        TmpQtyBracket."Variant Code" := TmpSalesPriceResponse."Variant Code";
        TmpQtyBracket."Currency Code" := TmpSalesPriceResponse."Currency Code";
        TmpQtyBracket."Minimum Quantity" := 1;
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
          TmpQtyBracket."Minimum Quantity" := TmpSalesPriceResponse."Minimum Quantity";

        if (not TmpQtyBracket.Insert ()) then;

        // Unit Price Brackets
        SalesPrice.SetFilter ("Item No.", '=%1', TmpSalesPriceResponse."Item No.");
        //-MAG2.21 [350006]
        // SalesPrice.SETFILTER ("Starting Date", '=%1|<=%2', 0D, TODAY);
        // SalesPrice.SETFILTER ("Ending Date", '=%1|>=%2', 0D, TODAY);
        SalesPrice.SetFilter ("Starting Date", '=%1|<=%2', 0D, TmpSalesPriceResponse."Price End Date");
        SalesPrice.SetFilter ("Ending Date", '=%1|>=%2', 0D, TmpSalesPriceResponse."Price End Date");
        //+MAG2.21 [350006]

        SalesPrice.SetFilter ("Variant Code", '=%1|=%2', '', TmpSalesPriceResponse."Variant Code");
        SalesPrice.SetFilter ("Currency Code", '=%1|=%2', '', TmpSalesPriceResponse."Currency Code");
        SalesPrice.SetFilter ("Unit of Measure Code", '=%1|=%2', '', TmpSalesPriceResponse."Unit of Measure Code");
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
          SalesPrice.SetFilter ("Minimum Quantity", '=%1', TmpSalesPriceResponse."Minimum Quantity");


        // Item Discount % Brackets
        SalesLineDiscount.Reset ();
        SalesLineDiscount.SetFilter (Type, '=%1', SalesLineDiscount.Type::Item);
        SalesLineDiscount.SetFilter (Code, '=%1', TmpSalesPriceResponse."Item No.");
        //-MAG2.21 [350006]
        // SalesLineDiscount.SETFILTER ("Starting Date", '=%1|<=%2', 0D, TODAY);
        // SalesLineDiscount.SETFILTER ("Ending Date", '=%1|>=%2', 0D, TODAY);
        SalesLineDiscount.SetFilter ("Starting Date", '=%1|<=%2', 0D, TmpSalesPriceResponse."Price End Date");
        SalesLineDiscount.SetFilter ("Ending Date", '=%1|>=%2', 0D, TmpSalesPriceResponse."Price End Date");
        //+MAG2.21 [350006]

        SalesLineDiscount.SetFilter ("Variant Code", '=%1|=%2', '', TmpSalesPriceResponse."Variant Code");
        SalesLineDiscount.SetFilter ("Currency Code", '=%1|=%2', '', TmpSalesPriceResponse."Currency Code");
        SalesLineDiscount.SetFilter ("Unit of Measure Code", '=%1|=%2', '', TmpSalesPriceResponse."Unit of Measure Code");
        if (TmpSalesPriceResponse."Minimum Quantity" > 0) then
          SalesLineDiscount.SetFilter ("Minimum Quantity", '=%1', TmpSalesPriceResponse."Minimum Quantity");

        // SalesPrice: Customer,Customer Price Group,All Customers,Campaign
        // SaleLineDiscount: Customer,Customer Disc. Group,All Customers,Campaign
        for SalesType := SalesPrice."Sales Type"::Customer to SalesPrice."Sales Type"::Campaign do begin
          SalesPrice.SetFilter ("Sales Type", '=%1', SalesType);
          SalesLineDiscount.SetFilter (Type, '=%1', SalesLineDiscount.Type::Item);
          SalesLineDiscount.SetFilter (Code, '=%1', TmpSalesPriceResponse."Item No.");

          case SalesType of
            0 :
              begin
                SalesPrice.SetFilter ("Sales Code", '=%1', Customer."No.");
                SalesLineDiscount.SetFilter ("Sales Code", '=%1', Customer."No.");
              end;
            1 :
              begin
                SalesPrice.SetFilter ("Sales Code", '=%1', Customer."Customer Price Group");
                SalesLineDiscount.SetFilter ("Sales Code", '=%1', Customer."Customer Disc. Group");
              end;
            2 :
              begin
                SalesPrice.SetFilter ("Sales Code", '=%1', '');
                SalesLineDiscount.SetFilter ("Sales Code", '=%1', '');
              end;
            3 :
              begin
                SalesPrice.SetFilter ("Sales Code", '=%1', CampaignCode);
                SalesLineDiscount.SetFilter ("Sales Code", '=%1', CampaignCode);
              end;
          end;

          if (SalesPrice.FindSet ()) then begin
            repeat
              TmpQtyBracket.TransferFields (TmpSalesPriceResponse, true);
              TmpQtyBracket."Minimum Quantity" := SalesPrice."Minimum Quantity";
              TmpQtyBracket."Price End Date" := SalesPrice."Ending Date";
              TmpQtyBracket."Unit Price Base" := SalesPrice."Unit Price";

              if (not TmpQtyBracket.Insert ()) then begin
                with TmpQtyBracket do
                  Get ("Item No.", "Source Type", "Source Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Request ID");

                // This will break when VAT is included in one of the prices but not the other. (The ending date could be wrong)
                if (TmpQtyBracket."Unit Price Base" > SalesPrice."Unit Price") then begin
                  TmpQtyBracket."Unit Price Base" := SalesPrice."Unit Price";
                  TmpQtyBracket."Price End Date" := SalesPrice."Ending Date";
                  TmpQtyBracket.Modify ();
                end;
              end;
            until (SalesPrice.Next () = 0);
          end;

          if (SalesLineDiscount.FindSet ()) then begin
            repeat
              TmpQtyBracket.TransferFields (TmpSalesPriceResponse, true);
              TmpQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
              TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
              TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

              if (not TmpQtyBracket.Insert ()) then begin
                with TmpQtyBracket do
                  Get ("Item No.", "Source Type", "Source Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Request ID");
                if (TmpQtyBracket."Line Discount %" < SalesLineDiscount."Line Discount %")then begin
                  TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                  TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                  TmpQtyBracket.Modify ();
                end;
              end;

            until (SalesLineDiscount.Next () = 0);
          end;

          // Item Group Discount % Brackets
          if (Item."Item Disc. Group" <> '' ) then begin
            SalesLineDiscount.SetFilter (Type, '=%1', SalesLineDiscount.Type::"Item Disc. Group");
            SalesLineDiscount.SetFilter (Code, '=%1', Item."Item Disc. Group");
            if (SalesLineDiscount.FindSet ()) then begin
              repeat
                TmpQtyBracket.TransferFields (TmpSalesPriceResponse, true);
                TmpQtyBracket."Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";

                if (not TmpQtyBracket.Insert ()) then begin
                  with TmpQtyBracket do
                    Get ("Item No.", "Source Type", "Source Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Request ID");
                  if (TmpQtyBracket."Line Discount %" > SalesLineDiscount."Line Discount %") then begin
                    TmpQtyBracket."Line Discount %" := SalesLineDiscount."Line Discount %";
                    TmpQtyBracket."Discount End Date" := SalesLineDiscount."Ending Date";
                    TmpQtyBracket.Modify ();
                  end;
                end;

              until (SalesLineDiscount.Next () = 0);
            end;
          end;
        end;

        // Calculate the unit price and discount for all brackets
        TmpQtyBracket.Reset ();
        if (TmpQtyBracket.FindSet ()) then begin
          repeat
            TmpSalesLine.Quantity := TmpQtyBracket."Minimum Quantity";
            TmpSalesLine."Qty. per Unit of Measure" := 1;
            //-MAG2.23 [370652]
            //IF (TmpSalesLine."Unit of Measure" <> '') THEN
            //  IF (ItemUnitofMeasure.GET (TmpSalesLine."No.", TmpSalesLine."Unit of Measure")) THEN
            if (TmpSalesLine."Unit of Measure Code" <> '') then
              if (ItemUnitofMeasure.Get (TmpSalesLine."No.", TmpSalesLine."Unit of Measure Code")) then
            //+MAG2.23 [370652]
                if (ItemUnitofMeasure."Qty. per Unit of Measure" > 0) then
                  TmpSalesLine."Qty. per Unit of Measure" := ItemUnitofMeasure."Qty. per Unit of Measure";

            TmpSalesLine."Customer Disc. Group" := Customer."Customer Disc. Group";
            TmpSalesLine."Customer Price Group" := Customer."Customer Price Group";

            SalesPriceCalcMgt.FindSalesLinePrice (TmpSalesHeader, TmpSalesLine, 0);

            //-MAG2.25 [391299]
            // SalesPriceCalcMgt.FindSalesLineLineDisc (TmpSalesHeader, TmpSalesLine);
            if (TmpSalesLine."Allow Line Disc.") then
              SalesPriceCalcMgt.FindSalesLineLineDisc (TmpSalesHeader, TmpSalesLine);
            //+MAG2.25 [391299]

            TmpPricePoint.TransferFields (TmpSalesPriceResponse);
            TmpPricePoint."Unit Price Base" := TmpSalesLine."Unit Price";
            TmpPricePoint."Unit Price" := TmpSalesLine."Unit Price" - TmpSalesLine."Unit Price" * TmpSalesLine."Line Discount %" / 100;
            TmpPricePoint."Minimum Quantity" := TmpSalesLine.Quantity;
            TmpPricePoint."Line Discount %" := TmpSalesLine."Line Discount %";
            TmpPricePoint."Price End Date" := TmpQtyBracket."Price End Date";
            TmpPricePoint."Discount End Date" := TmpQtyBracket."Discount End Date";

            if (not TmpPricePoint.Insert ()) then begin
              Clear (TmpPricePointNew);
              TmpPricePointNew.TransferFields (TmpPricePoint, true);

              with TmpPricePoint do
                Get ("Item No.", "Source Type", "Source Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Request ID");

              if (TmpPricePointNew."Unit Price" < TmpPricePoint."Unit Price") then begin
                TmpPricePoint.TransferFields (TmpPricePointNew, false);
                TmpPricePoint.Modify ();
              end;
            end;

          until (TmpQtyBracket.Next () = 0);
        end;
    end;

    local procedure TEST_SOAP_ItemPrice()
    var
        M2ItemPriceRequest: XMLport "M2 Item Price Request";
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TmpSalesPriceRequest: Record "M2 Price Calculation Buffer" temporary;
        TmpPriceBracketResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpDiscountBracketResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpPricePointResponse: Record "M2 Price Calculation Buffer" temporary;
        TmpSalesPriceResponse: Record "M2 Price Calculation Buffer" temporary;
        ResponseMessage: Text;
        ResponseCode: Code[10];
    begin

        xmltext :=
          '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
          '<ItemPrice xmlns="urn:microsoft-dynamics-nav/xmlports/x6151146">'+
            '<Request RequestId="101" ItemNumber="80001" VariantCode="1" CustomerNumber="10034"/>'+
            '<Request RequestId="102" ItemNumber="80001" VariantCode="2"/>'+
            '<Request RequestId="103" ItemNumber="80001" VariantCode="1" CustomerNumber="10034" Quantity="7"/>'+
          '</ItemPrice>';

        // Request
        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ItemPriceRequest.SetSource (iStream);
        M2ItemPriceRequest.Import ();

        // Process
        M2ItemPriceRequest.GetSalesPriceRequest (TmpSalesPriceRequest);
        TryItemPriceRequest (TmpSalesPriceRequest, TmpPriceBracketResponse, TmpDiscountBracketResponse, TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode);
        M2ItemPriceRequest.SetSalesPriceResponse (TmpPricePointResponse, TmpSalesPriceResponse, ResponseMessage, ResponseCode);

        // Reponse
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        M2ItemPriceRequest.SetDestination (oStream);
        M2ItemPriceRequest.Export ();
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        M2ItemPriceRequest.SetSource (iStream);
        iStream.Read (xmltext);

        Message (xmltext);
    end;

    local procedure "---"()
    begin
    end;

    [Scope('Personalization')]
    procedure ItemAvailabilityByPeriod(var ItemAvailabilityByPeriod: XMLport "M2 Item Availability By Period")
    begin

        //-NPR5.49 [345373]
        ItemAvailabilityByPeriod.Import;
        ItemAvailabilityByPeriod.CalculateAvailability ();

        // All logic in XML port to generate output on export
        //+NPR5.49 [345373]
    end;

    [Scope('Personalization')]
    procedure CustomerItemByPeriod(var CustomerItemByPeriod: XMLport "M2 Customer Item By Period")
    begin

        //-NPR5.49 [345375]
        CustomerItemByPeriod.Import ();
        CustomerItemByPeriod.ValidateRequest ();

        // All logic in XML port to generate output on export
        //+NPR5.49 [345375]
    end;

    [Scope('Personalization')]
    procedure EstimateDeliveryDate(var EstimateDeliveryDate: XMLport "M2 Estimate Delivery Date")
    begin

        //-MAG2.25 [349999]
        EstimateDeliveryDate.Import ();
        EstimateDeliveryDate.PrepareResult ();
        //+MAG2.25 [349999]
    end;

    [Scope('Personalization')]
    procedure GetWorkingDayCalendar(var GetWorkingDayCalendar: XMLport "M2 Get WorkingDay Calendar")
    begin

        //-MAG2.25 [349999]
        GetWorkingDayCalendar.Import ();
        GetWorkingDayCalendar.PrepareResponse ();
        //+MAG2.25 [349999]
    end;
}

