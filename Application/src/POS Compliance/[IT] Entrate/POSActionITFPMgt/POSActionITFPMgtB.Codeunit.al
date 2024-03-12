codeunit 6184706 "NPR POS Action: IT FP Mgt. B"
{
    Access = Internal;
    SingleInstance = true;

    var
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        ITPrinterMgt: Codeunit "NPR IT Printer Mgt.";
        POSWorkshiftCheckpointFound: Boolean;

    internal procedure CreateHTTPRequestBody(Method: Option logInPrinter,getPrinterModel,getPaymentMethods,getVATSetup,printReceipt,printZReport,printXReport,printLastReceipt,setLogo; Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Requests: JsonArray;
    var
        RequestIndex: Integer;
    begin
        Clear(POSWorkshiftCheckpointFound);
        ITPOSUnitMapping.Get(GetPOSUnitNo(Sale));
        ITPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Method := Context.GetIntegerParameter('Method');

        case Method of
            Method::logInPrinter:
                begin
                    ITPOSUnitMapping.TestField("Fiscal Printer Password");
                    AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('4238', '20')));
                    AddRequestToRequestsArray(Requests, 1, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('4038', ITPrinterMgt.FormatLoginCommandData(ITPOSUnitMapping))));
                end;
            Method::getVATSetup:
                begin
                    ITPrinterMgt.CreateDummyFirstRequest(Requests);
                    for RequestIndex := 1 to 9 do
                        AddRequestToRequestsArray(Requests, RequestIndex, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('4205', Format("NPR IT Printer Departments".FromInteger(RequestIndex)))));
                end;
            Method::getPrinterModel:
                begin
                    AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('1138', '1')));
                    AddRequestToRequestsArray(Requests, 1, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('3217', '1')));
                end;
            Method::getPaymentMethods:
                begin
                    ITPrinterMgt.CreateDummyFirstRequest(Requests);
                    ITPrinterMgt.CreateRequestsForPOSPaymentMethodMapping(ITPOSUnitMapping, Requests);
                end;
            Method::printReceipt:
                begin
                    if not GetAuditLog(ITPOSAuditLogAuxInfo, GetSalesTicketNo(Context)) then
                        exit;
                    case ITPOSAuditLogAuxInfo."Transaction Type" of
                        "NPR IT Transaction Type"::SALE:
                            AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreateNormalSaleRequestMessage(ITPOSAuditLogAuxInfo));
                        "NPR IT Transaction Type"::REFUND:
                            AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreateNormalRefundRequestMessage(ITPOSAuditLogAuxInfo));
                    end;
                end;
            Method::printZReport:
                AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreateZReportPrintRequestMessage());
            Method::printXReport:
                AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreateXReportPrintRequestMessage());
            Method::printLastReceipt:
                AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('1047', '1')));
#if not (BC17 or BC18 or BC19)
            Method::setLogo:
                begin
                    ITPOSUnitMapping.TestField("Fiscal Printer Logo");
                    AddRequestToRequestsArray(Requests, 0, ITPrinterMgt.CreateSetLogoRequestMessage(ITPOSUnitMapping));
                end;
#endif
        end;
    end;

    internal procedure HandleResponse(Method: Option logInPrinter,getPrinterModel,getPaymentMethods,getVATSetup,printReceipt,printZReport,printXReport,printLastReceipt,setLogo; Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        ResponseToken: JsonToken;
    begin
        ResponseToken := Context.GetJToken('resultValues');

        case Method of
            Method::logInPrinter:
                ITPrinterMgt.ProcessFPrinterLoginResponse(ResponseToken);
            Method::getPrinterModel:
                ITPrinterMgt.ProcessFPrinterModelResponse(ITPOSUnitMapping, ResponseToken);
            Method::getPaymentMethods:
                ITPrinterMgt.ProcessFPrinterPaymentMethodsResponse(ITPOSUnitMapping, ResponseToken);
            Method::getVATSetup:
                ITPrinterMgt.ProcessFPrinterVATDepartmentsResponse(ITPOSUnitMapping, ResponseToken);
            Method::printReceipt:
                ITPrinterMgt.ProcessFPrinterPrintReceiptRespose(ITPOSUnitMapping, ITPOSAuditLogAuxInfo, ResponseToken);
            Method::printZReport:
                ITPrinterMgt.ProcessFPrinterPrintZReportResponse(ResponseToken);
            Method::printXReport:
                ITPrinterMgt.ProcessFPrinterPrintXReportResponse(ResponseToken);
            Method::printLastReceipt:
                ITPrinterMgt.ProcessFPrinterPrintLastReceiptResponse(ResponseToken);
#if not (BC17 or BC18 or BC19)
            Method::setLogo:
                ITPrinterMgt.ProcessFPrinterSetLogoResponse(ResponseToken);
#endif
        end;
    end;

    #region Helper Procedures

    local procedure AddRequestToRequestsArray(var Requests: JsonArray; Index: Integer; RequestBody: Text)
    var
        Request: JsonObject;
    begin
        Request.Remove('requestBody');
        Request.Remove('index');
        Request.Add('index', Index);
        Request.Add('url', ITPrinterMgt.FormatHTTPRequestUrl(ITPOSUnitMapping."Fiscal Printer IP Address"));
        Request.Add('requestBody', RequestBody);
        Requests.Add(Request);
    end;

    local procedure GetPOSUnitNo(Sale: Codeunit "NPR POS Sale"): Code[10]
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        exit(POSSale."Register No.");
    end;

    local procedure GetAuditLog(var ITPOSAuditLogAuxInfo2: Record "NPR IT POS Audit Log Aux Info"; SalesTicketNo: Code[20]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if not GetPOSEntry(SalesTicketNo, POSEntry) then
            exit(false);

        if not ITPOSAuditLogAuxInfo2.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit(false);

        exit(true);
    end;

    local procedure GetPOSEntry(DocumentNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", DocumentNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure GetSalesTicketNo(var Context: Codeunit "NPR POS JSON Helper") SalesTicketNo: Code[20];
    var
        CustomParameters: JsonObject;
        JsonToken: JsonToken;
    begin
        CustomParameters := Context.GetJsonObject('customParameters');
        CustomParameters.Get('salesTicketNo', JsonToken);
        SalesTicketNo := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(SalesTicketNo));
    end;
    #endregion
}