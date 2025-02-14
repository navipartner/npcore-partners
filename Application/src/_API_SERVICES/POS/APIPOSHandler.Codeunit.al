#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185056 "NPR API POS Handler" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        APIPOSSale: Codeunit "NPR API POS Sale";
        APIPOSSalesperson: Codeunit "NPR API POS Salesperson";
        APIExternalPOSSale: Codeunit "NPR API External POS Sale";
        APIPOSGlobalEntry: Codeunit "NPR API POS Global Entry";
    begin
        case true of
            Request.Match('GET', '/pos/sale/search'):
                exit(APIPOSSale.SearchSale(Request));
            Request.Match('GET', '/pos/sale/:saleId'):
                exit(APIPOSSale.GetSale(Request));
            Request.Match('POST', 'pos/salesperson/login'):
                exit(APIPOSSalesperson.Login(Request));
            request.Match('GET', 'pos/salesperson/:id'):
                exit(APIPOSSalesperson.GetSalesperson(Request));
            Request.Match('GET', '/pos/externalsale/:saleId'):
                exit(APIExternalPOSSale.GetSale(Request));
            Request.Match('POST', '/pos/externalsale'):
                exit(APIExternalPOSSale.CreateSale(Request));
            Request.Match('POST', '/pos/globalentry'):
                exit(APIPOSGlobalEntry.InsertPosSalesEntries(Request));
        end;
    end;
}
#endif