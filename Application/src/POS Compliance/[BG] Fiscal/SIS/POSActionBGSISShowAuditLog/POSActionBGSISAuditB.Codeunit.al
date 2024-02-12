codeunit 6184684 "NPR POS Action: BG SIS Audit B"
{
    Access = Internal;

    internal procedure ShowBGSISAuditLog(Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction)
    var
        BGSISPOSAuditLogAux, BGSISPOSAuditLogAux2 : Record "NPR BG SIS POS Audit Log Aux.";
        BGSISPOSAuditLogAuxPage: Page "NPR BG SIS POS Audit Log Aux.";
    begin
        BGSISPOSAuditLogAux.FilterGroup(10);

        case Show of
            Show::AllFiscalized:
                BGSISPOSAuditLogAux.SetFilter("Grand Receipt No.", '<>%1', '');
            Show::AllNonFiscalized:
                BGSISPOSAuditLogAux.SetRange("Grand Receipt No.", '');
            Show::LastTransaction:
                begin
                    BGSISPOSAuditLogAux2.SetLoadFields("Audit Entry Type", "Audit Entry No.");
                    BGSISPOSAuditLogAux2.SetFilter("Grand Receipt No.", '<>%1', '');
                    BGSISPOSAuditLogAux2.FindLast();

                    BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux2."Audit Entry Type");
                    BGSISPOSAuditLogAux.SetRange("Audit Entry No.", BGSISPOSAuditLogAux2."Audit Entry No.");
                end;
        end;

        BGSISPOSAuditLogAux.FilterGroup(0);
        BGSISPOSAuditLogAuxPage.SetTableView(BGSISPOSAuditLogAux);
        BGSISPOSAuditLogAuxPage.RunModal();
    end;
}
