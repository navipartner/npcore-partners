codeunit 6184735 "NPR POS Action: BG SIS ReprFRB"
{
    Access = Internal;

    internal procedure PrepareHTTPRequest(Type: Option enterGrandReceiptNo,reprintSelectedFiscalized; POSUnitNo: Code[10]) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        InputDialog: Page "NPR Input Dialog";
        GrandReceiptNo: Integer;
        GrandReceiptNoLbl: Label 'Grand Receipt Number';
        GrandReceiptNoMustBeEnteredAndPositiveErr: Label 'Grand Receipt Number must be entered and positive number.';
        TypeOfReprintFromElectronicJournal: Option EOD,T2TEOD,T2TDATE;
        Param1, Param2, Param3, Param4 : Text;
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        case Type of
            Type::enterGrandReceiptNo:
                begin
                    InputDialog.SetInput(1, GrandReceiptNo, GrandReceiptNoLbl);
                    InputDialog.RunModal();
                    InputDialog.InputInteger(1, GrandReceiptNo);

                    if GrandReceiptNo < 1 then
                        Error(GrandReceiptNoMustBeEnteredAndPositiveErr);
                end;
            Type::reprintSelectedFiscalized:
                if not SelectFiscalizedAuditLog(POSUnitNo, GrandReceiptNo) then
                    Error('');
        end;

        Param1 := Format(-1); // directive from SIS is to always use -1
        Param2 := Format(GrandReceiptNo).PadLeft(10, '0');
        Param3 := Param1;
        Param4 := Format(GrandReceiptNo).PadLeft(10, '0');

        Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForReprintFromElectronicJournal(TypeOfReprintFromElectronicJournal::T2TEOD, Param1, Param2, Param3, Param4));
    end;

    internal procedure HandleResponse(ResponseText: Text)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        BGSISCommunicationMgt.ProcessReprintFromElectronicJournalResponse(ResponseText);
    end;

    local procedure SelectFiscalizedAuditLog(POSUnitNo: Code[10]; var GrandReceiptNo: Integer): Boolean
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        BGSISPOSAuditLogAux.FilterGroup(10);
        BGSISPOSAuditLogAux.SetRange("POS Unit No.", POSUnitNo);
        BGSISPOSAuditLogAux.SetFilter("Grand Receipt No.", '<>%1', '');
        BGSISPOSAuditLogAux.FilterGroup(0);
        if not (Page.RunModal(0, BGSISPOSAuditLogAux) = Action::LookupOK) then
            exit(false);

        Evaluate(GrandReceiptNo, BGSISPOSAuditLogAux."Grand Receipt No.");
        exit(true);
    end;
}
