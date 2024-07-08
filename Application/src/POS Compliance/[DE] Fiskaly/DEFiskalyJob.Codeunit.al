codeunit 6014449 "NPR DE Fiskaly Job"
{
    Access = Internal;

    trigger OnRun()
    var
        DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
        DeAuditAux2: Record "NPR DE POS Audit Log Aux. Info";
        DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
    begin
        DeAuditAux.SetCurrentKey("Fiscalization Status");
        DeAuditAux.SetFilter("Fiscalization Status", '<>%1', DeAuditAux."Fiscalization Status"::Fiscalized);
        if DeAuditAux.FindSet(true) then
            repeat
                DeAuditAux2 := DeAuditAux;
                DEFiskalyComm.SendDocument(DeAuditAux2);
            until DeAuditAux.Next() = 0;
    end;
}
