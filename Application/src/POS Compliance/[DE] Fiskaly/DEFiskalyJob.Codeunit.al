codeunit 6014449 "NPR DE Fiskaly Job"
{
    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        DEAuditSetup: Record "NPR DE Audit Setup";
        DEPOSAuditLogAux: Record "NPR DE POS Audit Log Aux. Info";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
        DocumentJson: JsonObject;
        ResponseJson: JsonObject;
    begin
        DEPOSAuditLogAux.Reset();
        DEPOSAuditLogAux.SetFilter("Fiscalization Status", '<> %1', DEPOSAuditLogAux."Fiscalization Status"::Fiscalized);

        if DEPOSAuditLogAux.FindSet(true) then
            repeat
                Clear(DocumentJson);
                POSEntry.Get(DEPOSAuditLogAux."POS Entry No.");
                POSUnitAux.Get(POSEntry."POS Unit No.");
                DEAuditSetup.Get();
                DEAuditMgt.CreateDocumentJson(DEPOSAuditLogAux."POS Entry No.", POSUnitAux, DocumentJson);

                if not DEFiskalyComm.SendDocument(DEPOSAuditLogAux, DocumentJson, ResponseJson, DEAuditSetup) then
                    DEAuditMgt.SetErrorMsg(DEPOSAuditLogAux)
                else
                    if not DEAuditMgt.DeAuxInfoInsertResponse(DEPOSAuditLogAux, ResponseJson) then
                        DEAuditMgt.SetErrorMsg(DEPOSAuditLogAux);

                DEAuditSetup.Modify();
                DEPOSAuditLogAux.Modify();
            until DEPOSAuditLogAux.Next() = 0;
    end;
}