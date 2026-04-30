#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185056 "NPR API POS Handler" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        APIPOSSale: Codeunit "NPR API POS Sale";
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
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

            Request.Match('GET', '/pos/sale/:saleId/saleline/:saleLineId'):
                exit(APIPOSSaleLine.GetSaleLine(Request));
            Request.Match('GET', '/pos/sale/:saleId/saleline'):
                exit(APIPOSSaleLine.ListSaleLines(Request));
            Request.Match('POST', '/pos/sale/:saleId/saleline/:saleLineId'):
                exit(APIPOSSaleLine.CreateSaleLine(Request));
            Request.Match('POST', '/pos/sale/:saleId/saleline/:saleLineId/addon'):
                exit(APIPOSSaleLine.CreateSaleLineAddon(Request));
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
}
#endif