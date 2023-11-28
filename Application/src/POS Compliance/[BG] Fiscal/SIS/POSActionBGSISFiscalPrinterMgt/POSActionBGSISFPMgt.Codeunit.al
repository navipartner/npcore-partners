codeunit 6184606 "NPR POS Action: BG SIS FP Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        AuditLogFound, ExtendedReceipt, POSWorkshiftCheckpointFound, RequestTextRead : Boolean;
        RequestText: Text;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        // TO-DO this will be finished in one of the future tasks
        // ParamMethodOptionsCaptionLbl: Label 'Get Mfc Info,Print Receipt,Print X Report,Print Z Report,Print Duplicate,Cash Handling,Print Last Not Fiscalized,Print Selected Not Fiscalized,Get Receipt';
        // ParamMethodOptionsLbl: Label 'getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getReceipt', Locked = true;
        ParamMethodOptionsCaptionLbl: Label 'Get Mfc Info,Print Receipt,Print X Report,Print Z Report,Print Duplicate,Cash Handling,Print Last Not Fiscalized,Print Selected Not Fiscalized';
        ParamMethodOptionsLbl: Label 'getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Method', ParamMethodOptionsLbl, '', ParamMethodCaptionLbl, ParamMethodDescrLbl, ParamMethodOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareRequest':
                FrontEnd.WorkflowResponse(PrepareHTTPRequest(Context, Sale));
            'HandleResponse':
                HandleResponse(Context, Sale);
        end;
    end;

    local procedure PrepareHTTPRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        // TO-DO this will be finished in one of the future tasks
        // Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getReceipt;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized;
    begin
        ClearGlobalVariables();
        BGSISPOSUnitMapping.Get(GetPOSUnitNo(Sale));
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Response.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        Method := Context.GetIntegerParameter('Method');

        case Method of
            Method::getMfcInfo:
                Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForRefreshFiscalPrinterInfo());
            Method::printReceipt:
                if FindAuditLog(GetSalesTicketNo(Context)) then begin
                    GetRequestText(true);
                    Response.Add('requestBody', RequestText);
                end;
            Method::printXReport:
                Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintXReport());
            Method::printZReport:
                Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintZReport());
            Method::printDuplicate:
                Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintDuplicate());
            Method::cashHandling:
                if GetPOSWorkshiftCheckpoint(GetCheckpointEntryNo(Context)) then
                    Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForCashHandling(POSWorkshiftCheckpoint));
            Method::printLastNotFiscalized:
                if FindLastNotFiscalizedAuditLog(GetPOSUnitNo(Sale)) then begin
                    GetRequestText(true);
                    Response.Add('requestBody', RequestText);
                end;
            Method::printSelectedNotFiscalized:
                if SelectNotFiscalizedAuditLog(GetPOSUnitNo(Sale)) then begin
                    GetRequestText(true);
                    Response.Add('requestBody', RequestText);
                end;
        // TO-DO this will be finished in one of the future tasks
        // Method::getReceipt:
        //     if SelectFiscalizedAuditLog(GetPOSUnitNo(Sale)) then
        //         Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForGetReceipt(BGSISPOSAuditLogAux));
        end;
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        Response: JsonObject;
        // TO-DO this will be finished in one of the future tasks
        // Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getReceipt;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);

        Method := Context.GetIntegerParameter('Method');

        case Method of
            Method::getMfcInfo:
                BGSISCommunicationMgt.ProcessFiscalPrinterInfoResponse(GetPOSUnitNo(Sale), ResponseText);
            Method::printReceipt:
                if FindAuditLog(GetSalesTicketNo(Context)) then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, GetPOSUnitNo(Sale), ResponseText, RequestText, ExtendedReceipt);
                end;
            Method::printXReport:
                BGSISCommunicationMgt.ProcessPrintXReportResponse(ResponseText);
            Method::printZReport:
                BGSISCommunicationMgt.ProcessPrintZReportResponse(ResponseText);
            Method::printDuplicate:
                BGSISCommunicationMgt.ProcessPrintDuplicateResponse(ResponseText);
            Method::cashHandling:
                if GetPOSWorkshiftCheckpoint(GetCheckpointEntryNo(Context)) then
                    BGSISCommunicationMgt.ProcessCashHandlingResponse(ResponseText);
            Method::printLastNotFiscalized:
                if FindLastNotFiscalizedAuditLog(GetPOSUnitNo(Sale)) then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, GetPOSUnitNo(Sale), ResponseText, RequestText, ExtendedReceipt);
                end;
            Method::printSelectedNotFiscalized:
                if AuditLogFound then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, GetPOSUnitNo(Sale), ResponseText, RequestText, ExtendedReceipt);
                end;
        // TO-DO this will be finished in one of the future tasks
        // Method::getReceipt:
        //     if AuditLogFound then
        //         BGSISCommunicationMgt.ProcessGetReceiptResponse(BGSISPOSAuditLogAux, ResponseText);
        end;
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

    local procedure GetCheckpointEntryNo(var Context: Codeunit "NPR POS JSON Helper") CheckpointEntryNo: Integer
    var
        TransferResult: JsonObject;
        JsonToken: JsonToken;
    begin
        TransferResult := Context.GetJsonObject('transferResult');
        TransferResult.Get('checkpointEntryNo', JsonToken);
        CheckpointEntryNo := JsonToken.AsValue().AsInteger();
    end;

    local procedure ClearGlobalVariables()
    begin
        Clear(BGSISPOSAuditLogAux);
        Clear(POSWorkshiftCheckpoint);
        Clear(AuditLogFound);
        Clear(POSWorkshiftCheckpointFound);
        Clear(RequestText);
        Clear(RequestTextRead);
        Clear(ExtendedReceipt);
    end;

    local procedure FindAuditLog(SalesTicketNo: Code[20]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if AuditLogFound then
            exit(true);

        if not FindPOSEntry(SalesTicketNo, POSEntry) then
            exit(false);

        if not BGSISPOSAuditLogAux.FindAuditLog(POSEntry."Entry No.") then
            exit(false);

        AuditLogFound := true;
        exit(true);
    end;

    local procedure FindPOSEntry(DocumentNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", DocumentNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure FindLastNotFiscalizedAuditLog(POSUnitNo: Code[10]): Boolean
    begin
        if AuditLogFound then
            exit(true);

        BGSISPOSAuditLogAux.SetRange("POS Unit No.", POSUnitNo);
        BGSISPOSAuditLogAux.SetRange("Grand Receipt No.", '');
        if not BGSISPOSAuditLogAux.FindLast() then
            exit(false);

        AuditLogFound := true;
        exit(true);
    end;

    local procedure SelectNotFiscalizedAuditLog(POSUnitNo: Code[10]): Boolean
    begin
        if AuditLogFound then
            exit(true);

        BGSISPOSAuditLogAux.FilterGroup(10);
        BGSISPOSAuditLogAux.SetRange("POS Unit No.", POSUnitNo);
        BGSISPOSAuditLogAux.SetRange("Grand Receipt No.", '');
        BGSISPOSAuditLogAux.FilterGroup(0);
        if not (Page.RunModal(0, BGSISPOSAuditLogAux) = Action::LookupOK) then
            exit(false);

        AuditLogFound := true;
        exit(true);
    end;

    // TO-DO this will be finished in one of the future tasks
    // local procedure SelectFiscalizedAuditLog(POSUnitNo: Code[10]): Boolean
    // begin
    //     if AuditLogFound then
    //         exit(true);

    //     BGSISPOSAuditLogAux.FilterGroup(10);
    //     BGSISPOSAuditLogAux.SetRange("POS Unit No.", POSUnitNo);
    //     BGSISPOSAuditLogAux.SetFilter("Grand Receipt No.", '<>%1', '');
    //     BGSISPOSAuditLogAux.FilterGroup(0);
    //     if not Page.RunModal(0, BGSISPOSAuditLogAux) = Action::LookupOK then
    //         exit(false);

    //         AuditLogFound := true;
    //         exit(true);
    // end;

    local procedure GetRequestText(AskForExtendedReceipt: Boolean)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        ExtendedReceiptQst: Label 'Do you want to create extended fiscal receipt?';
    begin
        if RequestTextRead then
            exit;

        if AskForExtendedReceipt then
            ExtendedReceipt := Confirm(ExtendedReceiptQst);

        RequestText := BGSISCommunicationMgt.CreateJSONBodyForSaleAndRefund(BGSISPOSAuditLogAux, ExtendedReceipt);
        RequestTextRead := true;
    end;

    local procedure GetPOSWorkshiftCheckpoint(CheckpointEntryNo: Integer): Boolean
    begin
        if POSWorkshiftCheckpointFound then
            exit(true);

        if not POSWorkshiftCheckpoint.Get(CheckpointEntryNo) then
            exit(false);

        POSWorkshiftCheckpointFound := true;
        exit(true);
    end;

    local procedure GetPOSUnitNo(Sale: Codeunit "NPR POS Sale"): Code[10]
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        exit(POSSale."Register No.");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISFPMgt.js###
'let main=async({workflow:t,context:n})=>{let e=await t.respond("PrepareRequest");if(e.requestBody){const s=await(await fetch(e.url,{method:"POST",headers:{"Content-Type":"application/json"},body:e.requestBody})).json();await t.respond("HandleResponse",{result:s})}};'
        );
    end;
}
