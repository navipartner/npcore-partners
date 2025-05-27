#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248432 "NPR LoyaltyGeneralAgent"
{
    Access = Internal;

    var
        HelperFunctions: Codeunit "NPR Loyalty Helper Functions";

    trigger OnRun()
    begin

    end;

    internal procedure GetLoyaltyMembershipReceiptPdf(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSEntry: Record "NPR POS Entry";
        Membership: Record "NPR MM Membership";
        ReportSelections: Record "NPR Report Selection Retail";
        RecRef: RecordRef;
        ExternalMembershipNumber: Code[20];
        ReceiptEntryNoText: Text;
        PdfDoc: Text;
        LanguageIdText: Text;
        ReceiptEntryNo: Integer;
        LanguageId: Integer;
        TempBlob: Codeunit "Temp Blob";
        oStream: OutStream;
        Instr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ExternalMembershipNumber := CopyStr(_Request.Paths().Get(5), 1, MaxStrLen(ExternalMembershipNumber));
        ReceiptEntryNoText := CopyStr(_Request.Paths().Get(6), 1, MaxStrLen(ReceiptEntryNoText));

        ReceiptEntryNo := 0;
        if ReceiptEntryNoText <> '' then
            Evaluate(ReceiptEntryNo, ReceiptEntryNoText);

        ReportSelections.SetFilter("Report Type", '=%1', ReportSelections."Report Type"::"Large Sales Receipt (POS Entry)");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);

        if (not ReportSelections.FindFirst()) then
            ReportSelections."Report ID" := REPORT::"NPR Sales Ticket A4 - POS Rdlc";

        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNumber);
        Membership.FindFirst();
        Membership.TestField("Customer No.");

        POSEntry.Get(ReceiptEntryNo);
        POSEntry.TestField("Customer No.", Membership."Customer No.");
        POSEntry.SetRecFilter();
        RecRef.GetTable(POSEntry);

        LanguageIdText := HelperFunctions.GetQueryParameterFromRequest(_Request, 'languageId');

        if LanguageIdText <> '' then
            Evaluate(LanguageId, LanguageIdText);

        if LanguageId <> 0 then
            LanguageId := GlobalLanguage(LanguageId);

        TempBlob.CreateOutStream(oStream);
        Report.SaveAs(ReportSelections."Report ID", '', ReportFormat::Pdf, oStream, RecRef);
        TempBlob.CreateInStream(Instr);
        if (LanguageId <> 0) then
            GlobalLanguage(LanguageId);

        PdfDoc := Base64Convert.ToBase64(Instr);

        exit(Response.RespondOK(PdfDoc));
    end;

    internal procedure RegisterSale(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        JToken, JTokSales, JTokPayments : JsonToken;
    begin
        HelperFunctions.InsertAuthorizationHeader(_Request, TempAuthorization);

        JToken := _Request.BodyJson();
        JToken.SelectToken('sales', JTokSales);
        JToken.SelectToken('payments', JTokPayments);

        GetSalesLines(JTokSales, TempSalesLines);
        GetPaymentLines(JTokPayments, TempPaymentLines);

        Response := RegisterSale(TempAuthorization, TempSalesLines, TempPaymentLines);
    end;

    internal procedure GetLoyaltyConfiguration(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
    begin
        HelperFunctions.InsertAuthorizationHeader(_Request, TempAuthorization);

        Response := GetLoyaltyConfiguration(TempAuthorization);
    end;

    local procedure GetLoyaltyConfiguration(var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary) Response: Codeunit "NPR API Response"
    var
        TempLoyaltySetup: Record "NPR MM Loyalty Setup" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if (LoyaltyPointsMgrServer.GetLoyaltySetup(TempAuthorization, TempLoyaltySetup, ResponseMessage, ResponseMessageId)) then
            HelperFunctions.SetLoyaltyResponse(TempLoyaltySetup)
        else
            HelperFunctions.SetErrorResponse(ResponseMessage, ResponseMessageId);

        if HelperFunctions.GetResponseCode() = 'OK' then
            exit(Response.RespondOK(GetResponse('getLoyaltyConfiguration')))
        else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()))
    end;

    internal procedure GetLoyaltyMembershipReceiptList(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipNumber, CardNumber, CustomerNumber : Text;
        DocumentDate: Date;
    begin
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
        CardNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'cardNumber');
        CustomerNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'customerNumber');

        DocumentDate := Today();

        Response := GetLoyaltyMembershipReceiptList(_Request, MembershipNumber, CardNumber, CustomerNumber, DocumentDate);
    end;

    internal procedure GetLoyaltyMembershipReceiptList(_Request: Codeunit "NPR API Request"; MembershipNumber: Text; CardNumber: Text; CustomerNumber: Text; DocumentDate: Date) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipEntryNo: Integer;
        CurrencyCode: Code[20];
        DateValidFromDate, DateValidUntilDate : Date;
    begin
        MembershipEntryNo := HelperFunctions.GetMembershipEntryNo(CardNumber, MembershipNumber, CustomerNumber);

        if (MembershipEntryNo = 0) or (not Membership.Get(MembershipEntryNo)) then
            Response.RespondBadRequest('Invalid membership entry no.');

        HelperFunctions.SetResponse('OK', 'Success');

        Membership.SetFilter("Date Filter", '..%1', DocumentDate);
        Membership.SetRange("Entry No.", MembershipEntryNo);
        Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        if not Membership.FindSet() then
            Response.RespondBadRequest(StrSubstNo('Membership not found for Entry No. "%1" and Date Filter "%2"', MembershipEntryNo, DocumentDate));

        GeneralLedgerSetup.Get();
        CurrencyCode := GeneralLedgerSetup."LCY Code";

        MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today, DateValidFromDate, DateValidUntilDate);

        ResponseJson := CreateJsonResponseMembershipReceiptList(ResponseJson, Membership, CurrencyCode, DateValidFromDate, DateValidUntilDate, DocumentDate);

        exit(Response.RespondOK(ResponseJson));
    end;

    local procedure RegisterSale(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpSaleLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPaymentLinesIn: Record "NPR MM Reg. Sales Buffer" temporary) Response: Codeunit "NPR API Response"
    var
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if (LoyaltyPointsMgrServer.RegisterSales(TmpAuthorizationIn, TmpSaleLinesIn, TmpPaymentLinesIn, TempPointsResponse, ResponseMessage, ResponseMessageId)) then
            HelperFunctions.SetPointsResponse(TempPointsResponse)
        else
            HelperFunctions.SetErrorResponse(ResponseMessage, ResponseMessageId);

        if HelperFunctions.GetResponseCode() = 'OK' then
            exit(Response.RespondOK(GetResponse('registerSale')))
        else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()))
    end;

    local procedure GetSalesLines(JTokSales: JsonToken; var TempSalesLines: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
        Line: JsonToken;
    begin
        if JTokSales.AsArray().Count <= 0 then
            exit;

        foreach Line in JTokSales.AsArray() do begin
            TempSalesLines.Init();
            TempSalesLines.Type := JsonMgmt.GetJInteger(Line, 'type', false);
            TempSalesLines."Item No." := CopyStr(JsonMgmt.GetJCode(Line, 'itemNumber', false), 1, MaxStrLen(TempSalesLines."Item No."));
            TempSalesLines."Variant Code" := CopyStr(JsonMgmt.GetJCode(Line, 'variantCode', false), 1, MaxStrLen(TempSalesLines."Variant Code"));
            TempSalesLines.Quantity := JsonMgmt.GetJDecimal(Line, 'quantity', false);
            TempSalesLines.Description := CopyStr(JsonMgmt.GetJText(Line, 'description', false), 1, MaxStrLen(TempSalesLines.Description));
            TempSalesLines."Currency Code" := CopyStr(JsonMgmt.GetJCode(Line, 'currencyCode', false), 1, MaxStrLen(TempSalesLines."Currency Code"));
            TempSalesLines."Total Amount" := JsonMgmt.GetJInteger(Line, 'amount', false);
            TempSalesLines."Total Points" := JsonMgmt.GetJInteger(Line, 'points', false);
            TempSalesLines."Retail Id" := JsonMgmt.GetJText(Line, 'id', false);
            TempSalesLines.Insert();
        end;
    end;

    local procedure GetPaymentLines(JTokPayments: JsonToken; var TempPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
        Line: JsonToken;
    begin
        if JTokPayments.AsArray().Count <= 0 then
            exit;

        foreach Line in JTokPayments.AsArray() do begin
            TempPaymentLines.Init();
            TempPaymentLines.Type := JsonMgmt.GetJInteger(Line, 'type', false);
            TempPaymentLines.Description := CopyStr(JsonMgmt.GetJText(Line, 'description', false), 1, MaxStrLen(TempPaymentLines.Description));
            TempPaymentLines."Currency Code" := CopyStr(JsonMgmt.GetJCode(Line, 'currencyCode', false), 1, MaxStrLen(TempPaymentLines."Currency Code"));
            TempPaymentLines."Total Amount" := JsonMgmt.GetJDecimal(Line, 'amount', false);
            TempPaymentLines."Total Points" := JsonMgmt.GetJDecimal(Line, 'points', false);
            TempPaymentLines."Authorization Code" := CopyStr(JsonMgmt.GetJText(Line, 'authorizationCode', false), 1, MaxStrLen(TempPaymentLines."Authorization Code"));
            TempPaymentLines."Retail Id" := JsonMgmt.GetJText(Line, 'id', false);
            TempPaymentLines.Insert();
        end;
    end;

    local procedure GetResponse(FunctionName: Text): Codeunit "NPR JSON Builder"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        ResponseJson.AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                    .AddObject(HelperFunctions.GetResponseByFunctionName(ResponseJson, FunctionName));

        exit(ResponseJson);
    end;

    local procedure CreateJsonResponseMembershipReceiptList(var ResponseJson: Codeunit "NPR JSON Builder"; var Membership: Record "NPR MM Membership"; CurrencyCode: Code[20]; DateValidFromDate: Date; DateValidUntilDate: Date; DocumentDate: Date): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject('response')
                        .AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                        .AddObject(AddMembership(ResponseJson, Membership, DateValidFromDate, DateValidUntilDate, DocumentDate))
                        .AddArray(AddReceipts(ResponseJson, Membership."Customer No.", CurrencyCode))
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure AddMembership(var ResponseJson: Codeunit "NPR JSON Builder"; var Membership: Record "NPR MM Membership"; DateValidFromDate: Date; DateValidUntilDate: Date; DocumentDate: Date): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject('membership')
                        .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, false, Membership, DateValidFromDate, DateValidUntilDate))
                        .StartObject('accumulated')
                            .AddProperty('untilDate', Format(CalcDate('<-1D>', DocumentDate), 0, 9))
                            .StartObject('awarded')
                                .AddProperty('sales', Membership."Awarded Points (Sale)")
                                .AddProperty('refund', Membership."Awarded Points (Refund)")
                            .EndObject()
                            .StartObject('redeemed')
                                .AddProperty('withdrawal', Membership."Redeemed Points (Withdrawl)")
                                .AddProperty('deposit', Membership."Redeemed Points (Deposit)")
                            .EndObject()
                            .AddProperty('expired', Membership."Expired Points")
                            .AddProperty('remaining', Membership."Remaining Points")
                        .EndObject()
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure AddReceipts(var ResponseJson: Codeunit "NPR JSON Builder"; CustomerNo: Code[20]; CurrencyCode: Code[20]): Codeunit "NPR Json Builder"
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
    begin
        ResponseJson.StartArray('receipts');
        if (CustomerNo <> '') then begin
            POSEntry.SetFilter("Customer No.", '=%1', CustomerNo);
            if (not POSEntry.FindSet()) then begin
                ResponseJson.EndArray();
                exit(ResponseJson);
            end;
        end;

        repeat
            if POSEntry."POS Store Code" <> '' then begin
                Clear(POSStore);
                POSStore.SetRange(Code, POSEntry."POS Store Code");
                POSStore.FindFirst();

                ResponseJson.StartObject()
                                .AddProperty('entryNo', POSEntry."Entry No.")
                                .StartObject('storeAddress')
                                    .AddProperty('storeCode', POSEntry."POS Store Code")
                                    .AddProperty('name', POSStore.Name)
                                    .AddProperty('name2', POSStore."Name 2")
                                    .AddProperty('address', POSStore.Address)
                                    .AddProperty('address2', POSStore."Address 2")
                                    .AddProperty('postcode', POSStore."Post Code")
                                    .AddProperty('city', POSStore.City)
                                    .AddProperty('contact', POSStore.Contact)
                                    .AddProperty('county', POSStore.County)
                                    .AddProperty('country', POSStore."Country/Region Code")
                                    .AddProperty('vatRegistrationNo', POSStore."VAT Registration No.")
                                    .AddProperty('registrationNo', POSStore."Registration No.")
                                .EndObject()
                                .AddProperty('posUnit', POSEntry."POS Unit No.")
                                .AddProperty('receiptNumber', POSEntry."Document No.")
                                .AddProperty('salesType', Format(POSEntry."Entry Type"))
                                .AddProperty('date', POSEntry."Entry Date")
                                .AddProperty('time', POSEntry."Ending Time")
                                .AddProperty('amount', POSEntry."Amount Incl. Tax")
                                .AddProperty('currencyCode', CurrencyCode)
                                .AddProperty('vatAmount', POSEntry."Tax Amount")
                            .EndObject();
            end;
        until POSEntry.Next() = 0;

        ResponseJson.EndArray();

        exit(ResponseJson);
    end;
}
#endif