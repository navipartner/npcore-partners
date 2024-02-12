codeunit 6184683 "NPR POS Action: BG SIS FP MgtB"
{
    Access = Internal;
    SingleInstance = true;

    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        AuditLogFound, ExtendedReceipt, POSWorkshiftCheckpointFound, RequestTextRead : Boolean;
        RequestText: Text;

    internal procedure PrepareHTTPRequest(Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance; POSUnitNo: Code[10]; SalesTicketNo: Code[20]; CheckpointEntryNo: Integer) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        ClearGlobalVariables();
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        case Method of
            Method::getMfcInfo:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForRefreshFiscalPrinterInfo());
            Method::printReceipt:
                if FindAuditLog(SalesTicketNo) then begin
                    GetRequestText(true);
                    Request.Add('requestBody', RequestText);
                end;
            Method::printXReport:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintXReport());
            Method::printZReport:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintZReport());
            Method::printDuplicate:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintDuplicate());
            Method::cashHandling:
                if GetPOSWorkshiftCheckpoint(CheckpointEntryNo) then
                    Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForCashHandling(POSWorkshiftCheckpoint));
            Method::printLastNotFiscalized:
                if FindLastNotFiscalizedAuditLog(POSUnitNo) then begin
                    GetRequestText(true);
                    Request.Add('requestBody', RequestText);
                end;
            Method::printSelectedNotFiscalized:
                if SelectNotFiscalizedAuditLog(POSUnitNo) then begin
                    GetRequestText(true);
                    Request.Add('requestBody', RequestText);
                end;
            Method::getCashBalance:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForGetCashBalance());
        // TO-DO this will be finished in one of the future tasks
        // Method::getReceipt:
        //     if SelectFiscalizedAuditLog(POSUnitNo) then
        //         Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForGetReceipt(BGSISPOSAuditLogAux));
        end;
    end;

    internal procedure HandleResponse(ResponseText: Text; Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance; POSUnitNo: Code[10]; SalesTicketNo: Code[20]; CheckpointEntryNo: Integer)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        case Method of
            Method::getMfcInfo:
                BGSISCommunicationMgt.ProcessFiscalPrinterInfoResponse(POSUnitNo, ResponseText);
            Method::printReceipt:
                if FindAuditLog(SalesTicketNo) then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, POSUnitNo, ResponseText, RequestText, ExtendedReceipt);
                end;
            Method::printXReport:
                BGSISCommunicationMgt.ProcessPrintXReportResponse(ResponseText);
            Method::printZReport:
                BGSISCommunicationMgt.ProcessPrintZReportResponse(ResponseText);
            Method::printDuplicate:
                BGSISCommunicationMgt.ProcessPrintDuplicateResponse(ResponseText);
            Method::cashHandling:
                if GetPOSWorkshiftCheckpoint(CheckpointEntryNo) then
                    BGSISCommunicationMgt.ProcessCashHandlingResponse(ResponseText);
            Method::printLastNotFiscalized:
                if FindLastNotFiscalizedAuditLog(POSUnitNo) then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, POSUnitNo, ResponseText, RequestText, ExtendedReceipt);
                end;
            Method::printSelectedNotFiscalized:
                if AuditLogFound then begin
                    GetRequestText(false);
                    BGSISCommunicationMgt.ProcessPrintSaleAndRefundResponse(BGSISPOSAuditLogAux, POSUnitNo, ResponseText, RequestText, ExtendedReceipt);
                end;
            Method::getCashBalance:
                BGSISCommunicationMgt.ProcessGetCashBalanceResponse(ResponseText);
        // TO-DO this will be finished in one of the future tasks
        // Method::getReceipt:
        //     if AuditLogFound then
        //         BGSISCommunicationMgt.ProcessGetReceiptResponse(BGSISPOSAuditLogAux, ResponseText);
        end;
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
}
