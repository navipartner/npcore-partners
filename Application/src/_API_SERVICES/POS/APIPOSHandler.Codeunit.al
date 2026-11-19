#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185056 "NPR API POS Handler" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _LastRoute: Text;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        APIPOSSale: Codeunit "NPR API POS Sale";
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
        APIPOSSaleLineV1: Codeunit "NPR API POS Sale Line V1";
        APIPOSSaleLineV2: Codeunit "NPR API POS Sale Line V2";
        APIPOSPaymentLine: Codeunit "NPR API POS Payment Line";
        APIPOSSalesperson: Codeunit "NPR API POS Salesperson";
        APIExternalPOSSale: Codeunit "NPR API External POS Sale";
        APIPOSGlobalEntry: Codeunit "NPR API POS Global Entry";
        APIPOSUnit: Codeunit "NPR APIPOSUnit";
        APIPOSStore: Codeunit "NPR APIPOSStore";
        APIPOSEntry: Codeunit "NPR API POS Entry";
        APIPOSEFTAdyen: Codeunit "NPR API POS EFT Adyen Cloud";
    begin
        case true of
            Request.Match('POST', '/pos/sale/:saleId'):
                exit(APIPOSSale.CreateSale(Request));
            Request.Match('PATCH', '/pos/sale/:saleId'):
                exit(APIPOSSale.UpdateSale(Request));
            Request.Match('DELETE', '/pos/sale/:saleId'):
                exit(APIPOSSale.DeleteSale(Request));
            Request.Match('POST', '/pos/sale/:saleId/complete'):
                exit(APIPOSSale.CompleteSale(Request));
            Request.Match('POST', '/pos/sale/:saleId/park'):
                exit(APIPOSSale.ParkSale(Request));
            Request.Match('POST', '/pos/sale/:saleId/resume'):
                exit(APIPOSSale.ResumeSale(Request));
            Request.Match('POST', '/pos/unit/:unitId/open'):
                exit(APIPOSUnit.OpenPOSUnit(Request));

            Request.Match('GET', '/pos/sale/:saleId/saleline/:saleLineId'):
                exit(APIPOSSaleLine.GetSaleLine(Request));
            Request.Match('GET', '/pos/sale/:saleId/saleline'):
                exit(APIPOSSaleLine.ListSaleLines(Request));
            Request.Match('POST', '/pos/sale/:saleId/saleline/:saleLineId'):
                if IsSaleLineV2(Request, 'create') then
                    exit(APIPOSSaleLineV2.CreateSaleLine(Request))
                else
                    exit(APIPOSSaleLineV1.CreateSaleLine(Request));
            Request.Match('POST', '/pos/sale/:saleId/saleline/:saleLineId/addon'):
                if IsSaleLineV2(Request, 'addon') then
                    exit(APIPOSSaleLineV2.CreateSaleLineAddon(Request))
                else
                    exit(APIPOSSaleLineV1.CreateSaleLineAddon(Request));
            Request.Match('PATCH', '/pos/sale/:saleId/saleline/:saleLineId'):
                exit(APIPOSSaleLine.UpdateSaleLine(Request));
            Request.Match('DELETE', '/pos/sale/:saleId/saleline/:saleLineId'):
                exit(APIPOSSaleLine.DeleteSaleLine(Request));

            Request.Match('GET', '/pos/sale/:saleId/paymentline/:paymentLineId'):
                exit(APIPOSPaymentLine.GetPaymentLine(Request));
            Request.Match('GET', '/pos/sale/:saleId/paymentline'):
                exit(APIPOSPaymentLine.ListPaymentLines(Request));
            Request.Match('POST', '/pos/sale/:saleId/paymentline/:paymentLineId'):
                exit(APIPOSPaymentLine.CreatePaymentLine(Request));
            Request.Match('DELETE', '/pos/sale/:saleId/paymentline/:paymentLineId'):
                exit(APIPOSPaymentLine.DeletePaymentLine(Request));

            // EFT (Adyen Cloud) endpoints
            Request.Match('POST', '/pos/sale/:saleId/eft/prepare'):
                exit(APIPOSEFTAdyen.PrepareEFTPayment(Request));
            Request.Match('GET', '/pos/sale/:saleId/eft/:transactionId/local/buildRequest'):
                exit(APIPOSEFTAdyen.BuildEFTRequest(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionId/local/parseResponse'):
                exit(APIPOSEFTAdyen.ParseEFTResponse(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/local/generateBoardingToken'):
                exit(APIPOSEFTAdyen.GenerateBoardingToken(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionId/cloud/start'):
                exit(APIPOSEFTAdyen.StartEFTPayment(Request));
            Request.Match('GET', '/pos/sale/:saleId/eft/:transactionId/cloud/status'):
                exit(APIPOSEFTAdyen.PollEFTStatus(Request));
            Request.Match('POST', '/pos/sale/:saleId/eft/:transactionId/cloud/cancel'):
                exit(APIPOSEFTAdyen.CancelEFTTransaction(Request));

            Request.Match('GET', '/pos/sale/search'):
                exit(APIPOSSale.SearchSale(Request));
            Request.Match('GET', '/pos/sale'):
                exit(APIPOSSale.SearchSale(Request));
            Request.Match('GET', '/pos/sale/:saleId'):
                exit(APIPOSSale.GetSale(Request));

            Request.Match('POST', 'pos/salesperson/login'):
                exit(APIPOSSalesperson.Login(Request));
            request.Match('GET', 'pos/salesperson/:id'):
                exit(APIPOSSalesperson.GetSalesperson(Request));
            Request.Match('POST', 'pos/salesperson/:id/block'):
                exit(APIPOSSalesperson.BlockSalesperson(Request));
            Request.Match('POST', 'pos/salesperson/:id/unblock'):
                exit(APIPOSSalesperson.UnblockSalesperson(Request));
            Request.Match('PATCH', '/pos/salesperson/:id'):
                exit(APIPOSSalesperson.UpdateSalesperson(Request));
            Request.Match('POST', 'pos/salesperson'):
                exit(APIPOSSalesperson.CreateSalesperson(Request));
            Request.Match('GET', '/pos/salesperson'):
                exit(APIPOSSalesperson.ListSalesperson(Request));

            Request.Match('GET', '/pos/externalsale/:saleId'):
                exit(APIExternalPOSSale.GetSale(Request));
            Request.Match('GET', '/pos/externalsale'):
                exit(APIExternalPOSSale.ListSales(Request));
            Request.Match('POST', '/pos/externalsale'):
                exit(APIExternalPOSSale.CreateSale(Request));
            Request.Match('GET', '/pos/entry/:entryId/print/salesreceipt'):
                exit(APIPOSEntry.PrintPosEntry(Request, Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)"));
            Request.Match('GET', '/pos/entry/:entryId/print/terminalreceipt'):
                exit(APIPOSEntry.PrintPosEntry(Request, Enum::"NPR Report Selection Type"::"Terminal Receipt"));
            Request.Match('POST', '/pos/entry/:entryId/issuedigitalreceipt'):
                exit(APIPOSEntry.IssueDigitalReceipt(Request));
            Request.Match('GET', '/pos/entry/:entryId'):
                exit(APIPOSEntry.GetEntry(Request));
            Request.Match('GET', '/pos/entry'):
                exit(APIPOSEntry.ListEntries(Request));

            Request.Match('POST', '/pos/globalentry'):
                exit(APIPOSGlobalEntry.InsertPosSalesEntries(Request));
            Request.Match('GET', '/pos/globalentry/getbyreference'):
                exit(APIPOSGlobalEntry.GetGlobalEntryByReference(Request));
            Request.Match('GET', '/pos/globalentry/getbyreference/pdf'):
                exit(APIPOSGlobalEntry.GetGlobalEntryByReferencePdf(Request));
            Request.Match('GET', '/pos/globalentry/search'):
                exit(APIPOSGlobalEntry.SearchGlobalEntry(Request));
            Request.Match('GET', '/pos/globalentry/:id'):
                exit(APIPOSGlobalEntry.GetGlobalEntry(Request));

            Request.Match('GET', '/pos/unit/me'):
                exit(APIPOSUnit.GetCurrentPOSUnit(Request));
            Request.Match('GET', '/pos/unit/:unitId'):
                exit(APIPOSUnit.GetPOSUnit(Request));
            Request.Match('GET', '/pos/unit'):
                exit(APIPOSUnit.GetPOSUnits(Request));

            Request.Match('GET', '/pos/store'):
                exit(APIPOSStore.GetPOSStores(Request));
        end;
    end;

    internal procedure V2From(): Date
    begin
        exit(20261123D);
    end;

    local procedure IsSaleLineV2(var Request: Codeunit "NPR API Request"; Operation: Text): Boolean
    var
        RequestDate: Date;
        RequestedDate: Date;
        HeaderState: Text;
    begin
        HeaderState := ClassifyHeader(Request, RequestedDate);
        if HeaderState = 'invalid' then
            LogRoute(Operation, HeaderState, RequestedDate, 'rejected');
        RequestDate := Request.ApiVersion();
        case true of
            RequestDate >= V2From():
                begin
                    LogRoute(Operation, HeaderState, RequestedDate, 'V2');
                    exit(true);
                end;
            else begin
                LogRoute(Operation, HeaderState, RequestedDate, 'V1');
                exit(false);
            end;
        end;
    end;

    local procedure ClassifyHeader(var Request: Codeunit "NPR API Request"; var RequestDate: Date): Text
    var
        Headers: Dictionary of [Text, Text];
        HeaderValue: Text;
    begin
        RequestDate := 0D;
        Headers := Request.Headers();
        if not Headers.Get('x-api-version', HeaderValue) then
            exit('absent');
        if HeaderValue = '' then
            exit('empty');
        if not Evaluate(RequestDate, HeaderValue, 9) then begin
            RequestDate := 0D;
            exit('invalid');
        end;
        if RequestDate = 0D then
            exit('empty');
        exit('date');
    end;

    local procedure LogRoute(Operation: Text; HeaderState: Text; RequestDate: Date; RoutedTo: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        CustomDimensions: Dictionary of [Text, Text];
        RequestedDateText: Text;
        RouteMessageLbl: Label 'POS sale line %1 routed to %2', Locked = true, Comment = '%1 = operation, %2 = the code that serves it';
    begin
        _LastRoute := Operation + '|' + HeaderState + '|' + RoutedTo;
        RequestedDateText := Format(RequestDate, 0, 9);

        CustomDimensions.Add('NPR_Operation', Operation);
        CustomDimensions.Add('NPR_HeaderState', HeaderState);
        CustomDimensions.Add('NPR_RequestedDate', RequestedDateText);
        CustomDimensions.Add('NPR_RoutedTo', RoutedTo);
        Session.LogMessage('NPR_API_POSSaleLineRoute', StrSubstNo(RouteMessageLbl, Operation, RoutedTo), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        Sentry.AddTransactionTag('bc.pos-api.route', RoutedTo);
        Sentry.AddTransactionTag('bc.pos-api.headerState', HeaderState);
        if RequestDate <> 0D then
            Sentry.AddTransactionTag('bc.pos-api.requestedDate', RequestedDateText);
    end;

    internal procedure LastRoute(): Text
    begin
        exit(_LastRoute);
    end;
}
#endif