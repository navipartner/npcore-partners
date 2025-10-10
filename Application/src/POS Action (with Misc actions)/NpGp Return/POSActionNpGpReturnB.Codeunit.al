codeunit 6059943 "NPR POS Action: NpGp Return B"
{
    Access = Internal;

    var
        NpGpCrossCompanySetup: Record "NPR NpGp Cross Company Setup";

    procedure CheckSetup(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        EmptyFieldErr: Label 'The %1 in %2 can not be blank or empty';
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnit.TestField("Global POS Sales Setup");
        NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup");

        if DelChr(NpGpPOSSalesSetup."Company Name", '<', ' ') = '' then
            Error(EmptyFieldErr, NpGpPOSSalesSetup.FieldName("Company Name"), NpGpPOSSalesSetup.TableName);

        if DelChr(NpGpPOSSalesSetup."Service Url", '<', ' ') = '' then
            Error(EmptyFieldErr, NpGpPOSSalesSetup.FieldName("Service Url"), NpGpPOSSalesSetup.TableName);
    end;

    procedure InitRequestBody(ServiceName: Text; ReferenceNo: Code[50]; FullSale: Boolean; var ContextXMLText: Text)
    var
        FullSaleTxt: Text;
    begin
        if FullSale then
            FullSaleTxt := 'true'
        else
            FullSaleTxt := 'false';
        ContextXMLText := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                            '<soapenv:Header />' +
                            '<soapenv:Body>' +
                                '<GetGlobalSale xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                                    '<referenceNumber>' + ReferenceNo + '</referenceNumber>' +
                                    '<fullSale>' + Format(FullSaleTxt) + '</fullSale>' +
                                    '<npGpPOSEntries />' +
                                '</GetGlobalSale>' +
                            '</soapenv:Body>' +
                        '</soapenv:Envelope>';
    end;

    procedure GetRecordsFromXml(XmlDoc: XmlDocument; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        NpGpPOSEntries: XmlPort "NPR NpGp POS Entries";
        OutStm: OutStream;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStm: InStream;
    begin
        TempBlob.CreateOutStream(OutStm);
        XmlDoc.WriteTo(OutStm);
        TempBlob.CreateInStream(InStm);
        NpGpPOSEntries.SetSource(InStm);
        NpGpPOSEntries.Import();
        NpGpPOSEntries.GetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);

        if TempNpGpPOSSalesLine.FindSet() then;
        if TempNpGpPOSSalesEntry.FindSet() then;
        if TempNpGpPOSPaymentLine.FindSet() then;
    end;

    procedure UpdateLineNos(SalePOS: Record "NPR POS Sale"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNumber: Record "Integer" temporary;
        LineNo: Integer;
        i: Integer;
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS.FindLast() then
            exit;

        TempNpGpPOSSalesLine.FindLast();

        if SaleLinePOS."Line No." < TempNpGpPOSSalesLine."Line No." then
            LineNo += TempNpGpPOSSalesLine."Line No."
        else
            LineNo := SaleLinePOS."Line No.";

        for i := 1 to SaleLinePOS.Count() do begin
            LineNo += 10000;
            TempNumber.Number := LineNo;
            TempNumber.Insert();
        end;

        TempNumber.FindSet();
        repeat
            SaleLinePOS.FindFirst();
            SaleLinePOS.Rename(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", TempNumber.Number);
        until TempNumber.Next() = 0;

        TempNpGpPOSSalesLine.FindSet();
    end;

    procedure PaymentMethodWarning(var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        WarningMsg: Text;
        PaidWithTxt: Label 'paid with %1 %2 %3\';
        PaidWithHeaderTxt: Label 'Please note the Payment Method\';
    begin
        if TempNpGpPOSPaymentLine.FindSet() then
            repeat
                if POSPaymentMethod.Get(TempNpGpPOSPaymentLine."POS Payment Method Code") and
                  POSPaymentMethod."NPR Warning pop-up on Return" then
                    WarningMsg := CopyStr(WarningMsg + StrSubstNo(PaidWithTxt, TempNpGpPOSPaymentLine.Description, Format(TempNpGpPOSPaymentLine."Payment Amount", 0, '<Precision,2:2><Standard format,0>'), ' '), 1, MaxStrLen(WarningMsg) - StrLen(PaidWithHeaderTxt))
            until TempNpGpPOSPaymentLine.Next() = 0;

        if WarningMsg = '' then
            exit;

        Message(PaidWithHeaderTxt + WarningMsg);
    end;

    procedure TestQuantity(var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; SalePOS: Record "NPR POS Sale")
    var
        POSCrossReference: Record "NPR POS Cross Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        QuantityOverloadedErr: Label 'Quantity of items returned cannot exceed the original amount';
    begin
        if TempNpGpPOSSalesLine.Quantity > 0 then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetFilter(Quantity, '<0');

            POSCrossReference.SetRange("Reference No.", TempNpGpPOSSalesLine."Global Reference");
            if POSCrossReference.FindSet() then
                repeat
                    SaleLinePOS.SetRange(SystemId, POSCrossReference.SystemId);
                    if SaleLinePOS.FindFirst() then
                        TempNpGpPOSSalesLine.Quantity += SaleLinePOS.Quantity;
                until POSCrossReference.Next() = 0;

            if TempNpGpPOSSalesLine.Quantity > 0 then
                exit;
        end;

        Error(QuantityOverloadedErr);
    end;

    procedure FindGlobalSaleByReferenceNo(ReferenceNo: Code[50]; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; FullSale: Boolean)
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        NpGpUserSaleReturn: Page "NPR NpGp User Sale Return";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        InterCompSetup: Boolean;
        POSSession: Codeunit "NPR POS Session";
        RefNoBlankErr: Label 'The reference number can not be blank or empty';
        NoInterCompTradeErr: Label 'Inter company exchange is not set up between "%1" and "%2"';
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnit.TestField("Global POS Sales Setup");
        NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup");

        if (DelChr(ReferenceNo, '<', ' ') = '') then
            Error(RefNoBlankErr);

        if CopyStr(ReferenceNo, StrLen(ReferenceNo) - 1) = 'XX' then
#pragma warning disable AA0139
            ReferenceNo := CopyStr(ReferenceNo, 1, StrLen(ReferenceNo) - 2);
#pragma warning restore

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        if NpGpPOSSalesSetup."Use api" then
            GetTempEntriesAPIRequest(NpGpPOSSalesSetup, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSPaymentLine, ReferenceNo, FullSale)
        else
            GetTempEntriesSoapRequest(NpGpPOSSalesSetup, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSPaymentLine, ReferenceNo, FullSale);
#ELSE
        GetTempEntriesSoapRequest(NpGpPOSSalesSetup, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSPaymentLine, ReferenceNo, FullSale);
#ENDIF

        InterCompSetup := NpGpCrossCompanySetup.Get(TempNpGpPOSSalesEntry."Original Company");

        if not InterCompSetup then begin
            NpGpCrossCompanySetup.SetRange("Original Company", '');
            InterCompSetup := NpGpCrossCompanySetup.FindFirst();
        end;

        if (not InterCompSetup) and (CompanyName <> TempNpGpPOSSalesEntry."Original Company") then
            Error(NoInterCompTradeErr, CompanyName, TempNpGpPOSSalesEntry."Original Company");

        if not FullSale then
            exit;

        if TempNpGpPOSSalesLine.FindSet() then begin
            NpGpUserSaleReturn.SetTables(SalePOS, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine);
            if not (NpGpUserSaleReturn.RunModal() = Action::OK) then
                Error('');
            NpGpUserSaleReturn.GetLines(TempNpGpPOSSalesLine);
        end;
    end;

    procedure CreateGlobalReverseSale(var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry"; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; ReturnReasonCode: Code[10]; FullSale: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
        POSSession: Codeunit "NPR POS Session";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if Customer.Get(TempNpGpPOSSalesEntry."Customer No.") then
            SalePOS.Validate("Customer No.", Customer."No.");

        if not FullSale then
            TestQuantity(TempNpGpPOSSalesLine, SalePOS)
        else begin
            TempNpGpPOSSalesLine.SetFilter(Quantity, '<0');
            if TempNpGpPOSSalesLine.IsEmpty then
                exit;
        end;

        POSSession.GetSaleLine(POSSaleLine);

        repeat
            POSSaleLine.GetNewSaleLine(SaleLinePOS);
            SaleLinePOS."VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
            SaleLinePOS."Gen. Bus. Posting Group" := NpGpCrossCompanySetup."Gen. Bus. Posting Group";

            if NpGpCrossCompanySetup."Use Original Item No." then
                Item.Get(TempNpGpPOSSalesLine."No.")
            else
                Item.Get(NpGpCrossCompanySetup."Generic Item No.");

            SaleLinePOS.Validate("No.", Item."No.");
            SaleLinePOS.Validate("Location Code", SalePOS."Location Code");
            SaleLinePOS.Validate("Variant Code", TempNpGpPOSSalesLine."Variant Code");
            SaleLinePOS.Description := TempNpGpPOSSalesLine.Description;
            SaleLinePOS."Description 2" := TempNpGpPOSSalesLine."Description 2";
            if FullSale then
                SaleLinePOS.Validate(Quantity, TempNpGpPOSSalesLine.Quantity)
            else
                SaleLinePOS.Validate(Quantity, -1);
            SaleLinePOS.Validate("Unit Price", TempNpGpPOSSalesLine."Unit Price");
            SaleLinePOS.Validate("Discount %", TempNpGpPOSSalesLine."Line Discount %");
            SaleLinePOS."Unit of Measure Code" := TempNpGpPOSSalesLine."Unit of Measure Code";
            SaleLinePOS."Currency Code" := TempNpGpPOSSalesLine."Currency Code";
            SaleLinePOS.Validate("VAT %", TempNpGpPOSSalesLine."VAT %");

            SaleLinePOS.Cost := SaleLinePOS.Amount;
            SaleLinePOS."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
            SaleLinePOS."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
            SaleLinePOS."Return Sale Sales Ticket No." := TempNpGpPOSSalesEntry."Document No.";
            SaleLinePOS."Return Reason Code" := ReturnReasonCode;
            POSSaleLine.InsertLineRaw(SaleLinePOS, false);
            POSCrossRefMgt.InitReference(SaleLinePOS.SystemId, TempNpGpPOSSalesLine."Global Reference", CopyStr(SaleLinePOS.TableName(), 1, 250), SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No."));
        until not FullSale or (TempNpGpPOSSalesLine.Next() = 0);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
        PaymentMethodWarning(TempNpGpPOSPaymentLine);
        POSSale.RefreshCurrent();
    end;

    procedure ExportPurchaseReturnOrder(Sale: Codeunit "NPR POS Sale"; ShowReturnOrd: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        MissingVendorErr: Label 'You need to enter Vendor No. for Item %1';
        Vendor: Record Vendor;
        PurcOrderHeader: Record "Purchase Header";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        PurchaseLine: Record "Purchase Line";
        NextLineNo: Integer;
        RetOrdCounter: Integer;
    begin
        Sale.GetCurrentSale(SalePOS);

        NextLineNo := 10000;
        RetOrdCounter := 0;

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter(Quantity, '<%1', 0);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        if SaleLinePOS.FindSet() then
            repeat
                if not Item.Get(SaleLinePOS."No.") then
                    exit;
                if not Vendor.Get(Item."Vendor No.") then
                    Error(MissingVendorErr, Item."No.");
                //check for existing purchase return order
                PurcOrderHeader.SetRange("Document Type", PurcOrderHeader."Document Type"::"Return Order");
                PurcOrderHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
                if PurcOrderHeader.FindFirst() then begin
                    //open purch order
                    ReleasePurchDoc.PerformManualReopen(PurcOrderHeader);
                    //add line
                    PurchaseLine.SetRange("Document Type", PurcOrderHeader."Document Type");
                    PurchaseLine.SetRange("Document No.", PurcOrderHeader."No.");
                    if PurchaseLine.FindLast() then
                        NextLineNo := PurchaseLine."Line No." + 10000;
                    RetOrdCounter += 1;
                end else begin
                    createPurchaseHeader(Vendor."No.", SalePOS."Location Code", PurcOrderHeader);
                    RetOrdCounter += 1;
                end;
                CreatePurcOrderLine(PurcOrderHeader, NextLineNo, SaleLinePOS);
                ReleasePurchDoc.PerformManualRelease(PurcOrderHeader);
            until SaleLinePOS.Next() = 0;

        if ShowReturnOrd then begin
            if RetOrdCounter = 1 then
                Page.Run(Page::"Purchase Return Order", PurcOrderHeader)
            else
                Page.Run(Page::"Purchase Return Order List");
        end;
    end;

    local procedure createPurchaseHeader(VendorNo: Code[20]; LocationCode: Code[20]; var PurchaseHeader: Record "Purchase Header")
    begin
        Clear(PurchaseHeader);

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        if LocationCode <> '' then
            PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Modify();
    end;

    local procedure CreatePurcOrderLine(PurcOrderHeader: Record "Purchase Header"; NextLineNo: Integer; SaleLinePOS: Record "NPR POS Sale Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurcOrderHeader."Document Type";
        PurchaseLine."Document No." := PurcOrderHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.Insert(true);

        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", SaleLinePOS."No.");
        if SaleLinePOS."Variant Code" <> '' then
            PurchaseLine.Validate("Variant Code", SaleLinePOS."Variant Code");

        if (SaleLinePOS."Location Code" <> '') then
            PurchaseLine.Validate("Location Code", SaleLinePOS."Location Code");

        PurchaseLine.Validate(Quantity, -SaleLinePOS.Quantity);
        PurchaseLine.Modify();
    end;

    local procedure GetTempEntriesSoapRequest(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
                                   var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
                                    ReferenceNo: Code[50]; FullSale: Boolean)
    var
        NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        XmlDoc: XmlDocument;
        ContextXMLText, ServiceName, Response, FirstNode, SecondNode, NameSpace : Text;
        Position1, Position2, Length : Integer;
        NoGlobalSaleErr: Label 'Could not find record of sale';
    begin
        ServiceName := NpGpPOSSalesSyncMgt.GetServiceName(NpGpPOSSalesSetup."Service Url");

        RequestMessage.GetHeaders(RequestHeaders);

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        InitRequestBody(ServiceName, ReferenceNo, FullSale, ContextXMLText);
        Content.WriteFrom(ContextXMLText);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'GetGlobalSale');
        RequestMessage.Content := Content;

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(Response);
            Error('%1 %2 \%3', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, Response);
        end;

        ResponseMessage.Content.ReadAs(Response);

        //Object Metadata table is accessible only for OnPrem target
        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/global_pos_sales';
        FirstNode := 'sales_entries';
        SecondNode := 'sales_entry';

        if StrPos(Response, SecondNode) = 0 then
            Error(NoGlobalSaleErr);

        Position1 := StrPos(Response, '<' + SecondNode);
        Position2 := StrPos(Response, '</' + SecondNode + '>');
        Length := Position2 - Position1 + StrLen('</' + SecondNode + '>');

        XmlDocument.ReadFrom('<' + FirstNode + ' xmlns="' + NameSpace + '">' +
                        CopyStr(Response, Position1, Length) +
         '</' + FirstNode + '>', XmlDoc);

        GetRecordsFromXml(XmlDoc, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine);
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    local procedure GetTempEntriesAPIRequest(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
                               var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
                                ReferenceNo: Code[50]; FullSale: Boolean)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Url, Tenant, Environment, Company, ErrorText, ResponseText : Text;
        NoGlobalSaleErr: Label 'Could not find record of sale';
    begin
        Url := GetApiBaseUrl(NpGpPOSSalesSetup."OData Base Url", Tenant, Environment, Company) + '/pos/globalentry/getbyreference?globalReference=' + ReferenceNo + '&fullSale=' + Format(FullSale, 0, 9);
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);
        Clear(ResponseMessage);

        if not (Client.Send(RequestMessage, ResponseMessage) and ResponseMessage.IsSuccessStatusCode()) then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) and (ResponseText <> '') then
                ErrorText += '\\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;

        ResponseMessage.Content.ReadAs(ResponseText);
        FillNpGpTempTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSPaymentLine, ResponseText);
        if TempNpGpPOSSalesEntry.IsEmpty() then
            Error(NoGlobalSaleErr);
    end;

    local procedure FillNpGpTempTables(var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
                                       var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
                                       var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; ResponseText: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        JToken: JsonToken;
        SalesLinesToken: JsonToken;
        PaymentLinesToken: JsonToken;
        JsonObjErr: Label 'Data cannot be read from json file';
    begin
        if not JToken.ReadFrom(ResponseText) then
            Error(JsonObjErr);

        InsertPOSSalesEntry(JToken, TempNpGpPOSSalesEntry);
        if JsonHelper.GetJsonToken(JToken, 'salesLines', SalesLinesToken) then
            InsertPOSSalesLines(SalesLinesToken, TempNpGpPOSSalesEntry."Entry No.", TempNpGpPOSSalesLine);

        if JsonHelper.GetJsonToken(JToken, 'paymentLines', PaymentLinesToken) then
            InsertPOSPaymentLines(PaymentLinesToken, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine);
    end;

    local procedure InsertPOSSalesEntry(JToken: JsonToken; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempNpGpPOSSalesEntry.Init();
#pragma warning disable AA0139
        TempNpGpPOSSalesEntry."POS Store Code" := JsonHelper.GetJCode(JToken, 'posStore', true);
        TempNpGpPOSSalesEntry."POS Unit No." := JsonHelper.GetJCode(JToken, 'posUnit', true);
        TempNpGpPOSSalesEntry."Document No." := JsonHelper.GetJCode(JToken, 'documentNo', true);
        TempNpGpPOSSalesEntry."Entry Time" := TextToDatetime(JsonHelper.GetJText(JToken, 'entryTime', true));
        Evaluate(TempNpGpPOSSalesEntry."Entry Type", JsonHelper.GetJText(JToken, 'entryType', true));
        TempNpGpPOSSalesEntry."Posting Date" := JsonHelper.GetJDate(JToken, 'postingDate', true);
        TempNpGpPOSSalesEntry."Fiscal No." := JsonHelper.GetJText(JToken, 'fiscalNumber', true);
        TempNpGpPOSSalesEntry."Sales Amount" := JsonHelper.GetJDecimal(JToken, 'salesAmount', true);
        TempNpGpPOSSalesEntry."Discount Amount" := JsonHelper.GetJDecimal(JToken, 'discountAmount', true);
        TempNpGpPOSSalesEntry."Total Amount" := JsonHelper.GetJDecimal(JToken, 'totalAmountExclVAT', true);
        TempNpGpPOSSalesEntry."Total Amount Incl. Tax" := JsonHelper.GetJDecimal(JToken, 'totalAmountInclVAT', true);
        TempNpGpPOSSalesEntry."Total Tax Amount" := JsonHelper.GetJDecimal(JToken, 'totalVATAmount', true);
        TempNpGpPOSSalesEntry."Original Company" := JsonHelper.GetJText(JToken, 'company', false);
        TempNpGpPOSSalesEntry."Customer No." := JsonHelper.GetJText(JToken, 'customerNo', false);
        TempNpGpPOSSalesEntry."Salesperson Code" := JsonHelper.GetJText(JToken, 'salesperson', false);
        TempNpGpPOSSalesEntry."Currency Code" := JsonHelper.GetJText(JToken, 'currencyCode', false);
        TempNpGpPOSSalesEntry."Currency Factor" := JsonHelper.GetJDecimal(JToken, 'currencyFactor', false);
        if TempNpGpPOSSalesEntry."Currency Factor" = 0 then
            TempNpGpPOSSalesEntry."Currency Factor" := 1;
        TempNpGpPOSSalesEntry.Insert(false);
#pragma warning restore
    end;

    local procedure InsertPOSSalesLines(SalesLinesToken: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        SalesLine: JsonToken;
    begin
        foreach SalesLine in SalesLinesToken.AsArray() do
            InsertPOSSalesLine(SalesLine, POSSalesEntryNo, TempNpGpPOSSalesLine);
    end;

    local procedure InsertPOSSalesLine(SalesLine: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempNpGpPOSSalesLine.Init();
        TempNpGpPOSSalesLine."POS Entry No." := POSSalesEntryNo;
        TempNpGpPOSSalesLine."Line No." := JsonHelper.GetJInteger(SalesLine, 'lineNo', true);
        Evaluate(TempNpGpPOSSalesLine.Type, JsonHelper.GetJText(SalesLine, 'type', true));
#pragma warning disable AA0139
        TempNpGpPOSSalesLine."No." := JsonHelper.GetJText(SalesLine, 'code', false);
#pragma warning restore AA0139
        TempNpGpPOSSalesLine.Validate(Quantity, JsonHelper.GetJDecimal(SalesLine, 'quantity', true));
        TempNpGpPOSSalesLine."Quantity (Base)" := JsonHelper.GetJDecimal(SalesLine, 'baseQuantity', true);
        if TempNpGpPOSSalesLine.Quantity <> 0 then
            TempNpGpPOSSalesLine."Qty. per Unit of Measure" := TempNpGpPOSSalesLine."Quantity (Base)" / TempNpGpPOSSalesLine.Quantity;
        TempNpGpPOSSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLine, 'unitPrice', true);
        TempNpGpPOSSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLine, 'vatPct', true);
        TempNpGpPOSSalesLine."Line Discount %" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountPct', true);
        TempNpGpPOSSalesLine."Line Discount Amount Excl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountExclVAT', true);
        TempNpGpPOSSalesLine."Line Discount Amount Incl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountInclVAT', true);
        TempNpGpPOSSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLine, 'lineAmount', true);
        TempNpGpPOSSalesLine."Amount Excl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'amountExclVAT', true);
        TempNpGpPOSSalesLine."Amount Incl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'amountInclVAT', true);
        TempNpGpPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountExclVATLCY', true);
        TempNpGpPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountInclVATLCY', true);
        TempNpGpPOSSalesLine."Amount Excl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'amountExclVATLCY', true);
        TempNpGpPOSSalesLine."Amount Incl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'amountInclVATLCY', true);
#pragma warning disable AA0139        
        TempNpGpPOSSalesLine."Currency Code" := JsonHelper.GetJText(SalesLine, 'currencyCode', false);
        TempNpGpPOSSalesLine."Global Reference" := JsonHelper.GetJText(SalesLine, 'globalReference', false);
        TempNpGpPOSSalesLine."Unit of Measure Code" := JsonHelper.GetJText(SalesLine, 'unitOfMeasureCode', false);
        TempNpGpPOSSalesLine."Variant Code" := JsonHelper.GetJText(SalesLine, 'variantCode', false);
        TempNpGpPOSSalesLine."Cross-Reference No." := JsonHelper.GetJText(SalesLine, 'referenceNumber', false);
        TempNpGpPOSSalesLine."BOM Item No." := JsonHelper.GetJText(SalesLine, 'bomItemCode', false);
        TempNpGpPOSSalesLine."Location Code" := JsonHelper.GetJText(SalesLine, 'locationCode', false);
        TempNpGpPOSSalesLine.Description := CopyStr(JsonHelper.GetJText(SalesLine, 'description', false), 1, MaxStrLen(TempNpGpPOSSalesLine.Description));
        TempNpGpPOSSalesLine."Description 2" := CopyStr(JsonHelper.GetJText(SalesLine, 'description2', false), 1, MaxStrLen(TempNpGpPOSSalesLine."Description 2"));
        TempNpGpPOSSalesLine.Insert(false);
#pragma warning restore AA0139
    end;

    local procedure InsertPOSPaymentLines(PaymentLines: JsonToken; TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        PaymentLine: JsonToken;
    begin
        foreach PaymentLine in PaymentLines.AsArray() do
            InsertPOSPaymentLine(PaymentLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine);
    end;

    local procedure InsertPOSPaymentLine(PaymentLine: JsonToken; TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempNpGpPOSPaymentLine.Init();
        TempNpGpPOSPaymentLine."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
        TempNpGpPOSPaymentLine."Line No." := JsonHelper.GetJInteger(PaymentLine, 'lineNo', true);
#pragma warning disable AA0139
        TempNpGpPOSPaymentLine."POS Payment Method Code" := JsonHelper.GetJText(PaymentLine, 'paymentMethod', true);
        TempNpGpPOSPaymentLine."Amount (LCY)" := JsonHelper.GetJDecimal(PaymentLine, 'amountLCY', true);
        TempNpGpPOSPaymentLine."Payment Amount" := JsonHelper.GetJDecimal(PaymentLine, 'amount', true);
        TempNpGpPOSPaymentLine."Document No." := JsonHelper.GetJCode(PaymentLine, 'documentNo', false);
        if TempNpGpPOSPaymentLine."Document No." = '' then
            TempNpGpPOSPaymentLine."Document No." := TempNpGpPOSSalesEntry."Document No.";
        TempNpGpPOSPaymentLine.Description := JsonHelper.GetJText(PaymentLine, 'description', false);
        TempNpGpPOSPaymentLine."Currency Code" := JsonHelper.GetJText(PaymentLine, 'currencyCode', false);
#pragma warning restore
        TempNpGpPOSPaymentLine.Insert(false);
    end;

    local procedure TextToDatetime(TextValue: Text): DateTime
    var
        DateTimeValue: DateTime;
    begin
        Evaluate(DateTimeValue, TextValue);
        exit(DateTimeValue);
    end;

    procedure GetApiBaseUrl(Url: Text; var Tenant: Text; var Environment: Text; var Company: Text) BaseUrl: Text
    begin
        ParseOdataUrlUrl(Url, Tenant, Environment, Company);
        BaseUrl := StrSubstNo('https://api.npretail.app/%1/%2/%3', Tenant, Environment, Company);
        exit(BaseUrl);
    end;

    procedure ParseOdataUrlUrl(FullUrl: Text; var Tenant: Text; var Environment: Text; var Company: Text)
    var
        UrlWithoutProtocol: Text;
        Parts: List of [Text];
    begin
        if StrPos(FullUrl, '://') > 0 then
            UrlWithoutProtocol := CopyStr(FullUrl, StrPos(FullUrl, '://') + 3, StrLen(FullUrl))
        else
            UrlWithoutProtocol := FullUrl;

        Parts := UrlWithoutProtocol.Split('/');
        Tenant := Parts.Get(2);
        Environment := Parts.Get(3);
        Company := Parts.Get(4);
    end;
#endif
}